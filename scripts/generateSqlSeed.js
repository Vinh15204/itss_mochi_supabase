import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '..', 'data');
const jsonFiles = fs.readdirSync(dataDir).filter(f => f.endsWith('.json'));

let sql = `-- =========================================================
-- LINGUA: COMPLETE SEED VOCABULARY DATASET (1,050 WORDS)
-- Gồm 70 bài học phân loại theo các Chuyên ngành Đại học, TOEIC & IELTS
-- Nghĩa tiếng Việt tối giản, súc tích (1-3 từ), có phiên âm IPA
-- =========================================================

DO $$
DECLARE
  v_deck_id UUID;
BEGIN
`;

let totalDecks = 0;
let totalCards = 0;

for (const file of jsonFiles) {
  const filePath = path.join(dataDir, file);
  const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  sql += `\n  -- =========================================================\n`;
  sql += `  -- KHỐI: ${file.toUpperCase()} (${content.length} bài học)\n`;
  sql += `  -- =========================================================\n`;

  for (const deck of content) {
    totalDecks++;
    const safeTitle = deck.title.replace(/'/g, "''");
    const safeDesc = (deck.description || '').replace(/'/g, "''");
    const safeLang = deck.language || 'en';

    sql += `\n  -- Bài ${totalDecks}: ${safeTitle}\n`;
    sql += `  INSERT INTO decks (title, description, language, card_count, created_at)\n`;
    sql += `  VALUES ('${safeTitle}', '${safeDesc}', '${safeLang}', ${deck.cards.length}, NOW())\n`;
    sql += `  RETURNING id INTO v_deck_id;\n\n`;

    sql += `  INSERT INTO cards (deck_id, front, reading, back, example, mastered, created_at) VALUES\n`;
    const cardRows = deck.cards.map((c, idx) => {
      totalCards++;
      const safeFront = c.front.replace(/'/g, "''");
      const safeReading = (c.reading || '').replace(/'/g, "''");
      const safeBack = c.back.replace(/'/g, "''");
      const safeExample = (c.example || '').replace(/'/g, "''");
      const isLast = idx === deck.cards.length - 1;
      return `  (v_deck_id, '${safeFront}', '${safeReading}', '${safeBack}', '${safeExample}', false, NOW())${isLast ? ';' : ','}`;
    });

    sql += cardRows.join('\n') + '\n';
  }
}

sql += `\nEND $$;\n`;

fs.writeFileSync(path.join(dataDir, 'seed_vocabulary.sql'), sql, 'utf-8');
console.log(`✅ Đã tạo thành công seed_vocabulary.sql với ${totalDecks} bài học và ${totalCards} từ vựng!`);
