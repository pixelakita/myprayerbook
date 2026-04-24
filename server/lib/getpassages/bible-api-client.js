const { Sleep } = require('../shared/utils');

class BibleApiClient {
  constructor({ translation, delayMs, retries, dryRun, logEnabled = false }) {
    this.translation = translation;
    this.delayMs = delayMs;
    this.retries = retries;
    this.dryRun = dryRun;
    this.cache = new Map();
    this.lastRequestStartedAt = 0;
    this.logEnabled = logEnabled;
  }

  async fetchPassage(query, fallbackQuery = null) {
    const cacheKey = `${this.translation}::${query}`;
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    if (this.dryRun) {
      const payload = {
        requested_query: query,
        fallback_query: fallbackQuery,
        translation_id: this.translation,
        dry_run: true,
      };
      this.cache.set(cacheKey, payload);
      return payload;
    }

    const candidates = [query, fallbackQuery].filter((item, index, array) => item && array.indexOf(item) === index);
    let lastError = null;

    for (const candidate of candidates) {
      try {
        const json = await this.request(candidate);
        const result = {
          requested_query: candidate,
          translation_id: json.translation_id,
          translation_name: json.translation_name,
          translation_note: json.translation_note,
          reference: json.reference,
          text: (json.text ?? '').trim(),
          verses: Array.isArray(json.verses) ? json.verses : null,
        };
        this.cache.set(cacheKey, result);
        return result;
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? new Error(`Failed to fetch passage for query: ${query}`);
  }

  async request(query) {
    let attempt = 0;

    while (attempt < this.retries) {
      attempt += 1;
      await this.waitForTurn();

      const url = `https://bible-api.com/${encodeURIComponent(query)}?translation=${encodeURIComponent(this.translation)}`;
      
      if (this.logEnabled) {
        console.log('========== BIBLE-API REQUEST ==========' );
        console.log(url);
      }

      try {
        const response = await fetch(url, {
          headers: { accept: 'application/json' },
        });

        if (!response.ok) {
          const bodyText = await response.text();
          
          if (this.logEnabled) {
            console.log('========== BIBLE-API RAW RESPONSE STATUS ==========' );
            console.log(response.status);
            console.log('========== BIBLE-API RAW RESPONSE BODY ==========' );
            console.log(bodyText);
          }

          const retriable = response.status === 429 || response.status >= 500;
          if (retriable && attempt < this.retries) {
            await Sleep.for(this.delayMs * attempt);
            continue;
          }
          throw new Error(`HTTP ${response.status} for ${query}: ${bodyText}`);
        }

        const json = await response.json();
        if (this.logEnabled) {
          console.log('========== BIBLE-API RAW RESPONSE STATUS ==========' );
          console.log(response.status);
          console.log('========== BIBLE-API PARSED RESPONSE ==========' );
          console.log(JSON.stringify(json, null, 2));
        }
        return json;
      } catch (error) {
        console.error(error);
        process.exit(1)
        if (attempt >= this.retries) {
          throw error;
        }
        await Sleep.for(this.delayMs * attempt);
      }
    }

    throw new Error(`Exhausted retries for query: ${query}`);
  }

  async waitForTurn() {
    const now = Date.now();
    const elapsed = now - this.lastRequestStartedAt;
    const waitFor = Math.max(0, this.delayMs - elapsed);
    if (waitFor > 0) {
      await Sleep.for(waitFor);
    }
    this.lastRequestStartedAt = Date.now();
  }
}

module.exports = {
  BibleApiClient,
};
