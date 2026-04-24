const path = require('path');

class PassageGenerationApp {
  constructor({ config, fileLocator, fileReader, entryProcessor, fileWriter, dataPathLayout }) {
    this.config = config;
    this.fileLocator = fileLocator;
    this.fileReader = fileReader;
    this.entryProcessor = entryProcessor;
    this.fileWriter = fileWriter;
    this.dataPathLayout = dataPathLayout;
  }

  filterEntries(entries, { from, to, limit }) {
    let filtered = entries;

    if (from || to) {
      filtered = filtered.filter((entry) => {
        if (from && entry.date < from) return false;
        if (to && entry.date > to) return false;
        return true;
      });
    }

    filtered = filtered.sort((a, b) => String(a.date).localeCompare(String(b.date)));

    if (Number.isInteger(limit) && limit > 0) {
      filtered = filtered.slice(0, limit);
    }

    return filtered;
  }

  async resolveReferenceEntries({ referenceEntries, referenceFiles } = {}) {
    if (Array.isArray(referenceEntries) && referenceEntries.length > 0) {
      return this.filterEntries(referenceEntries, this.config);
    }

    const resolvedReferenceFiles = referenceFiles && referenceFiles.length > 0
      ? referenceFiles
      : await this.fileLocator.findFiles(this.config);

    const combinedEntries = [];
    for (const referenceFile of resolvedReferenceFiles) {
      const entries = await this.fileReader.readEntries(referenceFile);
      combinedEntries.push(...entries);
    }

    return this.filterEntries(combinedEntries, this.config);
  }

  async run({ referenceEntries, referenceFiles } = {}) {
    const resolvedReferenceEntries = await this.resolveReferenceEntries({ referenceEntries, referenceFiles });

    console.log(`Processing ${resolvedReferenceEntries.length} reference entr${resolvedReferenceEntries.length === 1 ? 'y' : 'ies'}...`);
    console.log(`Translation: ${this.config.translation}`);

    const yearlyBuckets = new Map();
    let writtenCount = 0;

    for (const entry of resolvedReferenceEntries) {
      const [year] = entry.date.split('-');

      if (!yearlyBuckets.has(year)) {
        const existingEntries = await this.fileWriter.readAnnualEntries(year);
        yearlyBuckets.set(year, {
          year,
          entriesByDate: new Map(existingEntries.map((item) => [item.date, item])),
          hasChanges: false,
        });
      }

      const bucket = yearlyBuckets.get(year);
      if (!this.config.overwrite && bucket.entriesByDate.has(entry.date)) {
        const { file } = this.dataPathLayout.buildAnnualReadingPath(year);
        console.log(`Skipping existing ${path.relative(process.cwd(), file)} entry for ${entry.date}`);
        continue;
      }

      const result = await this.entryProcessor.processEntry(entry);
      bucket.entriesByDate.set(entry.date, result);
      bucket.hasChanges = true;
      writtenCount += 1;
    }

    const readingFiles = [];
    for (const bucket of yearlyBuckets.values()) {
      const entries = Array.from(bucket.entriesByDate.values())
        .sort((a, b) => String(a.date).localeCompare(String(b.date)));

      const { file } = this.dataPathLayout.buildAnnualReadingPath(bucket.year);
      readingFiles.push(file);

      if (!bucket.hasChanges) {
        console.log(`No changes for ${path.relative(process.cwd(), file)}`);
        continue;
      }

      await this.fileWriter.writeAnnualEntries(bucket.year, entries);
    }

    console.log(`Done. ${writtenCount} reading entr${writtenCount === 1 ? 'y' : 'ies'} written.`);
    return { readingFiles, writtenCount };
  }
}

module.exports = { PassageGenerationApp };
