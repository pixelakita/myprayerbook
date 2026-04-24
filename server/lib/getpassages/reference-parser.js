const { TextHelper } = require('../shared/utils');

const BOOK_ALIASES = {
  'Gn': { fullName: 'Genesis' },
  'Gen': { fullName: 'Genesis' },
  'Genesis': { fullName: 'Genesis' },
  'Ex': { fullName: 'Exodus' },
  'Exodus': { fullName: 'Exodus' },
  'Lv': { fullName: 'Leviticus' },
  'Leviticus': { fullName: 'Leviticus' },
  'Nm': { fullName: 'Numbers' },
  'Numbers': { fullName: 'Numbers' },
  'Dt': { fullName: 'Deuteronomy' },
  'Deuteronomy': { fullName: 'Deuteronomy' },
  'Jgs': { fullName: 'Judges' },
  'Judges': { fullName: 'Judges' },
  'Ruth': { fullName: 'Ruth' },
  '1 Sm': { fullName: '1 Samuel' },
  '1 Samuel': { fullName: '1 Samuel' },
  '2 Sm': { fullName: '2 Samuel' },
  '2 Samuel': { fullName: '2 Samuel' },
  '1 Kgs': { fullName: '1 Kings' },
  '1 Kings': { fullName: '1 Kings' },
  '2 Kgs': { fullName: '2 Kings' },
  '2 Kings': { fullName: '2 Kings' },
  '1 Chr': { fullName: '1 Chronicles' },
  '1 Chronicles': { fullName: '1 Chronicles' },
  '2 Chr': { fullName: '2 Chronicles' },
  '2 Chronicles': { fullName: '2 Chronicles' },
  'Est': { fullName: 'Esther' },
  'Esther': { fullName: 'Esther' },
  'Jdt': { fullName: 'Judith' },
  'Judith': { fullName: 'Judith' },
  'Jb': { fullName: 'Job' },
  'Job': { fullName: 'Job' },
  'Ps': { fullName: 'Psalms' },
  'Psalm': { fullName: 'Psalms' },
  'Psalms': { fullName: 'Psalms' },
  'Prv': { fullName: 'Proverbs' },
  'Proverbs': { fullName: 'Proverbs' },
  'Eccl': { fullName: 'Ecclesiastes' },
  'Ecclesiastes': { fullName: 'Ecclesiastes' },
  'Song': { fullName: 'Song of Solomon' },
  'Song of Solomon': { fullName: 'Song of Solomon' },
  'Wis': { fullName: 'Wisdom' },
  'Wisdom': { fullName: 'Wisdom' },
  'Sir': { fullName: 'Sirach' },
  'Sirach': { fullName: 'Sirach' },
  'Is': { fullName: 'Isaiah' },
  'Isaiah': { fullName: 'Isaiah' },
  'Jer': { fullName: 'Jeremiah' },
  'Jeremiah': { fullName: 'Jeremiah' },
  'Lam': { fullName: 'Lamentations' },
  'Lamentations': { fullName: 'Lamentations' },
  'Bar': { fullName: 'Baruch' },
  'Baruch': { fullName: 'Baruch' },
  'Ez': { fullName: 'Ezekiel' },
  'Ezekiel': { fullName: 'Ezekiel' },
  'Dn': { fullName: 'Daniel' },
  'Daniel': { fullName: 'Daniel' },
  'Hos': { fullName: 'Hosea' },
  'Hosea': { fullName: 'Hosea' },
  'Jl': { fullName: 'Joel' },
  'Joel': { fullName: 'Joel' },
  'Am': { fullName: 'Amos' },
  'Amos': { fullName: 'Amos' },
  'Jon': { fullName: 'Jonah' },
  'Jonah': { fullName: 'Jonah' },
  'Mi': { fullName: 'Micah' },
  'Micah': { fullName: 'Micah' },
  'Na': { fullName: 'Nahum' },
  'Nahum': { fullName: 'Nahum' },
  'Hb': { fullName: 'Habakkuk' },
  'Habakkuk': { fullName: 'Habakkuk' },
  'Zep': { fullName: 'Zephaniah' },
  'Zephaniah': { fullName: 'Zephaniah' },
  'Zec': { fullName: 'Zechariah' },
  'Zechariah': { fullName: 'Zechariah' },
  'Mal': { fullName: 'Malachi' },
  'Malachi': { fullName: 'Malachi' },
  'Mt': { fullName: 'Matthew' },
  'Matthew': { fullName: 'Matthew' },
  'Mk': { fullName: 'Mark' },
  'Mark': { fullName: 'Mark' },
  'Lk': { fullName: 'Luke' },
  'Luke': { fullName: 'Luke' },
  'Jn': { fullName: 'John' },
  'John': { fullName: 'John' },
  'Acts': { fullName: 'Acts' },
  'Rom': { fullName: 'Romans' },
  'Rm': { fullName: 'Romans' },
  'Romans': { fullName: 'Romans' },
  '1 Cor': { fullName: '1 Corinthians' },
  '1 Corinthians': { fullName: '1 Corinthians' },
  '2 Cor': { fullName: '2 Corinthians' },
  '2 Corinthians': { fullName: '2 Corinthians' },
  'Gal': { fullName: 'Galatians' },
  'Galatians': { fullName: 'Galatians' },
  'Eph': { fullName: 'Ephesians' },
  'Ephesians': { fullName: 'Ephesians' },
  'Phil': { fullName: 'Philippians' },
  'Philippians': { fullName: 'Philippians' },
  'Col': { fullName: 'Colossians' },
  'Colossians': { fullName: 'Colossians' },
  '1 Thes': { fullName: '1 Thessalonians' },
  '1 Thessalonians': { fullName: '1 Thessalonians' },
  '2 Thes': { fullName: '2 Thessalonians' },
  '2 Thessalonians': { fullName: '2 Thessalonians' },
  '1 Tm': { fullName: '1 Timothy' },
  '1 Timothy': { fullName: '1 Timothy' },
  '2 Tm': { fullName: '2 Timothy' },
  '2 Timothy': { fullName: '2 Timothy' },
  'Ti': { fullName: 'Titus' },
  'Titus': { fullName: 'Titus' },
  'Phlm': { fullName: 'Philemon' },
  'Philemon': { fullName: 'Philemon' },
  'Heb': { fullName: 'Hebrews' },
  'Hebrews': { fullName: 'Hebrews' },
  'Jas': { fullName: 'James' },
  'James': { fullName: 'James' },
  '1 Pt': { fullName: '1 Peter' },
  '1 Peter': { fullName: '1 Peter' },
  '2 Pt': { fullName: '2 Peter' },
  '2 Peter': { fullName: '2 Peter' },
  '1 Jn': { fullName: '1 John' },
  '1 John': { fullName: '1 John' },
  '2 Jn': { fullName: '2 John' },
  '2 John': { fullName: '2 John' },
  '3 Jn': { fullName: '3 John' },
  '3 John': { fullName: '3 John' },
  'Jude': { fullName: 'Jude' },
  'Rv': { fullName: 'Revelation' },
  'Revelation': { fullName: 'Revelation' },
};

