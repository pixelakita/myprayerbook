class ReferenceGenerationApp {
  constructor({ config, openRouterClient, referenceWriter, dataPathLayout }) {
    this.config = config;
    this.openRouterClient = openRouterClient;
    this.referenceWriter = referenceWriter;
    this.dataPathLayout = dataPathLayout;
  }

  async run({ onMonthCompleted } = {}) {
    const generatedReferenceFiles = [];
    const generatedReferenceFileSet = new Set();
    const months = this.config.months;
    const year = this.config.year;

    console.log(`Generating Bible reading references for ${year}...`);
    console.log(`Output directory: ${this.config.outputDir}`);

    const annualEntries = await this.referenceWriter.readAnnualEntries(year);
    const entriesByDate = new Map(annualEntries.map((entry) => [entry.date, entry]));

    for (const monthNumber of months) {
      const monthName = this.config.getMonthName(monthNumber);
      const daysInMonth = new Date(year, monthNumber, 0).getDate();
      const monthPrefix = `${year}-${String(monthNumber).padStart(2, '0')}-`;
      const monthDates = Array.from({ length: daysInMonth }, (_, index) => `${monthPrefix}${String(index + 1).padStart(2, '0')}`);
      const allExist = monthDates.every((date) => entriesByDate.has(date));
      const existingMonthEntries = monthDates
        .map((date) => entriesByDate.get(date))
        .filter(Boolean);

      if (allExist && !this.config.overwrite) {
        console.log(`[${monthName}] Skipping request because all reference entries already exist in references.json.`);
        const { file } = this.dataPathLayout.buildAnnualReferencePath(year);
        if (!generatedReferenceFileSet.has(file)) {
          generatedReferenceFiles.push(file);
          generatedReferenceFileSet.add(file);
        }

        if (typeof onMonthCompleted === 'function') {
          await onMonthCompleted({ monthName, referenceEntries: existingMonthEntries, referenceFile: file });
        }
        continue;
      }

      const monthData = await this.openRouterClient.fetchMonthReferences({
        monthName,
        year,
        maxRetries: 3,
      });

      for (const entry of monthData) {
        entriesByDate.set(entry.date, entry);
      }

      const mergedEntries = Array.from(entriesByDate.values())
        .sort((a, b) => String(a.date).localeCompare(String(b.date)));

      const file = await this.referenceWriter.writeAnnualEntries(year, mergedEntries);
      if (!generatedReferenceFileSet.has(file)) {
        generatedReferenceFiles.push(file);
        generatedReferenceFileSet.add(file);
      }

      if (typeof onMonthCompleted === 'function') {
        await onMonthCompleted({ monthName, referenceEntries: monthData, referenceFile: file });
      }
    }

    return { referenceFiles: generatedReferenceFiles };
  }
}

module.exports = {
  ReferenceGenerationApp,
};
