import { useState, useEffect, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useDeckStatus } from '../hooks/useDeckStatus';
import { TOPIC_CATEGORIES, getDeckTopicId } from '../services/topicCategories';

const DecksPage = () => {
  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState({ title: '', description: '', language: 'ja' });
  const [sourceFilter, setSourceFilter] = useState('all'); // all | system | my
  const [searchTerm, setSearchTerm] = useState('');
  
  const navigate = useNavigate();
  const { user } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const { t, currentLang } = useTranslation();

  const { getStatus, DECK_STATUS } = useDeckStatus(decks);

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
      addToast(currentLang === 'vi' ? 'Lỗi khi tải danh sách chủ đề' : 'Failed to load topics', 'error');
    } finally {
      setLoading(false);
    }
  }, [currentLang, addToast]);

  useEffect(() => {
    loadDecks();
  }, [loadDecks]);

  // Compute topic list with stats
  const topicList = useMemo(() => {
    return TOPIC_CATEGORIES.map(category => {
      // Find all decks belonging to this category
      const matchedDecks = decks.filter(deck => getDeckTopicId(deck) === category.id);
      
      let learningCount = 0;
      let completedCount = 0;
      let totalCards = 0;

      matchedDecks.forEach(deck => {
        const deckId = deck.id || deck._id;
        const st = getStatus(deckId);
        totalCards += (deck.card_count || deck.cardCount || 0);

        if (st === DECK_STATUS.LEARNING) learningCount++;
        else if (st === DECK_STATUS.COMPLETED) completedCount++;
      });

      const totalLessons = matchedDecks.length;
      const percent = totalLessons > 0 ? Math.round((completedCount / totalLessons) * 100) : 0;

      return {
        ...category,
        totalLessons,
        totalCards,
        learningCount,
        completedCount,
        percent,
        hasDecks: totalLessons > 0
      };
    }).filter(topic => {
      // 1. Filter by source
      if (sourceFilter === 'system' && topic.id === 'my') return false;
      if (sourceFilter === 'my' && topic.id !== 'my') return false;

      // Hide empty topics unless it's "my" (user might want to create)
      if (topic.id !== 'my' && !topic.hasDecks) return false;

      // 2. Search keyword filter
      if (searchTerm.trim()) {
        const q = searchTerm.toLowerCase();
        const titleVi = (topic.title.vi || '').toLowerCase();
        const titleEn = (topic.title.en || '').toLowerCase();
        const descVi = (topic.desc.vi || '').toLowerCase();
        const descEn = (topic.desc.descEn || '').toLowerCase();
        const matchTopic = titleVi.includes(q) || titleEn.includes(q) || descVi.includes(q) || descEn.includes(q);

        // Or if any deck inside this topic matches
        const matchChildDeck = decks.some(d => getDeckTopicId(d) === topic.id && (
          (d.title || '').toLowerCase().includes(q) || (d.description || '').toLowerCase().includes(q)
        ));

        if (!matchTopic && !matchChildDeck) return false;
      }

      return true;
    });
  }, [decks, sourceFilter, searchTerm, getStatus, DECK_STATUS]);

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
      addToast(currentLang === 'vi' ? 'Đã tạo bộ thẻ cá nhân thành công!' : 'Deck created!', 'success');
      navigate(`/decks/topic/my`);
    } catch (err) {
      console.error('Error creating deck:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tạo bộ thẻ' : 'Failed to create deck', 'error');
    }
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  const totalSystemDecks = decks.filter(d => !d.user_id).length;
  const totalMyDecks = user ? decks.filter(d => d.user_id === user.id).length : 0;
  const totalCardsAll = decks.reduce((acc, d) => acc + (d.card_count || d.cardCount || 0), 0);

  return (
    <div>
      <ToastContainer />
      
      {/* Page Header */}
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-md)' }}>
        <div>
          <h1 className="page-title">📚 <span className="text-gradient">{currentLang === 'vi' ? 'Chủ Đề Từ Vựng' : t('decks.title')}</span></h1>
          <p className="page-subtitle">
            {currentLang === 'vi' 
              ? `Kho học liệu với ${totalCardsAll.toLocaleString()} từ vựng phân chia theo từng chủ đề & chuyên ngành. Nhấn vào một chủ đề để xem danh sách bài học.` 
              : 'Explore curated vocabulary topics and study lessons by clicking on any category.'}
          </p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
          ✨ {t('decks.addDeck')}
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem', marginBottom: 'var(--space-xl)' }}>
        {/* Source Tabs */}
        <div style={{ display: 'flex', gap: '0.4rem', background: 'rgba(255,255,255,0.05)', padding: '4px', borderRadius: '10px' }}>
          <button
            className={`btn ${sourceFilter === 'all' ? 'btn-primary' : 'btn-ghost'}`}
            onClick={() => setSourceFilter('all')}
            style={{ padding: '0.4rem 0.85rem', fontSize: '0.85rem' }}
          >
            {currentLang === 'vi' ? 'Tất cả chủ đề' : 'All Topics'}
          </button>
          <button
            className={`btn ${sourceFilter === 'system' ? 'btn-primary' : 'btn-ghost'}`}
            onClick={() => setSourceFilter('system')}
            style={{ padding: '0.4rem 0.85rem', fontSize: '0.85rem' }}
          >
            🏛️ {currentLang === 'vi' ? 'Kho chuyên ngành' : 'System Topics'} ({totalSystemDecks})
          </button>
          <button
            className={`btn ${sourceFilter === 'my' ? 'btn-primary' : 'btn-ghost'}`}
            onClick={() => setSourceFilter('my')}
            style={{ padding: '0.4rem 0.85rem', fontSize: '0.85rem' }}
          >
            👤 {currentLang === 'vi' ? 'Của tôi' : 'My Decks'} ({totalMyDecks})
          </button>
        </div>

        {/* Search */}
        <div style={{ width: '100%', maxWidth: '340px' }}>
          <input
            type="text"
            className="form-input"
            placeholder={currentLang === 'vi' ? '🔍 Tìm kiếm theo chủ đề, từ khóa...' : 'Search topics...'}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{ padding: '0.45rem 0.85rem', fontSize: '0.85rem', width: '100%' }}
          />
        </div>
      </div>

      {/* Topic Rows List */}
      {topicList.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">🔍</div>
          <div className="empty-title" style={{ color: 'var(--text-primary)' }}>
            {currentLang === 'vi' ? 'Không tìm thấy chủ đề phù hợp' : 'No matching topics found'}
          </div>
          <div className="empty-desc" style={{ color: 'var(--text-secondary)' }}>
            {sourceFilter === 'my'
              ? (currentLang === 'vi' ? 'Bạn chưa tự tạo bộ thẻ cá nhân nào. Hãy bấm "Thêm bộ thẻ" để bắt đầu!' : 'You have not created any custom decks yet.')
              : (currentLang === 'vi' ? 'Thử tìm với từ khóa khác hoặc bấm hiển thị tất cả.' : 'Try another keyword or view all.')}
          </div>
          {sourceFilter === 'my' ? (
            <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
              ✨ {t('decks.addDeck')}
            </button>
          ) : (
            <button className="btn btn-secondary" onClick={() => { setSourceFilter('all'); setSearchTerm(''); }}>
              {t('flashcards.viewAll')}
            </button>
          )}
        </div>
      ) : (
        <div className="topic-list-container">
          {topicList.map(topic => {
            const title = topic.title[currentLang] || topic.title.vi;
            const desc = topic.desc[currentLang] || topic.desc.vi;

            return (
              <div
                key={topic.id}
                className="topic-row-item"
                onClick={() => navigate(`/decks/topic/${topic.id}`)}
                style={{
                  borderLeft: `5px solid ${topic.tagColor || 'var(--primary-color)'}`
                }}
              >
                {/* Left: Icon & Info */}
                <div className="topic-main-info">
                  <div
                    className="topic-icon-frame"
                    style={{
                      background: topic.bgGradient || 'rgba(255,255,255,0.05)',
                      borderColor: topic.borderGlow || 'rgba(255,255,255,0.1)'
                    }}
                  >
                    {topic.icon}
                  </div>

                  <div>
                    <div className="topic-title-heading">
                      <span>{title}</span>
                      {topic.id === 'my' && (
                        <span style={{ fontSize: '0.72rem', padding: '2px 8px', borderRadius: '10px', background: 'rgba(20, 184, 166, 0.2)', color: '#14b8a6', border: '1px solid rgba(20, 184, 166, 0.4)' }}>
                          👤 Của tôi
                        </span>
                      )}
                    </div>
                    <p className="topic-desc-summary">{desc}</p>
                  </div>
                </div>

                {/* Right: Stats & Action Arrow */}
                <div className="topic-row-stats">
                  <div className="topic-stats-badges">
                    <div style={{ display: 'flex', gap: '0.4rem', alignItems: 'center' }}>
                      <span className="topic-count-tag" style={{ background: `${topic.tagColor}20`, color: topic.tagColor || '#fff', borderColor: `${topic.tagColor}40` }}>
                        📁 {topic.totalLessons} {currentLang === 'vi' ? 'Bài học' : 'Lessons'}
                      </span>
                      <span className="topic-count-tag">
                        📇 {topic.totalCards} {currentLang === 'vi' ? 'từ vựng' : 'words'}
                      </span>
                    </div>

                    {(topic.learningCount > 0 || topic.completedCount > 0) && (
                      <span className="topic-progress-text-mini">
                        {topic.learningCount > 0 && <span style={{ color: '#4ade80', marginRight: '6px' }}>🟢 {topic.learningCount} đang học</span>}
                        {topic.completedCount > 0 && <span style={{ color: '#60a5fa' }}>🔵 {topic.completedCount} đã thuộc</span>}
                      </span>
                    )}
                  </div>

                  <div className="topic-arrow-btn" title={currentLang === 'vi' ? 'Xem các bài học trong chủ đề này' : 'View lessons'}>
                    ➜
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

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
    </div>
  );
};

export default DecksPage;
