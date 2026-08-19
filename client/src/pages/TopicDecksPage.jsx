import { useState, useEffect, useCallback, useMemo } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useDeckStatus } from '../hooks/useDeckStatus';
import { getTopicById, getDeckTopicId, parseDeckLessonInfo } from '../services/topicCategories';

const TopicDecksPage = () => {
  const { topicId } = useParams();
  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all'); // all | learning | not_started | completed
  const [searchTerm, setSearchTerm] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState({ title: '', description: '', language: 'ja' });

  const navigate = useNavigate();
  const { user } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const { t, currentLang } = useTranslation();

  const topic = useMemo(() => getTopicById(topicId), [topicId]);
  const topicTitle = topic.title[currentLang] || topic.title.vi;
  const topicDesc = topic.desc[currentLang] || topic.desc.vi;

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
      console.error('Error loading decks for topic:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tải danh sách bài học' : 'Failed to load lesson decks', 'error');
    } finally {
      setLoading(false);
    }
  }, [currentLang, addToast]);

  useEffect(() => {
    loadDecks();
  }, [loadDecks]);

  // Filter decks belonging only to this topic
  const topicDecks = useMemo(() => {
    return decks.filter(deck => getDeckTopicId(deck) === topicId);
  }, [decks, topicId]);

  // Filter topic decks based on status and search query
  const filteredDecks = useMemo(() => {
    return topicDecks.filter(deck => {
      const deckId = deck.id || deck._id;
      const status = getStatus(deckId);

      // Status filter
      if (statusFilter !== 'all' && status !== statusFilter) return false;

      // Keyword search
      if (searchTerm.trim()) {
        const q = searchTerm.toLowerCase();
        const matchTitle = (deck.title || '').toLowerCase().includes(q);
        const matchDesc = (deck.description || '').toLowerCase().includes(q);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    });
  }, [topicDecks, statusFilter, searchTerm, getStatus]);

  // Topic-level statistics
  const stats = useMemo(() => {
    let learning = 0;
    let completed = 0;
    let notStarted = 0;
    let totalCards = 0;

    topicDecks.forEach(deck => {
      const deckId = deck.id || deck._id;
      const st = getStatus(deckId);
      totalCards += (deck.card_count || deck.cardCount || 0);

      if (st === DECK_STATUS.LEARNING) learning++;
      else if (st === DECK_STATUS.COMPLETED) completed++;
      else notStarted++;
    });

    const percent = topicDecks.length > 0 ? Math.round((completed / topicDecks.length) * 100) : 0;

    return {
      totalLessons: topicDecks.length,
      totalCards,
      learning,
      completed,
      notStarted,
      percent
    };
  }, [topicDecks, getStatus, DECK_STATUS]);

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
    } catch (err) {
      console.error('Error creating deck:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tạo bộ thẻ' : 'Failed to create deck', 'error');
    }
  };

  const deleteDeck = async (deck, e) => {
    e.stopPropagation();
    if (!deck.user_id) {
      addToast(currentLang === 'vi' ? 'Không thể xóa bài học mẫu của hệ thống' : 'Cannot delete system default deck', 'warning');
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
      addToast(currentLang === 'vi' ? 'Đã xóa bộ thẻ' : 'Deck deleted', 'success');
    } catch (err) {
      console.error('Error deleting deck:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi xóa bộ thẻ' : 'Failed to delete deck', 'error');
    }
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  return (
    <div>
      <ToastContainer />

      {/* Navigation Breadcrumb */}
      <div style={{ marginBottom: 'var(--space-md)' }}>
        <button
          onClick={() => navigate('/decks')}
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            color: 'var(--text-secondary)',
            fontSize: '0.9rem',
            padding: '6px 12px',
            borderRadius: '8px',
            background: 'rgba(255,255,255,0.04)',
            border: '1px solid rgba(255,255,255,0.08)',
            cursor: 'pointer',
            transition: 'all 0.2s ease'
          }}
          onMouseEnter={e => { e.currentTarget.style.color = '#fff'; e.currentTarget.style.borderColor = 'var(--primary-color)'; }}
          onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-secondary)'; e.currentTarget.style.borderColor = 'rgba(255,255,255,0.08)'; }}
        >
          ← {currentLang === 'vi' ? 'Quay lại tất cả chủ đề' : 'Back to All Topics'}
        </button>
      </div>

      {/* Topic Hero Banner */}
      <div
        className="topic-hero-banner"
        style={{
          background: topic.bgGradient || 'var(--bg-card)',
          borderColor: topic.borderGlow || 'var(--border-color)'
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-lg)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', flex: 1, minWidth: '280px' }}>
            <div
              className="topic-icon-frame"
              style={{
                width: '68px',
                height: '68px',
                fontSize: '2.2rem',
                background: 'rgba(255,255,255,0.1)',
                borderColor: topic.tagColor || 'var(--border-color)'
              }}
            >
              {topic.icon}
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', flexWrap: 'wrap' }}>
                <h1 style={{ fontSize: '1.6rem', fontWeight: 800, margin: 0, color: '#fff' }}>{topicTitle}</h1>
                <span
                  style={{
                    fontSize: '0.75rem',
                    padding: '3px 10px',
                    borderRadius: '999px',
                    background: `${topic.tagColor}25`,
                    color: topic.tagColor || '#fff',
                    border: `1px solid ${topic.tagColor}50`,
                    fontWeight: 700
                  }}
                >
                  {stats.totalLessons} {currentLang === 'vi' ? 'Bài học' : 'Lessons'}
                </span>
              </div>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.92rem', marginTop: '4px', maxWidth: '750px', lineHeight: 1.5 }}>
                {topicDesc}
              </p>
            </div>
          </div>

          {topicId === 'my' && (
            <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
              ✨ {t('decks.addDeck')}
            </button>
          )}
        </div>

        {/* Progress & Summary Bar */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginTop: '1.5rem',
            paddingTop: '1.25rem',
            borderTop: '1px solid rgba(255,255,255,0.1)',
            flexWrap: 'wrap',
            gap: '1rem'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.8rem', flexWrap: 'wrap' }}>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
              📚 <strong>{stats.totalCards}</strong> {currentLang === 'vi' ? 'từ vựng' : 'vocabulary cards'}
            </span>
            <span style={{ color: 'rgba(255,255,255,0.2)' }}>•</span>
            <span style={{ fontSize: '0.85rem', color: '#4ade80' }}>
              🟢 {stats.learning} {currentLang === 'vi' ? 'đang học' : 'learning'}
            </span>
            <span style={{ color: 'rgba(255,255,255,0.2)' }}>•</span>
            <span style={{ fontSize: '0.85rem', color: '#60a5fa' }}>
              🔵 {stats.completed} {currentLang === 'vi' ? 'đã thuộc' : 'mastered'}
            </span>
            <span style={{ color: 'rgba(255,255,255,0.2)' }}>•</span>
            <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>
              ⚪ {stats.notStarted} {currentLang === 'vi' ? 'chưa học' : 'not started'}
            </span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div style={{ width: '140px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-muted)', marginBottom: '3px' }}>
                <span>{currentLang === 'vi' ? 'Tiến độ thuộc' : 'Mastered'}</span>
                <span style={{ fontWeight: 700, color: '#fff' }}>{stats.percent}%</span>
              </div>
              <div style={{ height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '999px', overflow: 'hidden' }}>
                <div style={{ height: '100%', width: `${stats.percent}%`, background: 'var(--gradient-primary)', borderRadius: '999px', transition: 'width 0.4s ease' }} />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Filter and Search Controls */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem', marginBottom: 'var(--space-xl)' }}>
        {/* Status Tabs */}
        <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
          {[
            { id: 'all', label: currentLang === 'vi' ? 'Tất cả bài học' : 'All Lessons', icon: '📁' },
            { id: DECK_STATUS.LEARNING, label: currentLang === 'vi' ? '🟢 Đang học' : 'Learning', icon: '🎯' },
            { id: DECK_STATUS.NOT_STARTED, label: currentLang === 'vi' ? '⚪ Chưa học' : 'Not Started', icon: '📦' },
            { id: DECK_STATUS.COMPLETED, label: currentLang === 'vi' ? '🔵 Đã thuộc xong' : 'Mastered', icon: '🏆' }
          ].map(st => (
            <button
              key={st.id}
              onClick={() => setStatusFilter(st.id)}
              style={{
                padding: '0.4rem 0.85rem',
                borderRadius: '8px',
                border: '1px solid',
                borderColor: statusFilter === st.id ? 'var(--primary-color)' : 'rgba(255,255,255,0.1)',
                background: statusFilter === st.id ? 'var(--primary-glow, rgba(99, 102, 241, 0.25))' : 'rgba(255,255,255,0.04)',
                color: statusFilter === st.id ? '#fff' : 'var(--text-secondary)',
                fontSize: '0.85rem',
                cursor: 'pointer',
                fontWeight: statusFilter === st.id ? '700' : '500',
                transition: 'all 0.2s ease'
              }}
            >
              {st.label}
            </button>
          ))}
        </div>

        {/* Search */}
        <div style={{ width: '100%', maxWidth: '320px' }}>
          <input
            type="text"
            className="form-input"
            placeholder={currentLang === 'vi' ? '🔍 Tìm bài học trong chủ đề...' : 'Search lessons in topic...'}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{ padding: '0.45rem 0.85rem', fontSize: '0.85rem', width: '100%' }}
          />
        </div>
      </div>

      {/* Lesson Decks Grid */}
      {filteredDecks.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">🔍</div>
          <div className="empty-title" style={{ color: 'var(--text-primary)' }}>
            {currentLang === 'vi' ? 'Không tìm thấy bài học nào phù hợp' : 'No matching lessons found'}
          </div>
          <div className="empty-desc" style={{ color: 'var(--text-secondary)' }}>
            {topicId === 'my' && topicDecks.length === 0
              ? (currentLang === 'vi' ? 'Bạn chưa tạo bộ thẻ nào. Hãy bấm "Thêm bộ thẻ" để bắt đầu!' : 'No custom decks created yet.')
              : (currentLang === 'vi' ? 'Thử đổi bộ lọc hoặc xóa từ khóa tìm kiếm.' : 'Try changing your search filter.')}
          </div>
          {topicId === 'my' && (
            <button className="btn btn-primary" onClick={() => setShowCreate(true)}>
              ✨ {t('decks.addDeck')}
            </button>
          )}
        </div>
      ) : (
        <div className="lesson-card-grid">
          {filteredDecks.map(deck => {
            const deckId = deck.id || deck._id;
            const isMyDeck = user?.id && deck.user_id === user.id;
            const status = getStatus(deckId);
            const { lessonLabel, cleanTitle } = parseDeckLessonInfo(deck.title);

            return (
              <div
                key={deckId}
                className="lesson-deck-card"
                onClick={() => navigate(`/decks/${deckId}`)}
              >
                <div>
                  <div className="lesson-deck-top">
                    {lessonLabel ? (
                      <span className="lesson-num-badge">{lessonLabel}</span>
                    ) : (
                      <span className="lesson-num-badge" style={{ background: 'rgba(255,255,255,0.08)', color: 'var(--text-secondary)' }}>
                        {deck.language === 'ja' ? '🇯🇵 Tiếng Nhật' : '🇬🇧 Tiếng Anh'}
                      </span>
                    )}

                    {/* Status Badge */}
                    <span
                      style={{
                        fontSize: '0.72rem',
                        padding: '2px 8px',
                        borderRadius: '6px',
                        fontWeight: '700',
                        background: status === DECK_STATUS.LEARNING ? 'rgba(34, 197, 94, 0.2)' : status === DECK_STATUS.COMPLETED ? 'rgba(59, 130, 246, 0.2)' : 'rgba(255, 255, 255, 0.08)',
                        color: status === DECK_STATUS.LEARNING ? '#4ade80' : status === DECK_STATUS.COMPLETED ? '#60a5fa' : '#94a3b8'
                      }}
                    >
                      {status === DECK_STATUS.LEARNING ? '🟢 ĐANG HỌC' : status === DECK_STATUS.COMPLETED ? '🔵 ĐÃ THUỘC' : '⚪ CHƯA HỌC'}
                    </span>
                  </div>

                  <h3 className="lesson-title" style={{ marginTop: '0.6rem', marginBottom: '0.35rem' }}>
                    {cleanTitle}
                  </h3>

                  <p className="lesson-desc">
                    {deck.description || (currentLang === 'vi' ? 'Luyện tập từ vựng chủ đề này' : 'Study vocabulary cards')}
                  </p>
                </div>

                <div className="lesson-deck-footer">
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    📇 {deck.card_count || deck.cardCount || 0} {currentLang === 'vi' ? 'từ' : 'cards'}
                  </span>

                  <div style={{ display: 'flex', gap: '0.4rem', alignItems: 'center' }}>
                    <button
                      className="btn btn-primary btn-sm"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/decks/${deckId}`);
                      }}
                      style={{ padding: '0.35rem 0.75rem', fontSize: '0.8rem' }}
                    >
                      {currentLang === 'vi' ? 'Vào học ➜' : 'Study ➜'}
                    </button>

                    {isMyDeck && (
                      <button
                        className="btn btn-ghost btn-sm"
                        onClick={(e) => deleteDeck(deck, e)}
                        style={{ color: 'var(--accent-red)', padding: '0.35rem 0.5rem' }}
                        title="Xóa bộ thẻ"
                      >
                        🗑️
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Create Modal for My Decks */}
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

export default TopicDecksPage;
