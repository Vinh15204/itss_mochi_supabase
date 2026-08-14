import axios from 'axios';

/**
 * Translate word or phrase to Vietnamese safely with fallback
 */
export const translateToVietnamese = async (text, sourceLang = 'en') => {
  if (!text) return '';
  const cleaned = text.trim();
  try {
    const res = await axios.get(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(cleaned)}&langpair=${sourceLang}|vi`, {
      timeout: 3500
    });
    let translated = res.data?.responseData?.translatedText;
    if (translated && !translated.includes('MYMEMORY WARNING')) {
      // Clean trailing period or garbage punctuation
      translated = translated.replace(/^[\s.,;:]+|[\s.,;:]+$/g, '');
      if (translated.toLowerCase() !== cleaned.toLowerCase()) {
        return translated;
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
  try {
    const res = await axios.get(`https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(word)}`, {
      timeout: 3000
    });
    if (res.data && res.data[0]?.meanings?.[0]?.definitions?.[0]?.definition) {
      return res.data[0].meanings[0].definitions[0].definition;
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
      return { definition: englishSenses, reading };
    }
    return { definition: '', reading: '' };
  } catch {
    return { definition: '', reading: '' };
  }
};