class BibleReferenceParser {
  constructor({ referenceConverter = null } = {}) {
    this.bookAliases = BOOK_ALIASES;
    this.bookKeys = Object.keys(this.bookAliases).sort((a, b) => b.length - a.length);
    this.referenceConverter = referenceConverter;
  }

  expandFieldValue(value) {
    if (value == null || value === '') {
      return [];
    }

    if (Array.isArray(value)) {
      return value.flatMap((item, index) => {
        const built = this.buildQueriesFromString(item);
        return built.map((query) => ({ ...query, sequence: index + 1 }));
      });
    }

    return this.buildQueriesFromString(value);
  }

  buildQueriesFromString(value) {
    const sourceValue = String(value);
    const preprocessed = this.preprocessReference(value);
    const alternatives = this.splitAlternativeChunks(preprocessed);
    const queries = [];
    let lastBookKey = null;
    let lastChapter = null;

    alternatives.forEach((alternativeText, altIndex) => {
      const labeledSegments = this.splitLabeledChunks(alternativeText);

      labeledSegments.forEach(({ label, text }) => {
        const parts = text.split(/\s*;\s*/g).map((item) => item.trim()).filter(Boolean);

        parts.forEach((part, partIndex) => {
          const built = this.buildReferenceQuery(part, { lastBookKey, lastChapter, sourceValue });
          lastBookKey = built.bookKey;
          if (built.chapter != null) {
            lastChapter = built.chapter;
          }
          queries.push({
            label,
            option: alternatives.length > 1 ? altIndex + 1 : null,
            segment: parts.length > 1 ? partIndex + 1 : null,
            originalText: sourceValue,
            ...built,
          });
        });
      });
    });

    return queries;
  }

