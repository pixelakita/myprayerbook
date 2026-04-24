const { PSALM_MODE } = require('../shared/reference-versification');

const PSALM_BOOKS = ['Psalms', 'Psalm', 'Ps', 'Psa', 'Psm'];
const ESTHER_BOOKS = ['Esther', 'Est', 'Esth'];
const NON_CONVERTIBLE_RESULT = Object.freeze({ changed: false, warnings: [], ruleIds: [] });

const JB_TO_WEBC_RULES = {
  schema: 'jb_to_webc_reference_conversion_v2',
  sourceVersion: 'Jerusalem Bible',
  targetVersion: 'WEBC',
  options: {
    psalmMode: {
      values: Object.values(PSALM_MODE),
      default: PSALM_MODE.JB_COUNTS_SUPERSCRIPTION_AS_V1,
    },
  },
  rules: [
    {
      id: 'joel_3_1_5_to_2_28_32',
      match: { book: ['Joel'], chapter: 3, verse: { min: 1, max: 5 } },
      transform: {
        chapter: { op: 'set', value: 2 },
        verse: { op: 'add', value: 27 },
      },
    },
    {
      id: 'joel_4_x_to_3_x',
      match: { book: ['Joel'], chapter: 4, verse: { min: 1 } },
      transform: {
        chapter: { op: 'add', value: -1 },
        verse: { op: 'identity' },
      },
    },
    {
      id: 'jonah_2_1_to_1_17',
      match: { book: ['Jonah'], chapter: 2, verse: 1 },
      transform: {
        chapter: { op: 'set', value: 1 },
        verse: { op: 'set', value: 17 },
      },
    },
    {
      id: 'jonah_2_2_11_to_2_1_10',
      match: { book: ['Jonah'], chapter: 2, verse: { min: 2, max: 11 } },
      transform: {
        chapter: { op: 'identity' },
        verse: { op: 'add', value: -1 },
      },
    },
    {
      id: 'malachi_3_19_24_to_4_1_6',
      match: { book: ['Malachi'], chapter: 3, verse: { min: 19, max: 24 } },
      transform: {
        chapter: { op: 'set', value: 4 },
        verse: { op: 'add', value: -18 },
      },
    },
    {
      id: 'job_40_25_32_to_41_1_8',
      match: { book: ['Job'], chapter: 40, verse: { min: 25, max: 32 } },
      transform: {
        chapter: { op: 'set', value: 41 },
        verse: { op: 'add', value: -24 },
      },
    },
    {
      id: 'job_41_1_26_to_41_9_34',
      match: { book: ['Job'], chapter: 41, verse: { min: 1, max: 26 } },
      transform: {
        chapter: { op: 'identity' },
        verse: { op: 'add', value: 8 },
      },
    },
  ],
};

class JerusalemToWebcReferenceConverter {
  constructor({ enabled = true, psalmMode = JB_TO_WEBC_RULES.options.psalmMode.default } = {}) {
    this.enabled = enabled;
    this.psalmMode = psalmMode;
  }

  convert(book, rest) {
    if (!this.enabled || !this.looksConvertible(rest)) {
      return this.buildPassthroughResult(rest);
    }

    if (this.isEsther(book)) {
      return this.buildResult({
        rest,
        warnings: ['Esther versification was left unchanged because Greek Esther additions require a dedicated section map.'],
      });
    }

    const { segments } = this.parseCompactReference(rest);
    const converted = segments.map((segment) => this.convertSegment(book, segment));
    const pieces = converted.flatMap((segment) => segment.pieces);
    const warnings = converted.flatMap((segment) => segment.warnings);
    const ruleIds = converted.flatMap((segment) => segment.ruleIds).filter(Boolean);

    if (pieces.length === 0) {
      return this.buildResult({
        rest,
        warnings: warnings.length > 0
          ? warnings
          : ['Reference segment could not be converted into a fetchable bible-api query.'],
        ruleIds,
      });
    }

    const nextRest = this.renderPieces(pieces);
    return this.buildResult({
      rest: nextRest,
      changed: nextRest !== rest,
      warnings,
      ruleIds,
    });
  }

  buildPassthroughResult(rest) {
    return this.buildResult({ rest });
  }

  buildResult({ rest, changed = false, warnings = [], ruleIds = [] }) {
    return {
      rest,
      changed,
      warnings,
      ruleIds,
    };
  }

  looksConvertible(rest) {
    return /^\d+:\s*[\da-z,\-\s]+$/i.test(String(rest || '').trim());
  }

  parseCompactReference(rest) {
    const input = String(rest || '').trim();
    const match = input.match(/^(\d+):\s*(.+)$/);
    if (!match) {
      throw new Error(`Could not parse chapter/verse reference: ${rest}`);
    }

    const chapter = Number(match[1]);
    const rawSegments = match[2].trim().split(',').map((item) => item.trim()).filter(Boolean);

    if (rawSegments.length === 0) {
      throw new Error(`No verse segments found in: ${rest}`);
    }

    return {
      chapter,
      segments: rawSegments.map((segmentText) => this.parseSegment(segmentText, chapter)),
    };
  }

