const path = require('path');
const process = require('process');
const {
  DEFAULT_REFERENCE_VERSIFICATION,
  DEFAULT_PSALM_MODE,
  assertValidReferenceOptions,
} = require('../shared/reference-versification');

const DEFAULT_MODEL = 'openai/gpt-5.4';
const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class ReferenceConfig {
  constructor(values) {
    Object.assign(this, values);
  }

  getMonthName(monthNumber) {
    return MONTH_NAMES[monthNumber - 1];
  }
}

class ReferenceConfigParser {
  constructor({ defaultModel = DEFAULT_MODEL } = {}) {
    this.defaultModel = defaultModel;
  }

  parse(argv) {
    const raw = {
      year: null,
      apiKey: process.env.OPENROUTER_API_KEY || '',
      model: this.defaultModel,
      endpointUrl: 'https://openrouter.ai/api/v1/chat/completions',
      outputDir: path.resolve(process.cwd(), 'data'),
      months: null,
      overwrite: false,
      referencesOnly: false,
      passageTranslation: 'web',
      passageDelayMs: 2100,
      passageRetries: 3,
      passageDryRun: false,
      overwritePassages: false,
      verbose: false,
      referenceVersification: DEFAULT_REFERENCE_VERSIFICATION,
      psalmMode: DEFAULT_PSALM_MODE,
    };

    for (let i = 0; i < argv.length; i += 1) {
      const token = argv[i];
      const next = argv[i + 1];

      switch (token) {
        case '--year':
        case '-y':
          raw.year = Number(next);
          i += 1;
          break;
        case '--apiKey':
        case '--api-key':
          raw.apiKey = next;
          i += 1;
          break;
        case '--model':
        case '-m':
          raw.model = next;
          i += 1;
          break;
        case '--endpoint-url':
          raw.endpointUrl = next;
          i += 1;
          break;
        case '--output-dir':
        case '-o':
          raw.outputDir = path.resolve(process.cwd(), next);
          i += 1;
          break;
        case '--months':
          raw.months = this.parseMonths(next);
          i += 1;
          break;
        case '--overwrite':
          raw.overwrite = true;
          break;
        case '--references-only':
          raw.referencesOnly = true;
          break;
        case '--translation':
        case '-t':
          raw.passageTranslation = next;
          i += 1;
          break;
        case '--delay-ms':
          raw.passageDelayMs = Number(next);
          i += 1;
          break;
        case '--retries':
          raw.passageRetries = Number(next);
          i += 1;
          break;
        case '--dry-run-passages':
          raw.passageDryRun = true;
          break;
        case '--overwrite-passages':
          raw.overwritePassages = true;
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
    if (!raw.months) {
      raw.months = MONTH_NAMES.map((_, index) => index + 1);
    }
    return new ReferenceConfig(raw);
  }

  parseMonths(value) {
    const months = String(value)
      .split(',')
      .map((item) => Number(item.trim()))
      .filter((item) => Number.isInteger(item) && item >= 1 && item <= 12);

    if (months.length === 0) {
      throw new Error('Invalid --months value. Example: --months 1,2,12');
    }

    return Array.from(new Set(months)).sort((a, b) => a - b);
  }

  validate(raw) {
    if (!Number.isInteger(raw.year) || String(raw.year).length !== 4) {
      throw new Error('Missing or invalid --year. Example: --year 2026');
    }

    if (!raw.apiKey || !String(raw.apiKey).trim()) {
      throw new Error('Missing OpenRouter API key. Pass --apiKey or set OPENROUTER_API_KEY.');
    }

    assertValidReferenceOptions(raw);
  }

  printHelp() {
    console.log(`getreferences.js

Usage:
  node getreferences.js --year 2026 [options]

Options:
  --year, -y         Year to generate, e.g. 2026
  --apiKey           OpenRouter API key (or set OPENROUTER_API_KEY)
  --model, -m        OpenRouter model (default: ${this.defaultModel})
  --output-dir, -o   Base data directory (default: ./data)
  --months           Comma-separated month numbers, e.g. 1,2,12
  --overwrite        Overwrite matching dates inside ./data/<year>/references.json
  --references-only  Generate references.json only and skip passage downloads
  --translation, -t  bible-api translation id used by the connected passage step (default: web)
  --delay-ms         Minimum delay between bible-api requests (default: 2100)
  --retries          Retry count per bible-api request (default: 3)
  --dry-run-passages Parse references without calling bible-api during the connected passage step
  --overwrite-passages  Overwrite matching dates inside ./data/<year>/gospels.json
  --verbose          Log internal OpenRouter / bible-api requests and responses
  --reference-versification  Reference conversion mode: jb-to-webc or none (default: ${DEFAULT_REFERENCE_VERSIFICATION})
  --psalm-mode       Psalm conversion mode: disabled or jb_counts_superscription_as_v1 (default: ${DEFAULT_PSALM_MODE})
  --help, -h         Show this help
`);
  }
}

module.exports = {
  ReferenceConfig,
  ReferenceConfigParser,
  DEFAULT_MODEL,
};