  preprocessReference(rawValue) {
    let value = String(rawValue ?? '').trim();
    value = value.replace(/[’]/g, "'");
    value = value.replace(/^=\s*/, '');
    value = value.replace(/\s*:\s*/g, ':');
    value = value.replace(/([A-Za-z])(\d+:\d)/g, '$1 $2');
    value = value.replace(/\s+,/g, ',');
    value = value.replace(/,\s*,+/g, ', ');
    value = value.replace(/\s+and\s+/gi, ', ');
    value = value.replace(/\s+or,\s*([^,]+),\s*(?=(?:[1-3]\s*)?[A-Za-z])/gi, ' || $1: ');
    value = TextHelper.normalizeWhitespace(value);
    value = value.replace(/,\s*$/, '');
    value = value.replace(/\s+-\s+/g, '-');
    return value;
  }

  splitAlternativeChunks(input) {
    const primary = input.split(/\s*\|\|\s*/g).filter(Boolean);
    const result = [];
    const splitter = /\s+or\s+(?=(?:(?:[1-3]\s*)?[A-Za-z][A-Za-z]+(?:\s+[A-Za-z][A-Za-z]+)?\s+\d|\d+:))/i;

    for (const part of primary) {
      result.push(...part.split(splitter).map((item) => item.trim()).filter(Boolean));
    }

    return result;
  }

  splitLabeledChunks(input) {
    const chunks = input
      .split(/,\s*(?=[A-Za-z][^:]{1,80}:\s*(?:(?:[1-3]\s*)?[A-Za-z][A-Za-z]+(?:\s+[A-Za-z][A-Za-z]+)?\s+\d|\d+:))/g)
      .map((item) => item.trim())
      .filter(Boolean);

    return chunks.map((chunk) => {
      if (this.extractBookAndRest(chunk)) {
        return { label: null, text: chunk };
      }

      const match = chunk.match(/^([^:]{1,80}?):\s*(.+)$/);
      if (!match) {
        return { label: null, text: chunk };
      }

      const label = match[1].trim();
      const text = match[2].trim();

      if (this.bookAliases[label]) {
        return { label: null, text: chunk };
      }

      return { label, text };
    });
  }

  extractBookAndRest(part) {
    const trimmed = part.trim();
    const lower = trimmed.toLowerCase();

    for (const key of this.bookKeys) {
      const normalizedKey = key.toLowerCase();
      if (lower === normalizedKey) {
        return { bookKey: key, rest: '' };
      }
      if (lower.startsWith(`${normalizedKey} `)) {
        return { bookKey: key, rest: trimmed.slice(key.length).trim() };
      }
      if (lower.startsWith(normalizedKey) && /\d/.test(trimmed.charAt(key.length))) {
        return { bookKey: key, rest: trimmed.slice(key.length).trim() };
      }
    }

    return null;
  }

  isVerseOnlySegment(text) {
    return /^\d+[a-z]?(?:\s*-\s*\d+[a-z]?)?(?:\s*,\s*\d+[a-z]?(?:\s*-\s*\d+[a-z]?)?)*$/i.test(
      String(text || '').trim()
    );
  }

  inferNearestContextFromSourceValue(part, sourceValue) {
    const source = this.preprocessReference(sourceValue);
    const target = this.preprocessReference(part);
    const targetIndex = source.indexOf(target);
    const limit = targetIndex >= 0 ? targetIndex : source.length;

    let best = null;

    for (const key of this.bookKeys) {
      const escaped = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const regex = new RegExp(`(?:^|[\\s,(;])(${escaped})\\s+(\\d+):`, 'gi');
      let match;
      while ((match = regex.exec(source)) !== null) {
        if (match.index > limit) {
          break;
        }
        best = {
          bookKey: key,
          chapter: Number(match[2]),
          index: match.index,
        };
      }
    }

    if (!best) {
      const extracted = this.extractBookAndRest(source);
      if (!extracted) {
        return null;
      }
      const chapterMatch = extracted.rest.match(/^(\d+):/);
      return {
        bookKey: extracted.bookKey,
        chapter: chapterMatch ? Number(chapterMatch[1]) : null,
      };
    }

    return {
      bookKey: best.bookKey,
      chapter: best.chapter,
    };
  }

