import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dataDir = path.join(__dirname, '..', 'data');
const jsonFiles = [
  'it_software.json',
  'medical.json',
  'economics_finance.json',
  'engineering.json',
  'law_politics.json',
  'toeic_workplace.json',
  'ielts_academic.json'
];

let sql = `-- =========================================================================
-- LINGUA: CẤP QUYỀN RLS & NẠP 1.050 TỪ VỰNG CHUYÊN NGÀNH (70 BÀI HỌC)
-- =========================================================================

-- 1. CẤP QUYỀN TRUY CẬP (ROW-LEVEL SECURITY) CHO BỘ TỪ GỐC
-- Đảm bảo người dùng VÀ khách vãng lai đều đọc được bộ thẻ hệ thống (user_id IS NULL)
ALTER TABLE IF EXISTS decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view system and own decks" ON decks;
CREATE POLICY "Public can view system and own decks" ON decks
FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own decks" ON decks;
CREATE POLICY "Users can insert own decks" ON decks
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own decks" ON decks;
CREATE POLICY "Users can update own decks" ON decks
FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own decks" ON decks;
CREATE POLICY "Users can delete own decks" ON decks
FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can view cards" ON cards;
CREATE POLICY "Public can view cards" ON cards
FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can manage cards in own decks" ON cards;
CREATE POLICY "Users can manage cards in own decks" ON cards
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM decks
    WHERE decks.id = cards.deck_id
    AND (decks.user_id = auth.uid() OR decks.user_id IS NULL)
  )
);

-- 2. NẠP TOÀN BỘ 70 BÀI HỌC CHUYÊN NGÀNH VÀO CƠ SỞ DỮ LIỆU
DO $$
DECLARE
  v_deck_id UUID;
BEGIN

  -- Xóa sạch các bộ thẻ hệ thống cũ (nếu có) để tránh bị trùng lặp
  DELETE FROM decks WHERE user_id IS NULL;
`;

let totalDecks = 0;
let totalCards = 0;

for (const file of jsonFiles) {
  const filePath = path.join(dataDir, file);
  if (!fs.existsSync(filePath)) continue;
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
console.log(`✅ Đã tạo thành công seed_vocabulary.sql với cấu hình RLS, ${totalDecks} bài học và ${totalCards} từ vựng!`);
