const fs = require('fs/promises');
const path = require('path');
const { FileSystemHelper } = require('../shared/utils');

class ReferenceWriter {
  constructor({ dataPathLayout }) {
    this.dataPathLayout = dataPathLayout;
  }

  async fileExists(file) {
    return FileSystemHelper.fileExists(file);
  }

  async readAnnualEntries(year) {
    const { file } = this.dataPathLayout.buildAnnualReferencePath(year);
    if (!await this.fileExists(file)) {
      return [];
    }

    const parsed = await FileSystemHelper.readJson(file);
    if (!Array.isArray(parsed)) {
      throw new Error(`Annual reference file must contain an array: ${file}`);
    }

    return parsed;
  }

  async writeAnnualEntries(year, entries) {
    const { dir, file } = this.dataPathLayout.buildAnnualReferencePath(year);
    await fs.mkdir(dir, { recursive: true });
    await FileSystemHelper.writeJson(file, entries);
    console.log(`Wrote ${path.relative(process.cwd(), file)}`);
    return file;
  }
}

module.exports = {
  ReferenceWriter,
};
