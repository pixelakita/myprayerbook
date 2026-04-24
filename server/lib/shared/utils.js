const fs = require('fs/promises');

class Sleep {
  static for(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

class FileSystemHelper {
  static async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  static async readJson(filePath) {
    const text = await fs.readFile(filePath, 'utf8');
    return JSON.parse(text);
  }

  static async writeJson(filePath, value) {
    await fs.writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
  }
}

class TextHelper {
  static normalizeWhitespace(value) {
    return String(value).replace(/\s+/g, ' ').trim();
  }

  static stripMarkdownCodeFence(text) {
    if (typeof text !== 'string') return '';
    const trimmed = text.trim();

    if (!trimmed.startsWith('```')) {
      return trimmed;
    }

    return trimmed
      .replace(/^```(?:json)?\s*/i, '')
      .replace(/\s*```$/, '')
      .trim();
  }

  static extractMessageText(message) {
    if (!message) return '';

    if (typeof message.content === 'string') {
      return message.content;
    }

    if (Array.isArray(message.content)) {
      return message.content
        .map((part) => {
          if (typeof part === 'string') return part;
          if (part && typeof part.text === 'string') return part.text;
          return '';
        })
        .join('')
        .trim();
    }

    return '';
  }
}

module.exports = {
  Sleep,
  FileSystemHelper,
  TextHelper,
};
