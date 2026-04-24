const { DataPathLayout } = require('../shared/data-path-layout');
const { PassageConfigParser, PassageConfig } = require('../getpassages/passage-config');
const { ReferenceFileLocator, ReferenceFileReader } = require('../getpassages/reference-library');
const { BibleReferenceParser } = require('../getpassages/reference-parser');
const { JerusalemToWebcReferenceConverter } = require('../getpassages/reference-converter');
const { BibleApiClient } = require('../getpassages/bible-api-client');
const { PassageFieldProcessor, PassageEntryProcessor, ReadingFileWriter } = require('../getpassages/passage-generator');
const { PassageGenerationApp } = require('../getpassages/passage-app');
const { ReferenceToPassageConfigBuilder } = require('../pipeline/pipeline-config');
const { REFERENCE_VERSIFICATION } = require('../shared/reference-versification');

const DEFAULT_FIELDS = ['reading_1', 'psalms', 'reading_2', 'gospel'];

class PassageAppFactory {
  static create(input = process.argv.slice(2), { fields = DEFAULT_FIELDS } = {}) {
    const config = Array.isArray(input)
      ? new PassageConfigParser().parse(input)
      : input instanceof PassageConfig
        ? input
        : new ReferenceToPassageConfigBuilder().build(input);

    const dataPathLayout = new DataPathLayout(config.dataDir);
    const bibleApiClient = new BibleApiClient({
      translation: config.translation,
      delayMs: config.delayMs,
      retries: config.retries,
      dryRun: config.dryRun,
      logEnabled: config.verbose,
    });

    return new PassageGenerationApp({
      config,
      fileLocator: new ReferenceFileLocator({ dataDir: config.dataDir, dataPathLayout }),
      fileReader: new ReferenceFileReader(),
      entryProcessor: new PassageEntryProcessor({
        fieldProcessor: new PassageFieldProcessor({
          referenceParser: new BibleReferenceParser({
            referenceConverter: new JerusalemToWebcReferenceConverter({
              enabled: config.referenceVersification === REFERENCE_VERSIFICATION.JB_TO_WEBC,
              psalmMode: config.psalmMode,
            }),
          }),
          bibleApiClient,
        }),
        dataPathLayout,
        translation: config.translation,
        fields,
      }),
      fileWriter: new ReadingFileWriter({ dataPathLayout }),
      dataPathLayout,
    });
  }
}

module.exports = { PassageAppFactory, DEFAULT_FIELDS };
