import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { createClient } from '../client/node_modules/@supabase/supabase-js/dist/main/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'https://jhlzfowhrckzzhrbxbuj.supabase.co';
const SUPABASE_KEY = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpobHpmb3docmNrenpocmJ4YnVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY2OTEzNzcsImV4cCI6MjEwMjI2NzM3N30.PJWznrFYoS6UzTsIAjzhtIbcnJf9tSIqq2BfedjW_Hw';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function seed() {
  console.log('🚀 Bắt đầu nạp kho từ vựng chuẩn vào Supabase...');
  const dataDir = path.join(__dirname, '..', 'data');
  const files = fs.readdirSync(dataDir).filter(f => f.endsWith('.json'));

  let totalDecks = 0;
  let totalCards = 0;

  for (const file of files) {
    const filePath = path.join(dataDir, file);
    const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    console.log(`\n📂 Đang xử lý file: ${file} (${content.length} bài học)...`);

    for (const deckInfo of content) {
      // 1. Check if deck with same title already exists
      const { data: existingDecks } = await supabase
        .from('decks')
        .select('id, title')
        .eq('title', deckInfo.title);

      let deckId = null;

      if (existingDecks && existingDecks.length > 0) {
        deckId = existingDecks[0].id;
        console.log(`  ℹ️ Bộ thẻ "${deckInfo.title}" đã tồn tại (ID: ${deckId}). Cập nhật thẻ...`);
      } else {
        // Create new deck
        const { data: newDeck, error: deckErr } = await supabase
          .from('decks')
          .insert([{
            title: deckInfo.title,
            description: deckInfo.description,
            language: deckInfo.language || 'en',
            card_count: deckInfo.cards.length
          }])
          .select()
          .single();

        if (deckErr) {
          console.error(`  ❌ Lỗi khi tạo bộ thẻ "${deckInfo.title}":`, deckErr.message);
          continue;
        }

        deckId = newDeck.id;
        console.log(`  ✅ Đã tạo bộ thẻ: "${deckInfo.title}" (ID: ${deckId})`);
        totalDecks++;
      }

      // 2. Insert cards
      if (deckId && deckInfo.cards && deckInfo.cards.length > 0) {
        // Delete old cards in deck if re-seeding to prevent duplicates
        await supabase.from('cards').delete().eq('deck_id', deckId);

        const cardsToInsert = deckInfo.cards.map(c => ({
          deck_id: deckId,
          front: c.front,
          back: c.back,
          reading: c.reading || '',
          example: c.example || '',
          mastered: false
        }));

        const { error: cardsErr } = await supabase
          .from('cards')
          .insert(cardsToInsert);

        if (cardsErr) {
          console.error(`  ❌ Lỗi khi thêm thẻ vào "${deckInfo.title}":`, cardsErr.message);
        } else {
          console.log(`    ✨ Đã nạp thành công ${cardsToInsert.length} từ vựng vào "${deckInfo.title}".`);
          totalCards += cardsToInsert.length;
        }
      }
    }
  }

  console.log(`\n🎉 HOÀN THÀNH TẤT CẢ!`);
  console.log(`📊 Tổng số bài học đã nạp/cập nhật: ${totalDecks}`);
  console.log(`📖 Tổng số từ vựng: ${totalCards}`);
}

seed().catch(err => {
  console.error('Fatal Error:', err);
  process.exit(1);
});
