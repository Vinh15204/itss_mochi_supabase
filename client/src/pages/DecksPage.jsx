import { useState, useEffect, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';

const DecksPage = () => {
  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState({ title: '', description: '', language: 'ja' });
  const [sourceFilter, setSourceFilter] = useState('all'); // all | system | my
  const [topicFilter, setTopicFilter] = useState('all'); // all | it | medical | economics | engineering | law | toeic | ielts | japanese
  const [searchTerm, setSearchTerm] = useState('');
  const navigate = useNavigate();
  const { user } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const { t, currentLang } = useTranslation();

  const loadDecks = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('decks')
        .select('*')
        .order('created_at', { ascending: true });

      if (error) throw error;
      setDecks(data || []);
    } catch (err) {
      console.error('Error loading decks:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tải bộ thẻ' : currentLang === 'en' ? 'Failed to load decks' : 'デッキの読み込みに失敗しました', 'error');
    } finally {
      setLoading(false);
    }
  }, [currentLang, addToast]);

  useEffect(() => {
    loadDecks();
  }, [loadDecks]);

  const getDeckCategory = (deck) => {
    const title = (deck.title || '').toLowerCase();
    if (title.startsWith('it -')) return 'it';
    if (title.startsWith('y khoa -')) return 'medical';
    if (title.startsWith('kinh tế -')) return 'economics';
    if (title.startsWith('kỹ thuật -')) return 'engineering';
    if (title.startsWith('luật & chính trị -') || title.startsWith('luật')) return 'law';
    if (title.startsWith('toeic -')) return 'toeic';
    if (title.startsWith('ielts')) return 'ielts';
    if (deck.language === 'ja') return 'japanese';
    return 'other';
  };

  const filteredDecks = useMemo(() => {
    return decks.filter(deck => {
      // 1. Phân loại theo nguồn gốc (Hệ thống vs Của tôi)
      const isSystem = !deck.user_id;
      const isMine = user?.id && deck.user_id === user.id;

      if (sourceFilter === 'system' && !isSystem) return false;
      if (sourceFilter === 'my' && !isMine) return false;

      // 2. Phân loại theo chuyên ngành / chủ đề
      if (topicFilter !== 'all') {
        const cat = getDeckCategory(deck);
        if (cat !== topicFilter) return false;
      }

      // 3. Tìm kiếm theo từ khóa
      if (searchTerm.trim()) {
        const q = searchTerm.toLowerCase();
        const matchTitle = (deck.title || '').toLowerCase().includes(q);
        const matchDesc = (deck.description || '').toLowerCase().includes(q);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    });
  }, [decks, sourceFilter, topicFilter, searchTerm, user]);

  const createDeck = async (e) => {
    e.preventDefault();
    try {
      const { data: { user: currentUser } } = await supabase.auth.getUser();
      const { data, error } = await supabase
        .from('decks')
        .insert([{
          title: form.title,
          description: form.description,
          language: form.language,
          user_id: currentUser?.id || user?.id,
          card_count: 0
        }])
        .select();

      if (error) throw error;

      if (data && data.length > 0) {
        setDecks(prev => [...prev, data[0]]);
      }
      setShowCreate(false);
      setForm({ title: '', description: '', language: 'ja' });
      addToast(currentLang === 'vi' ? 'Đã tạo bộ thẻ cá nhân thành công!' : currentLang === 'en' ? 'Deck created!' : 'デッキを作成しました！', 'success');
    } catch (err) {
      console.error('Error creating deck:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tạo bộ thẻ' : currentLang === 'en' ? 'Failed to create deck' : 'デッキの作成に失敗しました', 'error');
    }
  };

  const deleteDeck = async (deck, e) => {
    e.stopPropagation();
    const isSystem = !deck.user_id;
    if (isSystem) {
      addToast(currentLang === 'vi' ? 'Không thể xóa bộ từ mẫu của hệ thống' : 'Cannot delete system default deck', 'warning');
      return;
    }
    if (!confirm(t('decks.deleteConfirm'))) return;
    try {
      const deckId = deck.id || deck._id;
      const { error } = await supabase
        .from('decks')
        .delete()
        .eq('id', deckId);

      if (error) throw error;

      setDecks(prev => prev.filter(d => (d.id || d._id) !== deckId));
      addToast(currentLang === 'vi' ? 'Đã xóa bộ thẻ' : currentLang === 'en' ? 'Deck deleted' : 'デッキを削除しました', 'success');
    } catch (err) {
      console.error('Error deleting deck:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi xóa bộ thẻ' : currentLang === 'en' ? 'Failed to delete deck' : 'デッキの削除に失敗しました', 'error');
    }
  };

  const systemCount = decks.filter(d => !d.user_id).length;
  const myCount = user ? decks.filter(d => d.user_id === user.id).length : 0;

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  return (
    <div>
      <ToastContainer />
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-md)' }}>
        <div>
          <h1 className="page-title">📚 <span className="text-gradient">{t('decks.title')}</span></h1>
          <p className="page-subtitle">{currentLang === 'vi' ? 'Kho từ vựng 1.050 từ chuyên ngành & bộ thẻ tùy chỉnh cá nhân' : t('decks.subtitle')}</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
          ✨ {t('decks.addDeck')}
        </button>
      </div>

      {/* Primary Tab Filters: All vs System vs My Decks */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-md)', marginBottom: 'var(--space-xl)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 'var(--space-md)' }}>
          <div className="filter-group">
            <button
              className={`filter-option-btn ${sourceFilter === 'all' ? 'active-all' : ''}`}
              onClick={() => setSourceFilter('all')}
            >
              🌐 {currentLang === 'vi' ? 'Tất cả bộ thẻ' : 'All Decks'} ({decks.length})
            </button>
            <button
              className={`filter-option-btn ${sourceFilter === 'system' ? 'active-mastered' : ''}`}
              onClick={() => setSourceFilter('system')}
            >
              🏛️ {currentLang === 'vi' ? 'Bộ từ gốc hệ thống' : 'System Presets'} ({systemCount})
            </button>
            <button
              className={`filter-option-btn ${sourceFilter === 'my' ? 'active-unmastered' : ''}`}
              onClick={() => setSourceFilter('my')}
            >
              👤 {currentLang === 'vi' ? 'Bộ từ của tôi' : 'My Custom Decks'} ({myCount})
            </button>
          </div>

          {/* Search Box */}
          <div style={{ minWidth: '260px', flex: '1', maxWidth: '380px' }}>
            <input
              type="text"
              className="form-input"
              style={{ width: '100%', padding: '0.6rem 1rem' }}
              placeholder={currentLang === 'vi' ? '🔍 Tìm kiếm bài học, chủ đề...' : '🔍 Search decks...'}
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        {/* Secondary Category Filters */}
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', overflowX: 'auto', paddingBottom: '4px' }}>
          {[
            { id: 'all', label: 'Tất cả chuyên ngành', icon: '🎯' },
            { id: 'it', label: 'IT & Phần mềm', icon: '💻' },
            { id: 'medical', label: 'Y Khoa', icon: '🏥' },
            { id: 'economics', label: 'Kinh Tế', icon: '📊' },
            { id: 'engineering', label: 'Kỹ Thuật', icon: '⚙️' },
            { id: 'law', label: 'Luật & Chính Trị', icon: '⚖️' },
            { id: 'toeic', label: 'TOEIC Công Sở', icon: '💼' },
            { id: 'ielts', label: 'IELTS Academic', icon: '🎓' },
            { id: 'japanese', label: 'Tiếng Nhật', icon: '🇯🇵' },
          ].map(cat => (
            <button
              key={cat.id}
              onClick={() => setTopicFilter(cat.id)}
              style={{
                padding: '0.35rem 0.85rem',
                borderRadius: '999px',
                border: '1px solid',
                borderColor: topicFilter === cat.id ? 'var(--primary-color)' : 'rgba(255,255,255,0.1)',
                background: topicFilter === cat.id ? 'var(--primary-glow, rgba(99, 102, 241, 0.2))' : 'rgba(255,255,255,0.03)',
                color: topicFilter === cat.id ? '#fff' : 'var(--text-secondary)',
                fontSize: '0.85rem',
                cursor: 'pointer',
                fontWeight: topicFilter === cat.id ? '600' : '400',
                transition: 'all 0.2s ease',
                whiteSpace: 'nowrap'
              }}
            >
              {cat.icon} {cat.label}
            </button>
          ))}
        </div>
      </div>

      {/* Create Modal */}
      {showCreate && (
        <div className="modal-overlay" onClick={() => setShowCreate(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="glass-card">
              <h2 style={{ marginBottom: 'var(--space-xl)' }}>{t('decks.modalTitle')}</h2>
              <form onSubmit={createDeck} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-lg)' }}>
                <div className="form-group">
                  <label className="form-label">{t('decks.deckTitle')}</label>
                  <input
                    className="form-input"
                    placeholder={t('decks.placeholderTitle')}
                    value={form.title}
                    onChange={e => setForm(p => ({ ...p, title: e.target.value }))}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">{t('decks.deckDesc')}</label>
                  <input
                    className="form-input"
                    placeholder={t('decks.placeholderDesc')}
                    value={form.description}
                    onChange={e => setForm(p => ({ ...p, description: e.target.value }))}
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">{t('decks.deckLang')}</label>
                  <select
                    className="form-select"
                    value={form.language}
                    onChange={e => setForm(p => ({ ...p, language: e.target.value }))}
                  >
                    <option value="ja">{t('decks.langJa')}</option>
                    <option value="en">{t('decks.langEn')}</option>
                  </select>
                </div>
                <div style={{ display: 'flex', gap: 'var(--space-md)' }}>
                  <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>
                    {t('decks.createBtn')}
                  </button>
                  <button type="button" className="btn btn-secondary" onClick={() => setShowCreate(false)}>
                    {t('decks.cancelBtn')}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {decks.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">📇</div>
          <div className="empty-title">{currentLang === 'vi' ? 'Chưa có bộ thẻ nào' : currentLang === 'en' ? 'No decks yet' : 'デッキがありません'}</div>
          <div className="empty-desc">{currentLang === 'vi' ? 'Hãy chạy file seed_vocabulary.sql trong Supabase hoặc tạo bộ thẻ mới!' : 'Create your first flashcard deck to start learning!'}</div>
          <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
            {t('decks.addDeck')}
          </button>
        </div>
      ) : filteredDecks.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">🔍</div>
          <div className="empty-title" style={{ color: 'var(--text-primary)' }}>
            {currentLang === 'vi' ? 'Không tìm thấy bộ thẻ phù hợp' : 'No matching decks found'}
          </div>
          <div className="empty-desc" style={{ color: 'var(--text-secondary)' }}>
            {sourceFilter === 'my' 
              ? (currentLang === 'vi' ? 'Bạn chưa tự tạo bộ thẻ cá nhân nào. Hãy bấm "Thêm bộ thẻ" để bắt đầu tạo riêng cho mình!' : 'You have not created any custom decks yet.')
              : (currentLang === 'vi' ? 'Thử đổi bộ lọc hoặc xóa từ khóa tìm kiếm.' : 'Try changing your filter criteria or search keyword.')}
          </div>
          {sourceFilter === 'my' ? (
            <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
              ✨ {t('decks.addDeck')}
            </button>
          ) : (
            <button className="btn btn-secondary" onClick={() => { setSourceFilter('all'); setTopicFilter('all'); setSearchTerm(''); }}>
              {t('flashcards.viewAll')}
            </button>
          )}
        </div>
      ) : (
        <div className="deck-grid">
          {filteredDecks.map(deck => {
            const deckId = deck.id || deck._id;
            const isSystem = !deck.user_id;
            const isMyDeck = user?.id && deck.user_id === user.id;

            return (
              <div
                key={deckId}
                className="glass-card deck-card"
                onClick={() => navigate(`/decks/${deckId}`)}
                style={{ position: 'relative' }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-sm)' }}>
                  <span className="deck-lang">
                    {deck.language === 'ja' ? t('decks.langJa') : t('decks.langEn')}
                  </span>
                  {isSystem ? (
                    <span style={{ fontSize: '0.75rem', padding: '2px 8px', borderRadius: '12px', background: 'rgba(99, 102, 241, 0.15)', color: 'var(--primary-color)', border: '1px solid rgba(99, 102, 241, 0.3)' }}>
                      🏛️ Mẫu hệ thống
                    </span>
                  ) : (
                    <span style={{ fontSize: '0.75rem', padding: '2px 8px', borderRadius: '12px', background: 'rgba(16, 185, 129, 0.15)', color: '#10b981', border: '1px solid rgba(16, 185, 129, 0.3)' }}>
                      👤 Của tôi
                    </span>
                  )}
                </div>

                <h3 className="deck-title">{deck.title}</h3>
                <p className="deck-desc">{deck.description || (currentLang === 'vi' ? 'Chưa có mô tả' : currentLang === 'en' ? 'No description' : '説明なし')}</p>
                <div className="deck-meta">
                  <span>{t('decks.totalCards', { count: deck.card_count || deck.cardCount || 0 })}</span>
                  {isMyDeck && (
                    <button
                      className="btn btn-ghost btn-sm"
                      onClick={(e) => deleteDeck(deck, e)}
                      style={{ color: 'var(--accent-red)' }}
                      title="Xóa bộ thẻ của tôi"
                    >
                      🗑️
                    </button>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default DecksPage;
