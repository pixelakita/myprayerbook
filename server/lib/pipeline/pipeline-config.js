const { PassageConfig } = require('../getpassages/passage-config');

class ReferenceToPassageConfigBuilder {
  build(referenceConfig) {
    return new PassageConfig({
      input: null,
      year: referenceConfig.year,
      dataDir: referenceConfig.outputDir,
      translation: referenceConfig.passageTranslation,
      delayMs: referenceConfig.passageDelayMs,
      retries: referenceConfig.passageRetries,
      dryRun: referenceConfig.passageDryRun,
      from: null,
      to: null,
      limit: null,
      overwrite: referenceConfig.overwritePassages,
      verbose: referenceConfig.verbose,
      referenceVersification: referenceConfig.referenceVersification,
      psalmMode: referenceConfig.psalmMode,
    });
  }
}

module.exports = {
  ReferenceToPassageConfigBuilder,
};
