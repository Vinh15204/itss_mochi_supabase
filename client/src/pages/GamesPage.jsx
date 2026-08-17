import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useSpeech } from '../hooks/useSpeech';
import { useDeckStatus } from '../hooks/useDeckStatus';

const GamesPage = () => {
  const [decks, setDecks] = useState([]);
  const [selectedDeck, setSelectedDeck] = useState(null);
  const [cards, setCards] = useState([]);
  const [activeGame, setActiveGame] = useState(null); // null | 'penalty' | 'match' | 'scramble' | 'memory'
  const [loading, setLoading] = useState(true);
  const [gameLoading, setGameLoading] = useState(false);
  const { user } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const { currentLang } = useTranslation();
  const { speak } = useSpeech();
  const navigate = useNavigate();

  // Load user decks
  const loadDecks = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('decks')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setDecks(data || []);
      if (data && data.length > 0) {
        setSelectedDeck(data[0]);
      }
    } catch (err) {
      console.error('Error loading decks for games:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi tải danh sách bộ thẻ' : 'Failed to load decks', 'error');
    } finally {
      setLoading(false);
    }
  }, [currentLang, addToast]);

  useEffect(() => {
    loadDecks();
  }, [loadDecks]);

  // Load cards for selected deck
  const loadCardsForDeck = async (deck) => {
    if (!deck) return [];
    setGameLoading(true);
    try {
      const { data, error } = await supabase
        .from('cards')
        .select('*')
        .eq('deck_id', deck.id || deck._id);

      if (error) throw error;
      const validCards = (data || []).filter(c => c.front && c.back);
      setCards(validCards);
      return validCards;
    } catch (err) {
      console.error('Error loading cards:', err);
      addToast(currentLang === 'vi' ? 'Lỗi khi lấy từ vựng' : 'Failed to load words', 'error');
      return [];
    } finally {
      setGameLoading(false);
    }
  };

  const {
    getStatus,
    setStatus,
    learningDecks,
    notStartedDecks,
    completedDecks,
    DECK_STATUS
  } = useDeckStatus(decks);

  const [statusTab, setStatusTab] = useState(DECK_STATUS.LEARNING); // Mặc định chỉ hiện 'learning'
  const [showAddDeckModal, setShowAddDeckModal] = useState(false);
  const [modalSearch, setModalSearch] = useState('');

  // Tự động chọn deck đầu tiên của tab hiện tại nếu deck hiện tại không nằm trong danh sách
  const currentTabDecks = statusTab === DECK_STATUS.LEARNING
    ? learningDecks
    : statusTab === DECK_STATUS.COMPLETED
    ? completedDecks
    : notStartedDecks;

  useEffect(() => {
    if (currentTabDecks.length > 0) {
      const exists = currentTabDecks.some(d => (d.id || d._id) === (selectedDeck?.id || selectedDeck?._id));
      if (!exists) {
        setSelectedDeck(currentTabDecks[0]);
        loadCardsForDeck(currentTabDecks[0]);
      }
    } else if (decks.length > 0 && learningDecks.length === 0 && statusTab === DECK_STATUS.LEARNING) {
      setSelectedDeck(null);
      setCards([]);
    }
  }, [statusTab, currentTabDecks, selectedDeck, decks.length, learningDecks.length]);

  const handleSelectDeck = async (deck) => {
    setSelectedDeck(deck);
    await loadCardsForDeck(deck);
  };

  const toggleDeckStatus = (e, deckId, newStatus) => {
    e.stopPropagation();
    setStatus(deckId, newStatus);
    const msg = newStatus === DECK_STATUS.LEARNING 
      ? 'Đã thêm vào danh sách Đang học!' 
      : newStatus === DECK_STATUS.COMPLETED 
      ? 'Đã đánh dấu Đã học xong!' 
      : 'Đã chuyển về Chưa học';
    addToast(msg, 'success');
  };

  const startNewGame = async (gameType) => {
    if (!selectedDeck) {
      addToast(currentLang === 'vi' ? 'Vui lòng chọn một bộ thẻ Đang học để chơi!' : 'Please select an active deck!', 'error');
      return;
    }
    const activeCards = await loadCardsForDeck(selectedDeck);
    if (activeCards.length < 4) {
      addToast(
        currentLang === 'vi'
          ? 'Bộ thẻ này cần ít nhất 4 từ vựng để chơi game!'
          : 'This deck needs at least 4 words to play games!',
        'error'
      );
      return;
    }
    setActiveGame(gameType);
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  return (
    <div>
      <ToastContainer />
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">🎮 <span className="text-gradient">Games Học Từ Vựng IOE</span></h1>
          <p className="page-subtitle">Vừa chơi vừa nhớ từ vựng cực nhanh cùng các Mini-Game hấp dẫn!</p>
        </div>
        {activeGame && (
          <button className="btn btn-secondary" onClick={() => setActiveGame(null)}>
            ⬅️ Quay lại sảnh Game
          </button>
        )}
      </div>

      {/* Lobby View */}
      {!activeGame ? (
        <div>
          {/* Deck selector with Status Filtering */}
          <div className="glass-card" style={{ marginBottom: '2rem', padding: '1.25rem 1.5rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem', marginBottom: '1.25rem' }}>
              <div>
                <h3 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '1.2rem' }}>
                  📚 Chọn Bộ Thẻ Để Chơi:
                </h3>
                <p style={{ margin: '0.25rem 0 0', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                  {statusTab === DECK_STATUS.LEARNING && 'Chỉ hiển thị các bộ thẻ bạn ĐANG HỌC giúp tập trung tối đa!'}
                  {statusTab === DECK_STATUS.NOT_STARTED && 'Các bộ thẻ CHƯA HỌC trong kho học liệu'}
                  {statusTab === DECK_STATUS.COMPLETED && 'Các bộ thẻ bạn ĐÃ THUỘC & HOÀN THÀNH'}
                </p>
              </div>

              {/* Status Filter Tabs & Add Button */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
                <div style={{ display: 'flex', background: 'rgba(255,255,255,0.06)', padding: '3px', borderRadius: '10px', border: '1px solid rgba(255,255,255,0.1)' }}>
                  <button
                    type="button"
                    className={`btn ${statusTab === DECK_STATUS.LEARNING ? 'btn-primary' : 'btn-ghost'}`}
                    onClick={() => setStatusTab(DECK_STATUS.LEARNING)}
                    style={{ padding: '0.4rem 0.85rem', fontSize: '0.8rem', borderRadius: '8px' }}
                  >
                    🟢 Đang học ({learningDecks.length})
                  </button>
                  <button
                    type="button"
                    className={`btn ${statusTab === DECK_STATUS.NOT_STARTED ? 'btn-primary' : 'btn-ghost'}`}
                    onClick={() => setStatusTab(DECK_STATUS.NOT_STARTED)}
                    style={{ padding: '0.4rem 0.85rem', fontSize: '0.8rem', borderRadius: '8px' }}
                  >
                    ⚪ Chưa học ({notStartedDecks.length})
                  </button>
                  <button
                    type="button"
                    className={`btn ${statusTab === DECK_STATUS.COMPLETED ? 'btn-primary' : 'btn-ghost'}`}
                    onClick={() => setStatusTab(DECK_STATUS.COMPLETED)}
                    style={{ padding: '0.4rem 0.85rem', fontSize: '0.8rem', borderRadius: '8px' }}
                  >
                    🔵 Đã học ({completedDecks.length})
                  </button>
                </div>

                <button
                  type="button"
                  className="btn btn-outline"
                  onClick={() => setShowAddDeckModal(true)}
                  style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem', whiteSpace: 'nowrap' }}
                >
                  ➕ Thêm bộ đang học
                </button>
              </div>
            </div>

            {/* Deck List or Empty State */}
            {currentTabDecks.length === 0 ? (
              <div className="empty-state" style={{ padding: '2rem 1rem', textAlign: 'center', background: 'rgba(255,255,255,0.02)', borderRadius: '12px', border: '1px dashed rgba(255,255,255,0.15)' }}>
                <div style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>
                  {statusTab === DECK_STATUS.LEARNING ? '🎯' : statusTab === DECK_STATUS.COMPLETED ? '🏆' : '📦'}
                </div>
                <h4 style={{ margin: '0 0 0.5rem', color: '#fff' }}>
                  {statusTab === DECK_STATUS.LEARNING && 'Chưa có bộ thẻ nào trong mục "Đang học"'}
                  {statusTab === DECK_STATUS.NOT_STARTED && 'Tất cả các bộ thẻ đều đã được đưa vào học!'}
                  {statusTab === DECK_STATUS.COMPLETED && 'Chưa có bộ thẻ nào hoàn thành'}
                </h4>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '1rem' }}>
                  {statusTab === DECK_STATUS.LEARNING && 'Hãy bấm nút bên dưới để chọn các bài học bạn muốn chơi và ôn luyện hôm nay.'}
                </p>
                {statusTab === DECK_STATUS.LEARNING && (
                  <button className="btn btn-primary" onClick={() => setShowAddDeckModal(true)}>
                    ➕ Chọn Bộ Thẻ Vào "Đang Học"
                  </button>
                )}
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: '0.875rem' }}>
                {currentTabDecks.map(deck => {
                  const deckId = deck.id || deck._id;
                  const isSelected = selectedDeck?.id === deckId || selectedDeck?._id === deckId;
                  const currentStatus = getStatus(deckId);

                  return (
                    <div
                      key={deckId}
                      onClick={() => handleSelectDeck(deck)}
                      className={`glass-card ${isSelected ? 'active-deck-card' : ''}`}
                      style={{
                        padding: '1rem',
                        cursor: 'pointer',
                        borderRadius: '12px',
                        border: isSelected ? '2px solid #8b5cf6' : '1px solid rgba(255, 255, 255, 0.1)',
                        background: isSelected ? 'rgba(139, 92, 246, 0.18)' : 'rgba(255, 255, 255, 0.03)',
                        transition: 'all 0.2s ease',
                        position: 'relative',
                        display: 'flex',
                        flexDirection: 'column',
                        justifyContent: 'space-between'
                      }}
                    >
                      <div>
                        {/* Header: Flag & Status Badge */}
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                          <span style={{ fontSize: '1.2rem' }}>
                            {deck.language === 'ja' ? '🇯🇵' : '🇬🇧'}
                          </span>
                          <span style={{
                            fontSize: '0.7rem',
                            padding: '2px 7px',
                            borderRadius: '6px',
                            fontWeight: '700',
                            background: currentStatus === DECK_STATUS.LEARNING ? 'rgba(34, 197, 94, 0.2)' : currentStatus === DECK_STATUS.COMPLETED ? 'rgba(59, 130, 246, 0.2)' : 'rgba(255, 255, 255, 0.1)',
                            color: currentStatus === DECK_STATUS.LEARNING ? '#4ade80' : currentStatus === DECK_STATUS.COMPLETED ? '#60a5fa' : '#94a3b8'
                          }}>
                            {currentStatus === DECK_STATUS.LEARNING ? 'ĐANG HỌC' : currentStatus === DECK_STATUS.COMPLETED ? 'ĐÃ THUỘC' : 'CHƯA HỌC'}
                          </span>
                        </div>

                        {/* Title */}
                        <div style={{ fontWeight: '600', fontSize: '0.95rem', color: '#fff', marginBottom: '0.35rem', lineHeight: '1.4' }}>
                          {deck.title}
                        </div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                          {deck.card_count || deck.cardCount || 15} từ vựng
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Modal Quản lý / Thêm Bộ Thẻ Vào "Đang Học" */}
          {showAddDeckModal && (
            <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: '1rem' }}>
              <div className="glass-card" style={{ maxWidth: '640px', width: '100%', maxHeight: '85vh', display: 'flex', flexDirection: 'column', padding: '1.5rem', background: '#181826', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.15)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700' }}>📚 Kho Bộ Thẻ – Thêm Vào "Đang Học"</h3>
                    <p style={{ margin: '0.2rem 0 0', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                      Chọn nhanh các bài học bạn muốn luyện tập trong Games
                    </p>
                  </div>
                  <button className="btn btn-ghost" onClick={() => setShowAddDeckModal(false)} style={{ fontSize: '1.25rem', padding: '0.25rem 0.6rem' }}>
                    ✕
                  </button>
                </div>

                <div style={{ marginBottom: '1rem' }}>
                  <input
                    type="text"
                    placeholder="🔍 Tìm theo tên bộ thẻ (IT, Y khoa, Kinh tế, TOEIC, IELTS)..."
                    value={modalSearch}
                    onChange={(e) => setModalSearch(e.target.value)}
                    style={{ width: '100%', padding: '0.65rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff', fontSize: '0.9rem' }}
                  />
                </div>

                <div style={{ overflowY: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: '0.5rem', paddingRight: '4px' }}>
                  {decks
                    .filter(d => (d.title || '').toLowerCase().includes(modalSearch.toLowerCase()))
                    .map(deck => {
                      const deckId = deck.id || deck._id;
                      const currentStatus = getStatus(deckId);
                      const isLearning = currentStatus === DECK_STATUS.LEARNING;

                      return (
                        <div
                          key={deckId}
                          style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            padding: '0.75rem 1rem',
                            borderRadius: '10px',
                            background: isLearning ? 'rgba(34, 197, 94, 0.08)' : 'rgba(255,255,255,0.03)',
                            border: isLearning ? '1px solid rgba(34, 197, 94, 0.3)' : '1px solid rgba(255,255,255,0.06)'
                          }}
                        >
                          <div>
                            <div style={{ fontWeight: '600', color: '#fff', fontSize: '0.9rem' }}>
                              {deck.language === 'ja' ? '🇯🇵' : '🇬🇧'} {deck.title}
                            </div>
                            <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                              {deck.card_count || deck.cardCount || 15} từ vựng
                            </div>
                          </div>

                          <button
                            type="button"
                            className={`btn ${isLearning ? 'btn-secondary' : 'btn-primary'}`}
                            onClick={() => toggleDeckStatus({ stopPropagation: () => {} }, deckId, isLearning ? DECK_STATUS.NOT_STARTED : DECK_STATUS.LEARNING)}
                            style={{ padding: '0.4rem 0.85rem', fontSize: '0.8rem', minWidth: '110px' }}
                          >
                            {isLearning ? '✕ Bỏ chọn' : '➕ Đang học'}
                          </button>
                        </div>
                      );
                    })}
                </div>

                <div style={{ marginTop: '1rem', paddingTop: '1rem', borderTop: '1px solid rgba(255,255,255,0.1)', display: 'flex', justifyContent: 'flex-end' }}>
                  <button className="btn btn-primary" onClick={() => setShowAddDeckModal(false)}>
                    ✅ Hoàn tất & Chơi game ({learningDecks.length} bộ đang học)
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Games Selection List */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1.5rem' }}>
            {/* Game IOE Penalty Shootout */}
            <div className="glass-card" style={{ padding: '1.5rem', borderRadius: '16px', border: '2px solid #0099ff', background: 'linear-gradient(135deg, rgba(0, 153, 255, 0.15) 0%, rgba(0, 102, 204, 0.05) 100%)' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚽</div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 'bold', marginBottom: '0.5rem', color: '#38bdf8' }}>Sút Phạt IOE Pro ⚽</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.5rem', minHeight: '40px' }}>
                Game bóng đá sút penalty trắc nghiệm phong cách IOE chuyên nghiệp! Đồ họa 3D sân cỏ, đáp án A-B-C-D sút ăn mừng SIUUU!
              </p>
              <button
                className="btn"
                style={{ width: '100%', background: 'linear-gradient(135deg, #0099ff 0%, #0066cc 100%)', color: '#ffffff', fontWeight: 'bold' }}
                onClick={() => startNewGame('penalty')}
                disabled={gameLoading || !selectedDeck}
              >
                ⚽ Chơi Sút Phạt IOE
              </button>
            </div>

            {/* Game 1: Word Match */}
            <div className="glass-card" style={{ padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🧩</div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>Word Match (Nối Từ)</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.5rem', minHeight: '40px' }}>
                Nối nhanh các thẻ Từ Vựng và Nghĩa tương ứng trước khi hết giờ!
              </p>
              <button
                className="btn btn-primary"
                style={{ width: '100%' }}
                onClick={() => startNewGame('match')}
                disabled={gameLoading || !selectedDeck}
              >
                🎮 Chơi Nối Từ
              </button>
            </div>

            {/* Game 2: Word Scramble */}
            <div className="glass-card" style={{ padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🔤</div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>Word Scramble (Gỡ Rối Chữ)</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.5rem', minHeight: '40px' }}>
                Xếp lại các chữ cái xáo trộn để tìm ra từ chính xác dựa theo gợi ý nghĩa.
              </p>
              <button
                className="btn btn-primary"
                style={{ width: '100%' }}
                onClick={() => startNewGame('scramble')}
                disabled={gameLoading || !selectedDeck}
              >
                🎮 Chơi Gỡ Rối Chữ
              </button>
            </div>

            {/* Game 3: Memory Flip */}
            <div className="glass-card" style={{ padding: '1.5rem', borderRadius: '16px' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🃏</div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>Memory Flip (Lật Bài)</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.5rem', minHeight: '40px' }}>
                Lật thẻ bài 3D và ghi nhớ vị trí cặp từ - nghĩa để mở toàn bộ bộ bài!
              </p>
              <button
                className="btn btn-primary"
                style={{ width: '100%' }}
                onClick={() => startNewGame('memory')}
                disabled={gameLoading || !selectedDeck}
              >
                🎮 Chơi Lật Bài
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* Game Arena Render */
        <div>
          {activeGame === 'penalty' && <IOEPenaltyGame cards={cards} deck={selectedDeck} user={user} speak={speak} onRestart={() => startNewGame('penalty')} />}
          {activeGame === 'match' && <WordMatchGame cards={cards} deck={selectedDeck} speak={speak} onRestart={() => startNewGame('match')} />}
          {activeGame === 'scramble' && <WordScrambleGame cards={cards} deck={selectedDeck} speak={speak} onRestart={() => startNewGame('scramble')} />}
          {activeGame === 'memory' && <MemoryFlipGame cards={cards} deck={selectedDeck} speak={speak} onRestart={() => startNewGame('memory')} />}
        </div>
      )}
    </div>
  );
};

/* -------------------------------------------------------------------------
   PRO IOE PENALTY SHOOTOUT GAME (3D PRO GRAPHICS & PHYSICS)
   ------------------------------------------------------------------------- */
const IOEPenaltyGame = ({ cards, deck, user, speak, onRestart }) => {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [options, setOptions] = useState([]);
  const [score, setScore] = useState(0);
  const [secondsLeft, setSecondsLeft] = useState(180); // 3:00 timer like IOE
  const [kickStatus, setKickStatus] = useState(null); // null | 'goal' | 'miss'
  const [keeperState, setKeeperState] = useState({ pose: 'center', x: 0, y: 0, rot: 0 });
  const [ballState, setBallState] = useState({ x: 0, y: 0, scale: 1, rot: 0, shadowY: 0, isKicked: false });
  const [gameOver, setGameOver] = useState(false);

  const currentCard = cards[currentIdx];
  const userName = user?.username || 'hocsinh123';

  // Format seconds to MM:SS
  const formatTime = (secs) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  // Timer effect
  useEffect(() => {
    if (gameOver || secondsLeft <= 0) return;
    const interval = setInterval(() => {
      setSecondsLeft(prev => {
        if (prev <= 1) {
          setGameOver(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [secondsLeft, gameOver]);

  // Reset ball & keeper for new question
  const prepareQuestion = useCallback(() => {
    if (!currentCard) return;
    const correct = currentCard.back || currentCard.front;
    const otherCards = cards.filter(c => (c.id || c._id) !== (currentCard.id || currentCard._id) && c.back);
    const shuffledOthers = [...otherCards].sort(() => 0.5 - Math.random()).map(c => c.back).slice(0, 3);

    while (shuffledOthers.length < 3) {
      shuffledOthers.push(`Lựa chọn ${shuffledOthers.length + 1}`);
    }

    const allOptions = [...shuffledOthers, correct].sort(() => 0.5 - Math.random());
    setOptions(allOptions);
    setKickStatus(null);
    setKeeperState({ pose: 'center', x: 0, y: 0, rot: 0 });
    setBallState({ x: 0, y: 0, scale: 1, rot: 0, shadowY: 0, isKicked: false });
  }, [currentCard, cards]);

  useEffect(() => {
    prepareQuestion();
  }, [currentIdx, prepareQuestion]);

  const handleSelectOption = (selectedOption, optionIdx) => {
    if (kickStatus !== null || !currentCard) return;

    const isCorrect = selectedOption === (currentCard.back || currentCard.front);

    // Dynamic 3D ball trajectory targets (dx, dy in px relative to center penalty spot)
    // 0: A (Top-Left), 1: B (Top-Right), 2: C (Bottom-Left), 3: D (Bottom-Right)
    const ballTargets = [
      { x: -170, y: -200, scale: 0.6, rot: 720, shadowY: 190 }, // Top-Left corner
      { x: 170, y: -200, scale: 0.6, rot: -720, shadowY: 190 }, // Top-Right corner
      { x: -180, y: -130, scale: 0.68, rot: 540, shadowY: 120 }, // Bottom-Left corner
      { x: 180, y: -130, scale: 0.68, rot: -540, shadowY: 120 }  // Bottom-Right corner
    ];

    // Goalkeeper diving physics
    const diveDirections = [
      { pose: 'dive-left', x: -180, y: -40, rot: -38 },   // Top-Left dive
      { pose: 'dive-right', x: 180, y: -40, rot: 38 },    // Top-Right dive
      { pose: 'dive-left', x: -170, y: 0, rot: -28 },     // Low-Left dive
      { pose: 'dive-right', x: 170, y: 0, rot: 28 }      // Low-Right dive
    ];

    const targetBall = ballTargets[optionIdx] || { x: 0, y: -160, scale: 0.6, rot: 720, shadowY: 150 };

    // Goalkeeper dives WRONG direction if correct, or SAVES if wrong
    const keeperDive = isCorrect
      ? (optionIdx % 2 === 0 ? diveDirections[1] : diveDirections[0]) // Wrong dive
      : diveDirections[optionIdx]; // Save dive

    setBallState({
      x: targetBall.x,
      y: targetBall.y,
      scale: targetBall.scale,
      rot: targetBall.rot,
      shadowY: targetBall.shadowY,
      isKicked: true
    });

    setKeeperState(keeperDive);

    setTimeout(() => {
      if (isCorrect) {
        setKickStatus('goal');
        setScore(s => s + 10);
        speak(currentCard.front, deck?.language);
      } else {
        setKickStatus('miss');
      }

      // Next question delay
      setTimeout(() => {
        if (currentIdx < cards.length - 1) {
          setCurrentIdx(i => i + 1);
        } else {
          setGameOver(true);
        }
      }, 1900);
    }, 480);
  };

  if (!currentCard) return null;

  return (
    <div style={{
      maxWidth: '1150px',
      width: '100%',
      margin: '0 auto',
      borderRadius: '24px',
      overflow: 'hidden',
      boxShadow: '0 20px 60px rgba(0, 0, 0, 0.8)',
      border: '4px solid #0099ff',
      background: '#040914',
      position: 'relative'
    }}>
      {/* 1. TOP QUESTION BANNER (HD Blue Banner with dashed border) */}
      <div style={{
        background: 'linear-gradient(180deg, #00c3ff 0%, #0077ff 100%)',
        border: '3px dashed #ffffff',
        margin: '14px 16px 0 16px',
        borderRadius: '16px',
        padding: '16px 26px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
        boxShadow: '0 6px 20px rgba(0, 119, 255, 0.45)'
      }}>
        <div style={{
          position: 'absolute',
          left: '22px',
          background: '#ffffff',
          width: '46px',
          height: '46px',
          borderRadius: '50%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '2rem',
          boxShadow: '0 4px 8px rgba(0,0,0,0.3)'
        }}>
          ⚽
        </div>
        <div style={{
          color: '#ffffff',
          fontSize: '1.7rem',
          fontWeight: '800',
          textAlign: 'center',
          fontFamily: deck?.language === 'ja' ? 'var(--font-japanese)' : 'sans-serif',
          textShadow: '0 2px 6px rgba(0,0,0,0.5)'
        }}>
          {deck?.language === 'ja' ? `Nghĩa của từ "${currentCard.front}" là gì?` : `What is the meaning of "${currentCard.front}"?`}
        </div>
      </div>

      {/* 2. REALISTIC 2.5D PRO STADIUM FIELD ARENA (440px Height) */}
      <div style={{
        position: 'relative',
        height: '440px',
        background: 'radial-gradient(ellipse at center top, #1e293b 0%, #050a14 50%, #020617 100%)',
        overflow: 'hidden'
      }}>
        {/* Stadium Floodlights Glow Effect */}
        <div style={{
          position: 'absolute',
          top: '-50px',
          left: '15%',
          width: '200px',
          height: '200px',
          background: 'radial-gradient(circle, rgba(56, 189, 248, 0.25) 0%, transparent 70%)',
          pointerEvents: 'none'
        }}></div>
        <div style={{
          position: 'absolute',
          top: '-50px',
          right: '15%',
          width: '200px',
          height: '200px',
          background: 'radial-gradient(circle, rgba(56, 189, 248, 0.25) 0%, transparent 70%)',
          pointerEvents: 'none'
        }}></div>

        {/* Crowd Spectators & Flags Silhouette at top */}
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '110px',
          background: 'linear-gradient(180deg, #090d16 0%, #0f172a 100%)',
          display: 'flex',
          justifyContent: 'space-around',
          alignItems: 'flex-end',
          paddingBottom: '8px',
          opacity: 0.95
        }}>
          <div style={{ fontSize: '1.9rem' }}>🚩👥👥🚩👥👥🚩👥</div>
          <div style={{ fontSize: '1.9rem' }}>👥👥🚩👥👥🚩👥👥</div>
          <div style={{ fontSize: '1.9rem' }}>🚩👥👥🚩👥👥🚩👥</div>
        </div>

        {/* Top-Left IOE User & Score Badge */}
        <div style={{
          position: 'absolute',
          top: '120px',
          left: '25px',
          zIndex: 15,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start'
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            background: 'rgba(5, 10, 20, 0.85)',
            padding: '8px 16px',
            borderRadius: '12px',
            border: '2px solid #ff9900',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}>
            <div style={{
              background: '#ff9900',
              padding: '6px',
              borderRadius: '8px',
              color: '#ffffff',
              fontSize: '1.4rem'
            }}>
              👤
            </div>
            <div>
              <div style={{ color: '#ffff00', fontWeight: 'bold', fontSize: '1.1rem' }}>
                Score: <span style={{ color: '#ffffff' }}>{score}</span>
              </div>
              <div style={{ color: '#ffff00', fontWeight: 'bold', fontSize: '0.95rem' }}>
                Question: <span style={{ color: '#ffffff' }}>{currentIdx + 1}/{cards.length}</span>
              </div>
            </div>
          </div>
          <div style={{ color: '#a3e635', fontWeight: 'bold', fontSize: '1.1rem', marginTop: '6px', textShadow: '0 2px 4px #000' }}>
            {userName}
          </div>
        </div>

        {/* Top-Right Big Timer */}
        <div style={{
          position: 'absolute',
          top: '120px',
          right: '30px',
          zIndex: 15,
          color: '#ffffff',
          fontSize: '2.6rem',
          fontWeight: '900',
          fontFamily: 'monospace',
          textShadow: '0 3px 12px rgba(0,0,0,0.9)'
        }}>
          {formatTime(secondsLeft)}
        </div>

        {/* PRO LUSH TURF GRASS FIELD (Perspected Pitch Container) */}
        <div style={{
          position: 'absolute',
          top: '110px',
          left: 0,
          right: 0,
          bottom: 0,
          background: 'repeating-linear-gradient(90deg, #15803d 0px, #15803d 45px, #16a34a 45px, #16a34a 90px)',
          boxShadow: 'inset 0 20px 40px rgba(0,0,0,0.7)',
          overflow: 'hidden'
        }}>
          {/* Subtle grass field depth gradient */}
          <div style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(180deg, rgba(0,0,0,0.4) 0%, rgba(0,0,0,0.05) 50%, rgba(0,0,0,0.2) 100%)'
          }}></div>

          {/* White Court Boundary & Penalty Area Box */}
          <div style={{
            position: 'absolute',
            top: '145px',
            left: 0,
            right: 0,
            height: '5px',
            background: '#ffffff',
            boxShadow: '0 2px 6px rgba(0,0,0,0.4)'
          }}></div>
          <div style={{
            position: 'absolute',
            top: '145px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: '560px',
            height: '185px',
            border: '5px solid #ffffff',
            borderTop: 'none',
            boxShadow: '0 2px 6px rgba(0,0,0,0.3)'
          }}></div>

          {/* Goal Area Semi-Circle Arc */}
          <div style={{
            position: 'absolute',
            top: '330px',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '180px',
            height: '80px',
            border: '5px solid #ffffff',
            borderRadius: '0 0 90px 90px',
            borderTop: 'none'
          }}></div>

          {/* White Penalty Spot */}
          <div style={{
            position: 'absolute',
            top: '240px',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '16px',
            height: '16px',
            borderRadius: '50%',
            background: '#ffffff',
            boxShadow: '0 2px 6px rgba(0,0,0,0.5)'
          }}></div>

          {/* PRO 3D METALLIC GOAL POST FRAME */}
          <div style={{
            position: 'absolute',
            top: '10px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: '500px',
            height: '180px',
            zIndex: 3
          }}>
            {/* Net mesh background */}
            <div style={{
              position: 'absolute',
              inset: 0,
              background: 'repeating-linear-gradient(0deg, transparent, transparent 10px, rgba(255,255,255,0.25) 10px, rgba(255,255,255,0.25) 11px), repeating-linear-gradient(90deg, transparent, transparent 10px, rgba(255,255,255,0.25) 10px, rgba(255,255,255,0.25) 11px)',
              borderRadius: '10px 10px 0 0',
              boxShadow: 'inset 0 0 30px rgba(0,0,0,0.6)'
            }}></div>

            {/* Top metallic crossbar */}
            <div style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              height: '10px',
              background: 'linear-gradient(180deg, #ffffff 0%, #cbd5e1 50%, #64748b 100%)',
              borderRadius: '5px',
              boxShadow: '0 4px 10px rgba(0,0,0,0.5)'
            }}></div>

            {/* Left metallic post */}
            <div style={{
              position: 'absolute',
              top: 0,
              left: 0,
              bottom: 0,
              width: '10px',
              background: 'linear-gradient(90deg, #ffffff 0%, #cbd5e1 50%, #64748b 100%)',
              borderRadius: '5px 0 0 0',
              boxShadow: '4px 0 10px rgba(0,0,0,0.5)'
            }}></div>

            {/* Right metallic post */}
            <div style={{
              position: 'absolute',
              top: 0,
              right: 0,
              bottom: 0,
              width: '10px',
              background: 'linear-gradient(270deg, #ffffff 0%, #cbd5e1 50%, #64748b 100%)',
              borderRadius: '0 5px 0 0',
              boxShadow: '-4px 0 10px rgba(0,0,0,0.5)'
            }}></div>
          </div>

          {/* PRO ANIMATED GOALKEEPER WITH REALISTIC DIVE & SHADOW */}
          <div style={{
            position: 'absolute',
            top: '55px',
            left: '50%',
            transform: `translate(calc(-50% + ${keeperState.x}px), ${keeperState.y}px) rotate(${keeperState.rot}deg)`,
            transition: 'transform 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28)',
            zIndex: 6,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center'
          }}>
            {/* Goalkeeper Shadow on Pitch */}
            <div style={{
              width: '60px',
              height: '16px',
              background: 'rgba(0,0,0,0.4)',
              borderRadius: '50%',
              position: 'absolute',
              bottom: '-5px',
              filter: 'blur(4px)'
            }}></div>

            {/* Goalkeeper Image Graphic */}
            <img
              src="/image/gk.png"
              alt="Goalkeeper"
              style={{
                width: '145px',
                height: '145px',
                objectFit: 'contain',
                filter: 'drop-shadow(0 8px 12px rgba(0,0,0,0.6))',
                userSelect: 'none',
                pointerEvents: 'none'
              }}
            />
          </div>

          {/* PRO 3D FOOTBALL & DYNAMIC PITCH DROP SHADOW */}
          <div style={{
            position: 'absolute',
            top: '240px',
            left: '50%',
            transform: `translate(calc(-50% + ${ballState.x}px), ${ballState.y}px) scale(${ballState.scale})`,
            transition: 'transform 0.48s cubic-bezier(0.175, 0.885, 0.32, 1.15)',
            zIndex: 10,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            {/* Dynamic Ground Shadow that separates from ball on kick */}
            <div style={{
              position: 'absolute',
              top: `${ballState.shadowY}px`,
              width: '40px',
              height: '14px',
              background: 'rgba(0,0,0,0.5)',
              borderRadius: '50%',
              filter: 'blur(3px)',
              transform: `scale(${ballState.scale})`,
              transition: 'all 0.48s cubic-bezier(0.175, 0.885, 0.32, 1.15)'
            }}></div>

            {/* Spinning Soccer Ball */}
            <div style={{
              fontSize: '3.2rem',
              transform: `rotate(${ballState.rot}deg)`,
              transition: 'transform 0.48s ease-out',
              filter: 'drop-shadow(0 6px 14px rgba(0,0,0,0.6))',
              userSelect: 'none'
            }}>
              ⚽
            </div>
          </div>

          {/* GOAL Celebration Banner */}
          {kickStatus === 'goal' && (
            <div style={{
              position: 'absolute',
              inset: 0,
              background: 'rgba(0, 180, 0, 0.88)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              zIndex: 25,
              animation: 'popIn 0.3s ease'
            }}>
              <div style={{ fontSize: '4.2rem', fontWeight: '900', color: '#ffffff', textShadow: '0 4px 14px #000' }}>
                ⚽ GOALLL! SIUUUUU! 🔥
              </div>
              <div style={{ fontSize: '1.7rem', color: '#ffff00', marginTop: '0.75rem', fontWeight: 'bold' }}>
                +10 ĐIỂM THƯỞNG!
              </div>
            </div>
          )}

          {/* Missed Banner */}
          {kickStatus === 'miss' && (
            <div style={{
              position: 'absolute',
              inset: 0,
              background: 'rgba(220, 38, 38, 0.88)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              zIndex: 25,
              animation: 'popIn 0.3s ease'
            }}>
              <div style={{ fontSize: '3.8rem', fontWeight: '900', color: '#ffffff' }}>
                ❌ THỦ MÔN BẮT BÓNG!
              </div>
              <div style={{ fontSize: '1.4rem', color: '#ffffff', marginTop: '0.75rem' }}>
                Đáp án đúng: <strong style={{ color: '#ffff00' }}>{currentCard.back || currentCard.front}</strong>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* 3. BOTTOM IOE HEXAGONAL ANSWER BUTTONS (A, B, C, D) */}
      {!gameOver ? (
        <div style={{
          background: '#040914',
          padding: '24px 30px',
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '18px 30px',
          position: 'relative'
        }}>
          {options.map((opt, idx) => {
            const letter = String.fromCharCode(65 + idx); // A, B, C, D
            return (
              <button
                key={idx}
                onClick={() => handleSelectOption(opt, idx)}
                disabled={kickStatus !== null}
                style={{
                  background: 'linear-gradient(180deg, #00aaff 0%, #0077ee 100%)',
                  border: '3px dashed #ffffff',
                  borderRadius: '18px',
                  padding: '18px 26px',
                  color: '#ffffff',
                  fontWeight: 'bold',
                  fontSize: '1.3rem',
                  display: 'flex',
                  alignItems: 'center',
                  cursor: kickStatus !== null ? 'not-allowed' : 'pointer',
                  boxShadow: '0 8px 16px rgba(0,119,238,0.4)',
                  transition: 'all 0.2s ease',
                  textAlign: 'left',
                  clipPath: 'polygon(5% 0%, 95% 0%, 100% 50%, 95% 100%, 5% 100%, 0% 50%)' // IOE Hexagonal shape
                }}
                onMouseOver={(e) => {
                  if (kickStatus === null) e.currentTarget.style.transform = 'scale(1.03)';
                }}
                onMouseOut={(e) => {
                  e.currentTarget.style.transform = 'scale(1)';
                }}
              >
                <span style={{ fontSize: '1.5rem', color: '#ffffff', marginRight: '14px' }}>
                  {letter} :
                </span>
                <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {opt}
                </span>
              </button>
            );
          })}
        </div>
      ) : (
        /* Victory Screen */
        <div style={{ padding: '4rem 2rem', textAlign: 'center', background: '#0a0f1d' }}>
          <div style={{ fontSize: '6rem', marginBottom: '1rem' }}>🏆⚽</div>
          <h1 style={{ fontSize: '3rem', fontWeight: '900', color: '#38bdf8' }}>HOÀN THÀNH TRẬN ĐẤU IOE!</h1>
          <p style={{ fontSize: '1.5rem', marginTop: '1rem', color: '#ffffff' }}>
            Tổng số điểm đạt được: <strong style={{ color: '#ffff00', fontSize: '2.2rem' }}>{score} Điểm</strong>
          </p>
          <button className="btn btn-primary" onClick={onRestart} style={{ marginTop: '2.5rem', padding: '1rem 3rem', fontSize: '1.25rem' }}>
            🔄 Chơi Trận Tiếp Theo
          </button>
        </div>
      )}
    </div>
  );
};

/* -------------------------------------------------------------------------
   GAME 1: WORD MATCH (NỐI TỪ VỰNG)
   ------------------------------------------------------------------------- */
const WordMatchGame = ({ cards, deck, speak, onRestart }) => {
  const [items, setItems] = useState([]);
  const [selectedFirst, setSelectedFirst] = useState(null);
  const [matchedIds, setMatchedIds] = useState([]);
  const [score, setScore] = useState(0);
  const [combo, setCombo] = useState(0);
  const [timeLeft, setTimeLeft] = useState(60);
  const [gameOver, setGameOver] = useState(false);

  useEffect(() => {
    const shuffled = [...cards].sort(() => 0.5 - Math.random()).slice(0, 6);
    const gameItems = [];

    shuffled.forEach((card, idx) => {
      gameItems.push({ id: `front-${idx}`, cardId: card.id || card._id, text: card.front, type: 'front', reading: card.reading });
      gameItems.push({ id: `back-${idx}`, cardId: card.id || card._id, text: card.back, type: 'back' });
    });

    setItems(gameItems.sort(() => 0.5 - Math.random()));
    setMatchedIds([]);
    setScore(0);
    setCombo(0);
    setTimeLeft(60);
    setGameOver(false);
  }, [cards]);

  useEffect(() => {
    if (gameOver || timeLeft <= 0) return;
    const timer = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          setGameOver(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [timeLeft, gameOver]);

  const handleCardClick = (item) => {
    if (gameOver || matchedIds.includes(item.id)) return;

    if (!selectedFirst) {
      setSelectedFirst(item);
      if (item.type === 'front') speak(item.text, deck?.language);
      return;
    }

    if (selectedFirst.id === item.id) {
      setSelectedFirst(null);
      return;
    }

    if (selectedFirst.cardId === item.cardId && selectedFirst.type !== item.type) {
      const newMatched = [...matchedIds, selectedFirst.id, item.id];
      setMatchedIds(newMatched);
      setCombo(c => c + 1);
      const points = 100 + combo * 20;
      setScore(s => s + points);
      setSelectedFirst(null);

      if (item.type === 'front') speak(item.text, deck?.language);
      else if (selectedFirst.type === 'front') speak(selectedFirst.text, deck?.language);

      if (newMatched.length === items.length) {
        setGameOver(true);
      }
    } else {
      setCombo(0);
      setSelectedFirst(null);
    }
  };

  return (
    <div className="glass-card" style={{ padding: '2rem', textAlign: 'center' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>
          ⏱️ Thời gian: <span style={{ color: timeLeft <= 10 ? 'var(--accent-red)' : 'var(--accent-green)' }}>{timeLeft}s</span>
        </div>
        <div style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>
          🔥 Combo: <span style={{ color: 'var(--accent-yellow)' }}>{combo}x</span>
        </div>
        <div style={{ fontSize: '1.4rem', fontWeight: 'bold', color: 'var(--accent-purple-light)' }}>
          ⭐ Điểm: {score}
        </div>
      </div>

      {!gameOver ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: '1rem' }}>
          {items.map(item => {
            const isMatched = matchedIds.includes(item.id);
            const isSelected = selectedFirst?.id === item.id;
            return (
              <div
                key={item.id}
                onClick={() => handleCardClick(item)}
                style={{
                  padding: '1.25rem 1rem',
                  borderRadius: '12px',
                  background: isMatched
                    ? 'rgba(34, 197, 94, 0.2)'
                    : isSelected
                      ? 'rgba(168, 85, 247, 0.3)'
                      : 'var(--bg-glass)',
                  border: isMatched
                    ? '2px solid var(--accent-green)'
                    : isSelected
                      ? '2px solid var(--accent-purple-light)'
                      : '1px solid rgba(255, 255, 255, 0.1)',
                  cursor: isMatched ? 'default' : 'pointer',
                  opacity: isMatched ? 0.4 : 1,
                  transform: isSelected ? 'scale(1.05)' : 'scale(1)',
                  transition: 'all 0.2s ease',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  minHeight: '90px'
                }}
              >
                <div style={{
                  fontSize: item.type === 'front' ? '1.3rem' : '1rem',
                  fontWeight: item.type === 'front' ? 'bold' : 'normal',
                  fontFamily: item.type === 'front' && deck?.language === 'ja' ? 'var(--font-japanese)' : 'inherit'
                }}>
                  {item.text}
                </div>
                {item.reading && (
                  <div style={{ fontSize: '0.75rem', color: 'var(--accent-purple-light)', marginTop: '0.25rem' }}>
                    {item.reading}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      ) : (
        <div style={{ padding: '2rem 0' }}>
          <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🎉</div>
          <h2>{matchedIds.length === items.length ? 'Xuất Sắc! Đã Hoàn Thành!' : 'Hết Giờ!'}</h2>
          <p style={{ fontSize: '1.2rem', marginTop: '0.5rem', color: 'var(--text-secondary)' }}>
            Tổng điểm của bạn: <strong style={{ color: 'var(--accent-purple-light)' }}>{score}</strong>
          </p>
          <button className="btn btn-primary" onClick={onRestart} style={{ marginTop: '1.5rem', padding: '0.75rem 2rem' }}>
            🔄 Chơi Lại Game Này
          </button>
        </div>
      )}
    </div>
  );
};

/* -------------------------------------------------------------------------
   GAME 2: WORD SCRAMBLE (GỠ RỐI CHỮ)
   ------------------------------------------------------------------------- */
const WordScrambleGame = ({ cards, deck, speak, onRestart }) => {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [scrambled, setScrambled] = useState([]);
  const [userGuess, setUserGuess] = useState([]);
  const [score, setScore] = useState(0);
  const [gameOver, setGameOver] = useState(false);
  const [message, setMessage] = useState('');

  const targetCard = cards[currentIdx];

  useEffect(() => {
    if (!targetCard) return;
    const letters = targetCard.front.split('');
    const shuffled = [...letters].sort(() => 0.5 - Math.random());
    setScrambled(shuffled.map((char, i) => ({ id: i, char, used: false })));
    setUserGuess([]);
    setMessage('');
  }, [targetCard, currentIdx]);

  const handlePickLetter = (item) => {
    if (item.used) return;
    setUserGuess(prev => [...prev, item]);
    setScrambled(prev => prev.map(l => l.id === item.id ? { ...l, used: true } : l));
  };

  const handleRemoveGuess = (item) => {
    setUserGuess(prev => prev.filter(l => l.id !== item.id));
    setScrambled(prev => prev.map(l => l.id === item.id ? { ...l, used: false } : l));
  };

  const handleCheckAnswer = () => {
    const guessedWord = userGuess.map(l => l.char).join('');
    if (guessedWord.toLowerCase() === targetCard.front.toLowerCase()) {
      setMessage('✅ Chính xác!');
      speak(targetCard.front, deck?.language);
      setScore(s => s + 150);

      setTimeout(() => {
        if (currentIdx < cards.length - 1) {
          setCurrentIdx(i => i + 1);
        } else {
          setGameOver(true);
        }
      }, 1000);
    } else {
      setMessage('❌ Chưa đúng rồi, thử lại nhé!');
    }
  };

  if (!targetCard) return null;

  return (
    <div className="glass-card" style={{ padding: '2rem', textAlign: 'center', maxWidth: '600px', margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <div>Câu {currentIdx + 1}/{cards.length}</div>
        <div style={{ fontWeight: 'bold', color: 'var(--accent-purple-light)', fontSize: '1.2rem' }}>⭐ Điểm: {score}</div>
      </div>

      {!gameOver ? (
        <div>
          <div style={{ background: 'rgba(255, 255, 255, 0.05)', padding: '1rem', borderRadius: '12px', marginBottom: '1.5rem' }}>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>Gợi ý nghĩa:</div>
            <div style={{ fontSize: '1.2rem', fontWeight: 'bold', marginTop: '0.25rem' }}>{targetCard.back}</div>
            {targetCard.reading && <div style={{ color: 'var(--accent-purple-light)', marginTop: '0.25rem' }}>{targetCard.reading}</div>}
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', gap: '0.5rem', marginBottom: '1.5rem', minHeight: '50px' }}>
            {userGuess.map(item => (
              <div
                key={item.id}
                onClick={() => handleRemoveGuess(item)}
                style={{
                  width: '44px',
                  height: '48px',
                  borderRadius: '8px',
                  background: 'rgba(124, 58, 237, 0.3)',
                  border: '2px solid var(--accent-purple-light)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '1.4rem',
                  fontWeight: 'bold',
                  cursor: 'pointer'
                }}
              >
                {item.char}
              </div>
            ))}
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', gap: '0.5rem', flexWrap: 'wrap', marginBottom: '1.5rem' }}>
            {scrambled.map(item => (
              <button
                key={item.id}
                onClick={() => handlePickLetter(item)}
                disabled={item.used}
                style={{
                  width: '44px',
                  height: '48px',
                  borderRadius: '8px',
                  background: item.used ? 'transparent' : 'var(--bg-glass)',
                  border: item.used ? '1px dashed opacity 0.3' : '1px solid rgba(255, 255, 255, 0.2)',
                  fontSize: '1.3rem',
                  fontWeight: 'bold',
                  opacity: item.used ? 0.2 : 1,
                  cursor: item.used ? 'default' : 'pointer'
                }}
              >
                {item.char}
              </button>
            ))}
          </div>

          {message && <div style={{ fontSize: '1.1rem', marginBottom: '1rem', fontWeight: 'bold' }}>{message}</div>}

          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button className="btn btn-primary" onClick={handleCheckAnswer} disabled={userGuess.length === 0}>
              Kiểm Tra
            </button>
            <button className="btn btn-secondary" onClick={() => setCurrentIdx(i => Math.min(cards.length - 1, i + 1))}>
              Bỏ Qua
            </button>
          </div>
        </div>
      ) : (
        <div style={{ padding: '2rem 0' }}>
          <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🏆</div>
          <h2>Hoàn Thành Game Gỡ Rối Chữ!</h2>
          <p style={{ fontSize: '1.2rem', marginTop: '0.5rem', color: 'var(--text-secondary)' }}>
            Điểm số của bạn: <strong style={{ color: 'var(--accent-purple-light)' }}>{score}</strong>
          </p>
          <button className="btn btn-primary" onClick={onRestart} style={{ marginTop: '1.5rem' }}>
            🔄 Chơi Lại
          </button>
        </div>
      )}
    </div>
  );
};

/* -------------------------------------------------------------------------
   GAME 3: MEMORY FLIP (LẬT BÀI GHI NHỚ)
   ------------------------------------------------------------------------- */
const MemoryFlipGame = ({ cards, deck, speak, onRestart }) => {
  const [deckCards, setDeckCards] = useState([]);
  const [flippedIndex, setFlippedIndex] = useState([]);
  const [matched, setMatched] = useState([]);
  const [moves, setMoves] = useState(0);
  const [gameOver, setGameOver] = useState(false);

  useEffect(() => {
    const selected = [...cards].sort(() => 0.5 - Math.random()).slice(0, 6);
    const pool = [];
    selected.forEach((c, idx) => {
      pool.push({ id: idx * 2, cardId: c.id || c._id, text: c.front, type: 'word' });
      pool.push({ id: idx * 2 + 1, cardId: c.id || c._id, text: c.back, type: 'meaning' });
    });
    setDeckCards(pool.sort(() => 0.5 - Math.random()));
    setFlippedIndex([]);
    setMatched([]);
    setMoves(0);
    setGameOver(false);
  }, [cards]);

  const handleCardClick = (idx) => {
    if (flippedIndex.length === 2 || flippedIndex.includes(idx) || matched.includes(idx)) return;

    const newFlipped = [...flippedIndex, idx];
    setFlippedIndex(newFlipped);

    if (newFlipped.length === 2) {
      setMoves(m => m + 1);
      const first = deckCards[newFlipped[0]];
      const second = deckCards[newFlipped[1]];

      if (first.cardId === second.cardId && first.type !== second.type) {
        setMatched(m => [...m, newFlipped[0], newFlipped[1]]);
        setFlippedIndex([]);
        if (first.type === 'word') speak(first.text, deck?.language);
        else speak(second.text, deck?.language);

        if (matched.length + 2 === deckCards.length) {
          setGameOver(true);
        }
      } else {
        setTimeout(() => setFlippedIndex([]), 1000);
      }
    }
  };

  return (
    <div className="glass-card" style={{ padding: '2rem', textAlign: 'center' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <div>Số lần lật: <strong>{moves}</strong></div>
        <div>Đã mở: <strong>{matched.length / 2} / {deckCards.length / 2}</strong></div>
      </div>

      {!gameOver ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))', gap: '1rem' }}>
          {deckCards.map((card, idx) => {
            const isFlipped = flippedIndex.includes(idx) || matched.includes(idx);
            return (
              <div
                key={idx}
                onClick={() => handleCardClick(idx)}
                style={{
                  height: '110px',
                  borderRadius: '12px',
                  background: isFlipped ? 'rgba(124, 58, 237, 0.2)' : 'linear-gradient(135deg, #1e293b 0%, #0f172a 100%)',
                  border: isFlipped ? '2px solid var(--accent-purple-light)' : '1px solid rgba(255, 255, 255, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  padding: '0.5rem',
                  fontSize: isFlipped ? '1rem' : '2rem',
                  fontWeight: isFlipped ? 'bold' : 'normal',
                  transition: 'all 0.3s ease',
                  transform: isFlipped ? 'rotateY(0deg)' : 'rotateY(180deg)'
                }}
              >
                {isFlipped ? card.text : '❓'}
              </div>
            );
          })}
        </div>
      ) : (
        <div style={{ padding: '2rem 0' }}>
          <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🎉</div>
          <h2>Thắng Rồi! Đã Mở Toàn Bộ Thẻ!</h2>
          <p style={{ color: 'var(--text-secondary)', marginTop: '0.5rem' }}>
            Bạn đã hoàn thành trò chơi trong <strong>{moves}</strong> lượt lật.
          </p>
          <button className="btn btn-primary" onClick={onRestart} style={{ marginTop: '1.5rem' }}>
            🔄 Chơi Lại
          </button>
        </div>
      )}
    </div>
  );
};

export default GamesPage;
