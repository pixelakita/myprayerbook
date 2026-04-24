const path = require('path');
const process = require('process');
const {
  DEFAULT_REFERENCE_VERSIFICATION,
  DEFAULT_PSALM_MODE,
  assertValidReferenceOptions,
} = require('../shared/reference-versification');

class PassageConfig {
  constructor(values) {
    Object.assign(this, values);
  }
}

class PassageConfigParser {
  parse(argv) {
    const raw = {
      input: null,
      year: null,
      dataDir: path.resolve(process.cwd(), 'data'),
      translation: 'web',
      delayMs: 2100,
      retries: 3,
      dryRun: false,
      from: null,
      to: null,
      limit: null,
      overwrite: false,
      verbose: false,
      referenceVersification: DEFAULT_REFERENCE_VERSIFICATION,
      psalmMode: DEFAULT_PSALM_MODE,
    };

    for (let i = 0; i < argv.length; i += 1) {
      const token = argv[i];
      const next = argv[i + 1];

      switch (token) {
        case '--input':
        case '-i':
          raw.input = path.resolve(process.cwd(), next);
          i += 1;
          break;
        case '--year':
        case '-y':
          raw.year = Number(next);
          i += 1;
          break;
        case '--data-dir':
        case '-d':
          raw.dataDir = path.resolve(process.cwd(), next);
          i += 1;
          break;
        case '--translation':
        case '-t':
          raw.translation = next;
          i += 1;
          break;
        case '--delay-ms':
          raw.delayMs = Number(next);
          i += 1;
          break;
        case '--retries':
          raw.retries = Number(next);
          i += 1;
          break;
        case '--from':
          raw.from = next;
          i += 1;
          break;
        case '--to':
          raw.to = next;
          i += 1;
          break;
        case '--limit':
          raw.limit = Number(next);
          i += 1;
          break;
        case '--overwrite':
          raw.overwrite = true;
          break;
        case '--dry-run':
          raw.dryRun = true;
          break;
        case '--verbose':
          raw.verbose = true;
          break;
        case '--reference-versification':
          raw.referenceVersification = String(next || '').trim() || 'none';
          i += 1;
          break;
        case '--psalm-mode':
          raw.psalmMode = String(next || '').trim() || 'disabled';
          i += 1;
          break;
        case '--help':
        case '-h':
          this.printHelp();
          process.exit(0);
          break;
        default:
          if (token.startsWith('-')) {
            throw new Error(`Unknown argument: ${token}`);
          }
      }
    }

    this.validate(raw);
    return new PassageConfig(raw);
  }

  validate(raw) {
    if (!raw.input && (!Number.isInteger(raw.year) || String(raw.year).length !== 4)) {
      throw new Error('Pass either --input <reference-file> or --year <yyyy>.');
    }

    assertValidReferenceOptions(raw);
  }

  printHelp() {
    console.log(
`getpassages.js

Usage:
  node getpassages.js --year 2026 [options]
  node getpassages.js --input ./data/2026/references.json [options]

Options:
  --year, -y         Process reference data under ./data/<year>
  --input, -i        Process one reference JSON file (annual array or legacy daily object)
  --data-dir, -d     Base data directory (default: ./data)
  --translation, -t  bible-api translation id (default: web)
  --delay-ms         Minimum delay between HTTP requests (default: 2100)
  --retries          Retry count per request (default: 3)
  --from             Inclusive start date, e.g. 2026-01-01
  --to               Inclusive end date, e.g. 2026-12-31
  --limit            Process only the first N matching entries
  --overwrite        Overwrite matching entries inside ./data/<year>/gospels.json
  --dry-run          Parse references without calling bible-api
  --verbose          Log internal OpenRouter / bible-api requests and responses
  --reference-versification  Reference conversion mode: jb-to-webc or none (default: ${DEFAULT_REFERENCE_VERSIFICATION})
  --psalm-mode       Psalm conversion mode: disabled or jb_counts_superscription_as_v1 (default: ${DEFAULT_PSALM_MODE})
  --help, -h         Show this help
`
    );
  }
}

module.exports = {
  PassageConfig,
  PassageConfigParser,
};
