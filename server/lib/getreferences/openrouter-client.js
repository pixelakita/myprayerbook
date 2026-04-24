const { Sleep, TextHelper } = require('../shared/utils');

class OpenRouterClient {
  constructor({ apiKey, model, referenceNormalizer, endpointUrl, logEnabled = false }) {
    this.apiKey = apiKey;
    this.model = model;
    this.referenceNormalizer = referenceNormalizer;
    this.endpointUrl = endpointUrl || 'https://openrouter.ai/api/v1/chat/completions';
    this.logEnabled = logEnabled;
  }

  async fetchMonthReferences({ monthName, year, maxRetries = 3 }) {
    let lastError;

    for (let attempt = 1; attempt <= maxRetries; attempt += 1) {
      try {
        console.log(`[${monthName}] Requesting references (attempt ${attempt}/${maxRetries})...`);
        const parsedMonthData = await this.requestWithJsonObject({ monthName, year });
        const normalized = this.referenceNormalizer.normalizeMonthData(parsedMonthData, monthName, year);
        console.log(`[${monthName}] Received ${normalized.length} day entr${normalized.length === 1 ? 'y' : 'ies'}.`);
        return normalized;
      } catch (error) {
        lastError = error;
        console.error(`[${monthName}] Attempt ${attempt} failed: ${error.message}`);

        if (attempt < maxRetries) {
          await Sleep.for(1500 * attempt);
        }
      }
    }

    throw lastError;
  }

  buildPrompt(monthName, year) {
    return `reply only with the Catholic bible reading references for ${monthName} ${year}, normalized to RSV-2CE chapter and verse numbering, in JSON format of the following:

{
  "items": [
    {
      "date": string,
      "reading_1": string,
      "psalms": string,
      "reading_2": string,
      "gospel": string
    }
  ]
}

Rules:
- Return one object per calendar date in ${monthName} ${year}.
- Use ISO date format YYYY-MM-DD for the date field.
- Book names should be abbreviated (example, Mt, Lk, Ps).
- Use an empty string for reading_2 when there is no second reading.
- Normalize all references to RSV-2CE chapter and verse numbering before output.
- If source numbering differs, convert it to RSV-2CE before output.
- For Psalms, use RSV-2CE numbering only.
- If a date has a full alternate set of readings, return it under a variants object using the same fields: reading_1, psalms, reading_2, gospel.
- Output valid JSON only.
- Do not include markdown, commentary, explanations, or code fences.`;
  }

  unwrapItems(payload, monthName, year) {
    if (Array.isArray(payload)) return payload;
    if (payload && Array.isArray(payload.items)) return payload.items;
    throw new Error(`${monthName} ${year}: model did not return an array or an object with an 'items' array.`);
  }

  logDivider(label) {
    if (!this.logEnabled) return;
    console.log(`========== ${label} ==========`);
  }

  async requestWithJsonObject({ monthName, year }) {
    const payload = {
      model: this.model,
      temperature: 0,
      max_completion_tokens: 12000,
      messages: [
        { role: 'system', content: 'You output only valid JSON and nothing else.' },
        { role: 'user', content: this.buildPrompt(monthName, year) },
      ],
      response_format: { type: 'json_object' },
    };

    if (this.logEnabled) {
      this.logDivider(`${monthName} REQUEST`);
      console.log(JSON.stringify(payload, null, 2));
    }

    const response = await fetch(this.endpointUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://local.cli.app',
        'X-OpenRouter-Title': 'Bible Readings Generator',
      },
      body: JSON.stringify(payload),
    });

    const text = await response.text();

    if (this.logEnabled) {
      this.logDivider(`${monthName} RAW RESPONSE STATUS`);
      console.log(response.status);
      this.logDivider(`${monthName} RAW RESPONSE BODY`);
      console.log(text);
    }

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${text}`);
    }

    let parsedResponse;
    try {
      parsedResponse = JSON.parse(text);
    } catch (error) {
      throw new Error(`Failed to parse OpenRouter response JSON: ${error.message}
Raw response:
${text}`);
    }

    const message = parsedResponse?.choices?.[0]?.message;
    const content = TextHelper.extractMessageText(message).replace(/—/g, '-');

    if (this.logEnabled) {
      this.logDivider(`${monthName} EXTRACTED CONTENT`);
      console.log(content);
    }

    if (!content || !content.trim()) {
      throw new Error(`Model returned empty content for ${monthName} ${year}. Full response:
${text}`);
    }

    let parsedMonthData;
    try {
      parsedMonthData = JSON.parse(TextHelper.stripMarkdownCodeFence(content));
    } catch (error) {
      throw new Error(`Failed to parse model JSON for ${monthName} ${year}: ${error.message}
Model content:
${content}`);
    }

    if (this.logEnabled) {
      this.logDivider(`${monthName} PARSED JSON`);
      console.log(JSON.stringify(parsedMonthData, null, 2));
    }

    return this.unwrapItems(parsedMonthData, monthName, year);
  }
}

module.exports = {
  OpenRouterClient,
};
