const fs = require('fs/promises');
const path = require('path');
const { FileSystemHelper } = require('../shared/utils');

class ReferenceFileLocator {
  constructor({ dataDir, dataPathLayout }) {
    this.dataDir = dataDir;
    this.dataPathLayout = dataPathLayout;
  }

  async findFiles({ input, year }) {
    if (input) {
      return [input];
    }

    const yearDir = path.join(this.dataDir, String(year));
    const annualFile = path.join(yearDir, 'references.json');
    if (await FileSystemHelper.fileExists(annualFile)) {
      return [annualFile];
    }

    let monthEntries;
    try {
      monthEntries = await fs.readdir(yearDir, { withFileTypes: true });
    } catch (error) {
      if (error && error.code === 'ENOENT') {
        throw new Error(`Reference directory not found: ${yearDir}`);
      }
      throw error;
    }

    const files = [];
    for (const entry of monthEntries) {
      if (!entry.isDirectory()) continue;
      const monthDir = path.join(yearDir, entry.name);
      const childEntries = await fs.readdir(monthDir, { withFileTypes: true });
      for (const child of childEntries) {
        if (child.isFile() && /^references_\d{2}\.json$/.test(child.name)) {
          files.push(path.join(monthDir, child.name));
        }
      }
    }

    files.sort();
    return files;
  }
}

class ReferenceFileReader {
  async readEntries(filePath) {
    const parsed = await FileSystemHelper.readJson(filePath);
    const relativeSourceFile = path.relative(process.cwd(), filePath).replace(/\\/g, '/');

    if (Array.isArray(parsed)) {
      parsed.forEach((entry, index) => this.validateEntry(entry, `${filePath} at index ${index}`));
      return parsed.map((entry) => ({ ...entry, __sourceReferenceFile: relativeSourceFile }));
    }

    this.validateEntry(parsed, filePath);
    return [{ ...parsed, __sourceReferenceFile: relativeSourceFile }];
  }

  validateEntry(parsed, sourceLabel) {
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error(`Reference file entry must contain one object: ${sourceLabel}`);
    }

    if (typeof parsed.date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(parsed.date)) {
      throw new Error(`Reference file entry is missing a valid date: ${sourceLabel}`);
    }
  }
}

module.exports = {
  ReferenceFileLocator,
  ReferenceFileReader,
};
