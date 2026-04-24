const fs = require('fs/promises');
const path = require('path');
const { FileSystemHelper } = require('../shared/utils');

class PassageFieldProcessor {
  constructor({ referenceParser, bibleApiClient }) {
    this.referenceParser = referenceParser;
    this.bibleApiClient = bibleApiClient;
  }

  async processField(fieldName, value) {
    if (value == null || value === '' || (Array.isArray(value) && value.length === 0)) {
      return null;
    }

    let queries;
    try {
      queries = this.referenceParser.expandFieldValue(value);
    } catch (error) {
      return {
        field: fieldName,
        original: value,
        passages: [{ original: String(value), error: error instanceof Error ? error.message : String(error) }],
      };
    }

    const passages = [];
    for (const query of queries) {
      try {
        const response = await this.bibleApiClient.fetchPassage(query.normalizedQuery, query.fallbackQuery);
        passages.push({
          label: query.label,
          option: query.option,
          sequence: query.sequence ?? null,
          segment: query.segment,
          original: query.original,
          normalized_query: query.normalizedQuery,
          fallback_query: query.fallbackQuery,
          warnings: query.warnings,
          response,
        });
      } catch (error) {
        passages.push({
          label: query.label,
          option: query.option,
          sequence: query.sequence ?? null,
          segment: query.segment,
          original: query.original,
          normalized_query: query.normalizedQuery,
          fallback_query: query.fallbackQuery,
          warnings: query.warnings,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    return { field: fieldName, original: value, passages };
  }
}

class PassageEntryProcessor {
  constructor({ fieldProcessor, dataPathLayout, translation, fields }) {
    this.fieldProcessor = fieldProcessor;
    this.dataPathLayout = dataPathLayout;
    this.translation = translation;
    this.fields = fields;
  }

  async processReadingBlock(block) {
    const output = {};
    for (const fieldName of this.fields) {
      output[fieldName] = await this.fieldProcessor.processField(fieldName, block[fieldName]);
    }
    return output;
  }

  async processEntry(entry) {
    const base = {
      date: entry.date,
      translation: this.translation,
      source_reference_file: entry.__sourceReferenceFile || this.dataPathLayout.getRelativeReferenceFile(entry.date),
    };

    if (entry.variants && typeof entry.variants === 'object' && !Array.isArray(entry.variants)) {
      const variants = {};
      for (const [variantName, variantBlock] of Object.entries(entry.variants)) {
        variants[variantName] = await this.processReadingBlock(variantBlock);
      }
      return { ...base, variants };
    }

    return { ...base, readings: await this.processReadingBlock(entry) };
  }
}

class ReadingFileWriter {
  constructor({ dataPathLayout }) {
    this.dataPathLayout = dataPathLayout;
  }

  async fileExists(file) {
    return FileSystemHelper.fileExists(file);
  }

  async readAnnualEntries(year) {
    const { file } = this.dataPathLayout.buildAnnualReadingPath(year);
    if (!await this.fileExists(file)) {
      return [];
    }

    const parsed = await FileSystemHelper.readJson(file);
    if (!Array.isArray(parsed)) {
      throw new Error(`Annual reading file must contain an array: ${file}`);
    }

    return parsed;
  }

  async writeAnnualEntries(year, entries) {
    const { dir, file } = this.dataPathLayout.buildAnnualReadingPath(year);
    await fs.mkdir(dir, { recursive: true });
    await FileSystemHelper.writeJson(file, entries);
    console.log(`Wrote ${path.relative(process.cwd(), file)}`);
    return file;
  }
}

module.exports = {
  PassageFieldProcessor,
  PassageEntryProcessor,
  ReadingFileWriter,
};
