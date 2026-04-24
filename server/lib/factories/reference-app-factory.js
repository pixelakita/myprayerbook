const { ReferenceConfigParser } = require('../getreferences/reference-config');
const { ReferenceNormalizer } = require('../getreferences/reference-normalizer');
const { OpenRouterClient } = require('../getreferences/openrouter-client');
const { ReferenceWriter } = require('../getreferences/reference-writer');
const { ReferenceGenerationApp } = require('../getreferences/reference-app');
const { DataPathLayout } = require('../shared/data-path-layout');

class ReferenceAppFactory {
  static create(argv = process.argv.slice(2)) {
    const config = new ReferenceConfigParser().parse(argv);
    const dataPathLayout = new DataPathLayout(config.outputDir);
    const referenceNormalizer = new ReferenceNormalizer();
    const openRouterClient = new OpenRouterClient({
      apiKey: config.apiKey,
      model: config.model,
      referenceNormalizer,
      endpointUrl: config.endpointUrl,
      logEnabled: config.verbose,
    });
    const referenceWriter = new ReferenceWriter({ dataPathLayout });
    return new ReferenceGenerationApp({ config, openRouterClient, referenceWriter, dataPathLayout });
  }
}

module.exports = { ReferenceAppFactory };
