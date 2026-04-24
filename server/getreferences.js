#!/usr/bin/env node
const { ReferenceAppFactory } = require('./lib/factories/reference-app-factory');
const { PassageAppFactory } = require('./lib/factories/passage-app-factory');
const { ConnectedBiblePipelineApp } = require('./lib/pipeline/connected-bible-app');

async function main() {
  const argv = process.argv.slice(2);
  const referenceApp = ReferenceAppFactory.create(argv);
  const passageApp = PassageAppFactory.create(referenceApp.config);
  const pipeline = new ConnectedBiblePipelineApp({
    referenceApp,
    passageApp,
    shouldDownloadPassages: !referenceApp.config.referencesOnly,
  });
  await pipeline.run();
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack : error);
  process.exit(1);
});
