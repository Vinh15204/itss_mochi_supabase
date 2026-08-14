import axios from 'axios';

/**
 * Clean and summarize long translated text into a concise flashcard meaning
 */
const cleanMeaningText = (text) => {
  if (!text) return '';
  let cleaned = text.trim();

  // Remove leading/trailing dots or punctuation
  cleaned = cleaned.replace(/^[\s.,;:()-]+|[\s.,;:()-]+$/g, '');

  // If text contains full sentence/dictionary explanation in brackets, extract main concise part
  if (cleaned.includes(';') || cleaned.includes(' - ')) {
    cleaned = cleaned.split(/;| - /)[0];
  }

  // If text starts with parenthesis explanations like "(thường là học thuật) X", clean it
  cleaned = cleaned.replace(/^\([^)]+\)\s*/g, '');

  // Truncate if still over 55 characters
  if (cleaned.length > 55) {
    cleaned = cleaned.substring(0, 52) + '...';
  }

  return cleaned.trim();
};

/**
 * Get base form for plural nouns or verb suffixes (-s, -es, -ed, -ing)
 */
const getBaseWord = (word) => {
  const w = word.toLowerCase().trim();
  if (w.endsWith('s') && w.length > 4 && !w.endsWith('ss')) {
    return w.slice(0, -1);
  }
  if (w.endsWith('ing') && w.length > 5) {
    return w.slice(0, -3);
  }
  if (w.endsWith('ed') && w.length > 4) {
    return w.slice(0, -2);
  }
  return w;
};

/**
 * Translate word or phrase to Vietnamese safely with fallback
 */
export const translateToVietnamese = async (text, sourceLang = 'en') => {
  if (!text) return '';
  const cleaned = text.trim();
  const baseWord = getBaseWord(cleaned);

  try {
    // Try base word first if different, else try original
    const queryWord = (baseWord !== cleaned) ? baseWord : cleaned;

    const res = await axios.get(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(queryWord)}&langpair=${sourceLang}|vi`, {
      timeout: 3500
    });

    let translated = res.data?.responseData?.translatedText;
    if (translated && !translated.includes('MYMEMORY WARNING')) {
      const result = cleanMeaningText(translated);
      if (result && result.toLowerCase() !== queryWord.toLowerCase()) {
        return result;
      }
    }

    // Fallback attempt with original if base word query was different
    if (queryWord !== cleaned) {
      const resOrig = await axios.get(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(cleaned)}&langpair=${sourceLang}|vi`, {
        timeout: 3000
      });
      let translatedOrig = resOrig.data?.responseData?.translatedText;
      if (translatedOrig && !translatedOrig.includes('MYMEMORY WARNING')) {
        const result = cleanMeaningText(translatedOrig);
        if (result && result.toLowerCase() !== cleaned.toLowerCase()) {
          return result;
        }
      }
    }

    return '';
  } catch {
    return '';
  }
};

/**
 * Fetch English definition directly with rate limit protection
 */
export const fetchEnglishDefinition = async (word) => {
  if (!word) return '';
  const baseWord = getBaseWord(word);
  try {
    const res = await axios.get(`https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(baseWord)}`, {
      timeout: 3000
    });
    if (res.data && res.data[0]?.meanings?.[0]?.definitions?.[0]?.definition) {
      return cleanMeaningText(res.data[0].meanings[0].definitions[0].definition);
    }
    return '';
  } catch {
    return '';
  }
};

/**
 * Fetch Japanese definition or reading fallback
 */
export const fetchJapaneseDefinition = async (word) => {
  if (!word) return '';
  try {
    const res = await axios.get(`https://jisho.org/api/v1/search/words?keyword=${encodeURIComponent(word)}`, {
      timeout: 3000
    });
    if (res.data?.data?.[0]) {
      const firstResult = res.data.data[0];
      const japaneseInfo = firstResult.japanese?.[0] || {};
      const reading = japaneseInfo.reading || '';
      const englishSenses = firstResult.senses?.[0]?.english_definitions?.join(', ') || '';
      return { definition: cleanMeaningText(englishSenses), reading };
    }
    return { definition: '', reading: '' };
  } catch {
    return { definition: '', reading: '' };
  }
};
