const path = require('path');

class DataPathLayout {
  constructor(baseDirOrOptions) {
    this.baseDir = typeof baseDirOrOptions === 'string'
      ? baseDirOrOptions
      : baseDirOrOptions?.outputDir || baseDirOrOptions?.baseDir || path.resolve(process.cwd(), 'data');
  }

  buildReferencePath(dateString) {
    const [year, month, day] = dateString.split('-');
    const dir = path.join(this.baseDir, year, month);
    const file = path.join(dir, `references_${day}.json`);
    return { dir, file };
  }

  buildAnnualReferencePath(year) {
    const dir = path.join(this.baseDir, String(year));
    const file = path.join(dir, 'references.json');
    return { dir, file };
  }

  buildReadingPath(dateString) {
    const [year, month, day] = dateString.split('-');
    const dir = path.join(this.baseDir, year, month);
    const file = path.join(dir, `readings_${day}.json`);
    return { dir, file };
  }

  buildAnnualReadingPath(year) {
    const dir = path.join(this.baseDir, String(year));
    const file = path.join(dir, 'gospels.json');
    return { dir, file };
  }

  inferDateFromReferencePath(filePath) {
    const normalized = filePath.split(path.sep);
    if (normalized.length < 2) return null;

    const fileName = normalized[normalized.length - 1];

    if (fileName === 'references.json') {
      const year = normalized[normalized.length - 2];
      return /^\d{4}$/.test(year) ? { type: 'annual', year } : null;
    }

    if (normalized.length < 3) return null;

    const month = normalized[normalized.length - 2];
    const year = normalized[normalized.length - 3];
    const match = fileName.match(/^references_(\d{2})\.json$/);

    if (!match || !/^\d{4}$/.test(year) || !/^\d{2}$/.test(month)) {
      return null;
    }

    return { type: 'daily', date: `${year}-${month}-${match[1]}` };
  }

  getRelativeReferenceFile(dateString) {
    const [year] = dateString.split('-');
    return path.relative(process.cwd(), this.buildAnnualReferencePath(year).file).replace(/\\/g, '/');
  }
}

module.exports = {
  DataPathLayout,
};