  buildReferenceQuery(part, context = {}) {
    const warnings = [];
    const cleaned = this.preprocessReference(part);
    const { bookKey, inheritedChapter, rest } = this.resolveBookContext(part, cleaned, context, warnings);
    const normalizedRest = this.normalizeReferenceRest(rest, inheritedChapter, warnings);
    const chapter = this.extractChapter(normalizedRest);
    const conversion = this.applyReferenceConversion(bookKey, normalizedRest);
    const bookFullName = this.getBookFullName(bookKey);

    return {
      bookKey,
      chapter,
      original: part,
      normalizedQuery: `${bookFullName} ${conversion.rest}`.trim(),
      fallbackQuery: `${bookFullName} ${normalizedRest}`.trim(),
      warnings: [...warnings, ...conversion.warnings],
      conversionRuleIds: conversion.ruleIds,
    };
  }

  resolveBookContext(part, cleaned, context, warnings) {
    const extracted = this.extractBookAndRest(cleaned);
    const inferredContext = context.sourceValue
      ? this.inferNearestContextFromSourceValue(part, context.sourceValue)
      : null;

    let bookKey = context.lastBookKey ?? inferredContext?.bookKey ?? null;
    const inheritedChapter = context.lastChapter ?? inferredContext?.chapter ?? null;
    let rest = cleaned;

    if (extracted) {
      bookKey = extracted.bookKey;
      rest = extracted.rest;
    } else if (!bookKey && this.isVerseOnlySegment(cleaned) && inferredContext?.bookKey) {
      bookKey = inferredContext.bookKey;
      warnings.push(`Recovered book '${this.getBookFullName(bookKey)}' from source context.`);
    } else if (!bookKey) {
      throw new Error(`Unable to determine the book for reference segment: ${part}`);
    } else {
      warnings.push(`Inherited book '${this.getBookFullName(bookKey)}' from previous segment.`);
    }

    if (!rest) {
      throw new Error(`Missing chapter/verse information in reference segment: ${part}`);
    }

    return { bookKey, inheritedChapter, rest };
  }

  normalizeReferenceRest(rest, inheritedChapter, warnings) {
    const stripped = this.stripVersePartLetters(rest);
    if (stripped.changed) {
      warnings.push('Removed liturgical verse-part markers like a/b/c for bible-api compatibility.');
    }

    let normalized = stripped.value.trim();

    if (!normalized.includes(':') && inheritedChapter != null && this.isVerseOnlySegment(normalized)) {
      normalized = `${inheritedChapter}:${normalized}`;
      warnings.push(`Inherited chapter '${inheritedChapter}' from previous segment.`);
    }

    normalized = normalized.replace(/\s+and\s+/gi, ', ');
    normalized = normalized.replace(/\s*,\s*/g, ', ');
    normalized = normalized.replace(/\s*;\s*/g, '; ');
    normalized = normalized.replace(/,\s*$/, '');
    return TextHelper.normalizeWhitespace(normalized);
  }

  extractChapter(rest) {
    const chapterMatch = rest.match(/^(\d+):/);
    return chapterMatch ? Number(chapterMatch[1]) : null;
  }

  applyReferenceConversion(bookKey, rest) {
    if (!this.referenceConverter) {
      return { rest, warnings: [], ruleIds: [] };
    }

    const conversion = this.referenceConverter.convert(this.getBookFullName(bookKey), rest);
    return {
      rest: conversion.rest,
      warnings: Array.isArray(conversion.warnings) ? conversion.warnings : [],
      ruleIds: Array.isArray(conversion.ruleIds) ? conversion.ruleIds : [],
    };
  }

  getBookFullName(bookKey) {
    return this.bookAliases[bookKey].fullName;
  }

  stripVersePartLetters(spec) {
    let changed = false;
    const next = spec.replace(/(\d+)([a-z]+)(?=(?:\s*[-,;]|$))/gi, (_, digits, suffix) => {
      changed = changed || suffix.length > 0;
      return digits;
    });

    return { value: next, changed };
  }
}

module.exports = {
  BibleReferenceParser,
};
