class ReferenceNormalizer {
  normalizeMonthData(data, monthName, year) {
    if (!Array.isArray(data)) {
      throw new Error(`${monthName} ${year}: model did not return an array.`);
    }

    return data.map((row) => {
      const normalized = this.normalizeRow(row);
      this.validateRow(normalized, monthName, year);
      return {
        date: normalized.date,
        gospel: normalized.gospel
      };
    });
  }

  normalizeRow(row) {
    const normalized = {
      date: this.normalizeString(row?.date),
    };

    const baseFields = this.normalizeReadingFields(row);

    if (this.hasUsableVariants(row?.variants)) {
      const normalizedVariants = {};
      for (const [variantName, variantValue] of Object.entries(row.variants)) {
        normalizedVariants[variantName] = this.normalizeReadingFields(variantValue);
      }

      const completeVariantNames = Object.keys(normalizedVariants).filter((name) =>
        this.isCompleteVariant(normalizedVariants[name])
      );

      const partialVariantNames = Object.keys(normalizedVariants).filter((name) =>
        !this.isCompleteVariant(normalizedVariants[name])
      );

      const looksLikePalmSundayProcession =
        partialVariantNames.some((name) => /procession|entrance/i.test(name)) &&
        this.hasAnyBaseReadings(baseFields);

      if (looksLikePalmSundayProcession) {
        const processionName = partialVariantNames.find((name) => /procession|entrance/i.test(name));
        const procession = normalizedVariants[processionName];

        normalized.reading_1 = this.mergePalmSundayReading1(procession, baseFields.reading_1);
        normalized.psalms = baseFields.psalms;
        normalized.reading_2 = baseFields.reading_2;
        normalized.gospel = baseFields.gospel;
        return normalized;
      }

      if (completeVariantNames.length > 0 && partialVariantNames.length === 0) {
        normalized.variants = {};
        for (const variantName of completeVariantNames) {
          normalized.variants[variantName] = normalizedVariants[variantName];
        }
        return normalized;
      }

      if (this.hasAnyBaseReadings(baseFields)) {
        normalized.reading_1 = baseFields.reading_1;
        normalized.psalms = baseFields.psalms;
        normalized.reading_2 = baseFields.reading_2;
        normalized.gospel = baseFields.gospel;
        return normalized;
      }

      if (completeVariantNames.length > 0) {
        normalized.variants = {};
        for (const variantName of completeVariantNames) {
          normalized.variants[variantName] = normalizedVariants[variantName];
        }
        return normalized;
      }

      normalized.reading_1 = baseFields.reading_1;
      normalized.psalms = baseFields.psalms;
      normalized.reading_2 = baseFields.reading_2;
      normalized.gospel = baseFields.gospel;
      return normalized;
    }

    normalized.reading_1 = baseFields.reading_1;
    normalized.psalms = baseFields.psalms;
    normalized.reading_2 = baseFields.reading_2;
    normalized.gospel = baseFields.gospel;
    return normalized;
  }

  normalizeReadingFields(source) {
    return {
      reading_1: this.normalizeValue(source?.reading_1),
      psalms: this.normalizeValue(source?.psalms),
      reading_2: this.normalizeValue(source?.reading_2),
      gospel: this.normalizeValue(source?.gospel),
    };
  }

  normalizeValue(value) {
    if (Array.isArray(value)) {
      return value.map((item) => this.normalizeValue(item)).filter((item) => item !== '');
    }

    if (typeof value === 'string') {
      return this.normalizeString(value);
    }

    if (value == null) {
      return '';
    }

    return value;
  }

  normalizeString(value) {
    return typeof value === 'string' ? value.trim() : '';
  }

  hasUsableVariants(variants) {
    return !!variants && typeof variants === 'object' && !Array.isArray(variants) && Object.keys(variants).length > 0;
  }

  hasAnyBaseReadings(fields) {
    return this.hasContent(fields.reading_1) || this.hasContent(fields.psalms) || this.hasContent(fields.reading_2) || this.hasContent(fields.gospel);
  }

  hasContent(value) {
    if (Array.isArray(value)) {
      return value.length > 0;
    }
    return typeof value === 'string' ? value.trim() !== '' : !!value;
  }

  isCompleteVariant(variant) {
    return this.hasContent(variant?.reading_1) && this.hasContent(variant?.psalms) && this.hasContent(variant?.gospel);
  }

  mergePalmSundayReading1(processionVariant, baseReading1) {
    const processionReference =
      this.firstNonEmpty(processionVariant?.reading_1, processionVariant?.gospel, processionVariant?.psalms) || '';
    const massReading1 = this.normalizeValue(baseReading1);

    if (typeof massReading1 === 'string' && /procession\s*:/i.test(massReading1)) {
      return massReading1;
    }

    if (typeof massReading1 === 'string' && processionReference) {
      return `Procession: ${processionReference}, Mass: ${massReading1}`;
    }

    if (Array.isArray(massReading1) || !massReading1) {
      return processionReference || massReading1;
    }

    return massReading1;
  }

  firstNonEmpty(...values) {
    for (const value of values) {
      if (Array.isArray(value) && value.length > 0) {
        return value[0];
      }
      if (typeof value === 'string' && value.trim() !== '') {
        return value.trim();
      }
    }
    return '';
  }

  validateRow(row, monthName, year) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(row.date)) {
      throw new Error(`${monthName} ${year}: row is missing a valid ISO date.`);
    }

    if (row.variants) {
      for (const [variantName, variant] of Object.entries(row.variants)) {
        if (!this.isCompleteVariant(variant)) {
          throw new Error(`${monthName} ${year}: variant '${variantName}' is missing required readings for ${row.date}.`);
        }
      }
      return;
    }

    if (!this.hasContent(row.gospel)) {
      throw new Error(`${monthName} ${year}: row is missing required gospel for ${row.date}.`);
    }
  }
}

module.exports = {
  ReferenceNormalizer,
};
