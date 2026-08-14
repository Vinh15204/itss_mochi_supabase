import axios from 'axios';

/**
 * Fetch English definition directly using free public Free Dictionary API
 */
export const fetchEnglishDefinition = async (word) => {
  if (!word) return '';
  try {
    const res = await axios.get(`https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(word)}`);
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
    // Free Jisho API search endpoint (CORS proxy or fallback)
    const res = await axios.get(`https://jisho.org/api/v1/search/words?keyword=${encodeURIComponent(word)}`);
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

/**
 * Translate text to Vietnamese using free MyMemory Translation API
 */
export const translateToVietnamese = async (text, sourceLang = 'en') => {
  if (!text) return '';
  try {
    const res = await axios.get(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(text.slice(0, 500))}&langpair=${sourceLang}|vi`);
    if (res.data?.responseData?.translatedText) {
      return res.data.responseData.translatedText;
    }
    return text;
  } catch {
    return text;
  }
};
