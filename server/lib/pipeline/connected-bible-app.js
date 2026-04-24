class ConnectedBiblePipelineApp {
  constructor({ referenceApp, passageApp, shouldDownloadPassages = true }) {
    this.referenceApp = referenceApp;
    this.passageApp = passageApp;
    this.shouldDownloadPassages = shouldDownloadPassages;
  }

  async run() {
    const allReadingFiles = [];
    let totalReadingFilesWritten = 0;

    const referenceResult = await this.referenceApp.run({
      onMonthCompleted: async ({ monthName, referenceEntries }) => {
        if (!this.shouldDownloadPassages) return;
        if (!referenceEntries || referenceEntries.length === 0) {
          console.log(`[${monthName}] No reference entries available, so passage download was skipped.`);
          return;
        }
        console.log(`[${monthName}] Starting passage download from generated reference entries...`);
        const passageResult = await this.passageApp.run({ referenceEntries });
        if (Array.isArray(passageResult.readingFiles)) {
          allReadingFiles.push(...passageResult.readingFiles);
        }
        totalReadingFilesWritten += passageResult.writtenCount ?? 0;
      },
    });

    if (!this.shouldDownloadPassages) {
      console.log('Skipping passage download because --references-only was used.');
      return { referenceResult, passageResult: null };
    }

    return {
      referenceResult,
      passageResult: { readingFiles: allReadingFiles, writtenCount: totalReadingFilesWritten },
    };
  }
}

module.exports = { ConnectedBiblePipelineApp };