  parseSegment(segmentText, chapter) {
    const rangeMatch = segmentText.match(/^(\d+)\s*-\s*(\d+)$/);
    if (rangeMatch) {
      const startVerse = Number(rangeMatch[1]);
      const endVerse = Number(rangeMatch[2]);
      if (startVerse > endVerse) {
        throw new Error(`Invalid verse range: ${segmentText}`);
      }
      return { kind: 'range', chapter, startVerse, endVerse, original: segmentText };
    }

    const singleMatch = segmentText.match(/^(\d+)$/);
    if (singleMatch) {
      const verse = Number(singleMatch[1]);
      return { kind: 'single', chapter, startVerse: verse, endVerse: verse, original: segmentText };
    }

    throw new Error(`Invalid verse segment: ${segmentText}`);
  }

  convertSegment(book, segment) {
    if (this.isPsalm(book)) {
      return this.convertPsalmSegment(segment);
    }

    return this.convertStandardSegment(book, segment);
  }

  convertPsalmSegment(segment) {
    if (this.psalmMode === PSALM_MODE.DISABLED) {
      return {
        pieces: [this.buildPiece(segment.chapter, segment.startVerse, segment.chapter, segment.endVerse)],
        warnings: ['Psalm versification conversion is disabled, so this Psalm reference was left unchanged.'],
        ruleIds: [],
      };
    }

    const warnings = [];
    const pieces = [];

    if (segment.startVerse === 1) {
      warnings.push('Dropped Psalm superscription from bible-api query while shifting Psalm verse numbers for WEB/WEBC.');
      if (segment.endVerse >= 2) {
        pieces.push(this.buildPiece(segment.chapter, 1, segment.chapter, segment.endVerse - 1));
      }
    } else {
      pieces.push(this.buildPiece(segment.chapter, segment.startVerse - 1, segment.chapter, segment.endVerse - 1));
    }

    return {
      pieces,
      warnings,
      ruleIds: ['psalm_superscription_shift'],
    };
  }

  convertStandardSegment(book, segment) {
    const startResult = this.convertSingleVerse(book, segment.chapter, segment.startVerse);
    const endResult = this.convertSingleVerse(book, segment.chapter, segment.endVerse);

    return {
      pieces: [this.buildPiece(startResult.chapter, startResult.verse, endResult.chapter, endResult.verse)],
      warnings: [],
      ruleIds: [startResult.ruleId, endResult.ruleId].filter(Boolean),
    };
  }

  convertSingleVerse(book, chapter, verse) {
    const matchingRule = JB_TO_WEBC_RULES.rules.find((rule) => (
      rule.match.book.includes(book)
      && this.valueMatches(chapter, rule.match.chapter)
      && this.valueMatches(verse, rule.match.verse)
    ));

    if (!matchingRule) {
      return { chapter, verse, ruleId: null };
    }

    return {
      chapter: this.applyOp(chapter, matchingRule.transform.chapter),
      verse: this.applyOp(verse, matchingRule.transform.verse),
      ruleId: matchingRule.id,
    };
  }

  valueMatches(inputValue, matcher) {
    if (typeof matcher === 'number') {
      return inputValue === matcher;
    }

    if (matcher && typeof matcher === 'object') {
      if (typeof matcher.min === 'number' && inputValue < matcher.min) return false;
      if (typeof matcher.max === 'number' && inputValue > matcher.max) return false;
      return true;
    }

    return false;
  }

  applyOp(currentValue, opDef) {
    switch (opDef.op) {
      case 'identity':
        return currentValue;
      case 'set':
        return opDef.value;
      case 'add':
        return currentValue + opDef.value;
      default:
        throw new Error(`Unsupported operation: ${opDef.op}`);
    }
  }

  buildPiece(startChapter, startVerse, endChapter, endVerse) {
    return {
      type: startChapter === endChapter && startVerse === endVerse ? 'single' : 'range',
      startChapter,
      startVerse,
      endChapter,
      endVerse,
    };
  }

  renderPieces(pieces) {
    if (pieces.length === 0) {
      return '';
    }

    const firstChapter = pieces[0].startChapter;
    const sameChapter = pieces.every((piece) => (
      piece.startChapter === firstChapter && piece.endChapter === firstChapter
    ));

    if (sameChapter) {
      const verseParts = pieces.map((piece) => (
        piece.type === 'single'
          ? String(piece.startVerse)
          : `${piece.startVerse}-${piece.endVerse}`
      ));
      return `${firstChapter}:${verseParts.join(', ')}`;
    }

    return pieces
      .map((piece) => {
        if (piece.type === 'single') {
          return `${piece.startChapter}:${piece.startVerse}`;
        }
        if (piece.startChapter === piece.endChapter) {
          return `${piece.startChapter}:${piece.startVerse}-${piece.endVerse}`;
        }
        return `${piece.startChapter}:${piece.startVerse}-${piece.endChapter}:${piece.endVerse}`;
      })
      .join(', ');
  }

  isPsalm(book) {
    return PSALM_BOOKS.includes(book);
  }

  isEsther(book) {
    return ESTHER_BOOKS.includes(book);
  }
}

module.exports = {
  JerusalemToWebcReferenceConverter,
  JB_TO_WEBC_RULES,
  NON_CONVERTIBLE_RESULT,
};
