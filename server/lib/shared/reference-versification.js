const REFERENCE_VERSIFICATION = {
  NONE: 'none',
  JB_TO_WEBC: 'jb-to-webc',
};

const PSALM_MODE = {
  DISABLED: 'disabled',
  JB_COUNTS_SUPERSCRIPTION_AS_V1: 'jb_counts_superscription_as_v1',
};

const DEFAULT_REFERENCE_VERSIFICATION = REFERENCE_VERSIFICATION.JB_TO_WEBC;
const DEFAULT_PSALM_MODE = PSALM_MODE.JB_COUNTS_SUPERSCRIPTION_AS_V1;

const REFERENCE_VERSIFICATION_VALUES = Object.values(REFERENCE_VERSIFICATION);
const PSALM_MODE_VALUES = Object.values(PSALM_MODE);

function isValidReferenceVersification(mode) {
  return REFERENCE_VERSIFICATION_VALUES.includes(mode);
}

function isValidPsalmMode(mode) {
  return PSALM_MODE_VALUES.includes(mode);
}

function assertValidReferenceOptions({ referenceVersification, psalmMode }) {
  if (!isValidReferenceVersification(referenceVersification)) {
    throw new Error(`Invalid --reference-versification. Use ${REFERENCE_VERSIFICATION_VALUES.join(' or ')}.`);
  }

  if (!isValidPsalmMode(psalmMode)) {
    throw new Error(`Invalid --psalm-mode. Use ${PSALM_MODE_VALUES.join(' or ')}.`);
  }
}

module.exports = {
  REFERENCE_VERSIFICATION,
  PSALM_MODE,
  DEFAULT_REFERENCE_VERSIFICATION,
  DEFAULT_PSALM_MODE,
  REFERENCE_VERSIFICATION_VALUES,
  PSALM_MODE_VALUES,
  isValidReferenceVersification,
  isValidPsalmMode,
  assertValidReferenceOptions,
};
