#!/usr/bin/env node
const { PassageAppFactory } = require('./lib/factories/passage-app-factory');

async function main() {
  const app = PassageAppFactory.create(process.argv.slice(2));
  await app.run();
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack : error);
  process.exit(1);
});
