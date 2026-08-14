import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useSpeech } from '../hooks/useSpeech';

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

  const handleSelectDeck = async (deck) => {
    setSelectedDeck(deck);
    await loadCardsForDeck(deck);
  };

  const startNewGame = async (gameType) => {
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
          {/* Deck selector */}
          <div className="glass-card" style={{ marginBottom: '2rem' }}>
            <h3 style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              📚 Chọn Bộ Thẻ Để Chơi:
            </h3>
            {decks.length === 0 ? (
              <div className="empty-state" style={{ padding: '1rem' }}>
                <p>Bạn chưa có bộ thẻ nào. Hãy tạo bộ thẻ trước để bắt đầu chơi!</p>
                <button className="btn btn-primary" onClick={() => navigate('/decks')} style={{ marginTop: '0.5rem' }}>
                  ➕ Tạo Bộ Thẻ Ngay
                </button>
              </div>
            ) : (
              <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                {decks.map(deck => {
                  const isSelected = selectedDeck?.id === deck.id || selectedDeck?._id === deck._id;
                  return (
                    <div
                      key={deck.id || deck._id}
                      onClick={() => handleSelectDeck(deck)}
                      className={`glass-card ${isSelected ? 'active-deck-card' : ''}`}
                      style={{
                        padding: '1rem 1.25rem',
                        cursor: 'pointer',
                        borderRadius: '12px',
                        border: isSelected ? '2px solid var(--accent-purple-light)' : '1px solid rgba(255, 255, 255, 0.1)',
                        background: isSelected ? 'rgba(124, 58, 237, 0.15)' : 'var(--bg-glass)',
                        transition: 'all 0.2s ease',
                        minWidth: '180px',
                        flex: '1'
                      }}
                    >
                      <div style={{ fontWeight: 'bold', fontSize: '1.1rem', marginBottom: '0.25rem' }}>
                        {deck.language === 'ja' ? '🇯🇵' : '🇬🇧'} {deck.title}
                      </div>
                      <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                        {deck.card_count || deck.cardCount || 0} từ vựng
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Games Selection List */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1.5rem' }}>
            {/* Game IOE Penalty Shootout */}
            <div className="glass-card" style={{ padding: '1.5rem', borderRadius: '16px', border: '2px solid #0099ff', background: 'linear-gradient(135deg, rgba(0, 153, 255, 0.15) 0%, rgba(0, 102, 204, 0.05) 100%)' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚽</div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 'bold', marginBottom: '0.5rem', color: '#38bdf8' }}>Sút Phạt IOE ⚽</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.5rem', minHeight: '40px' }}>
                Game bóng đá sút penalty trắc nghiệm phong cách IOE huyền thoại! 4 đáp án A-B-C-D sút tung lưới ăn mừng SIUUU!
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
   EXACT IOE-STYLE PENALTY SHOOTOUT GAME (WIDE HIGH-RES SCREEN)
   ------------------------------------------------------------------------- */
const IOEPenaltyGame = ({ cards, deck, user, speak, onRestart }) => {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [options, setOptions] = useState([]);
  const [score, setScore] = useState(0);
  const [secondsLeft, setSecondsLeft] = useState(120); // 2:00 timer like IOE
  const [kickStatus, setKickStatus] = useState(null); // null | 'goal' | 'miss'
  const [keeperPos, setKeeperPos] = useState('center'); // 'left' | 'center' | 'right'
  const [ballPos, setBallPos] = useState({ top: '350px', left: '50%' });
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

  // Setup options for current question
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
    setKeeperPos('center');
    setBallPos({ top: '350px', left: '50%' });
  }, [currentCard, cards]);

  useEffect(() => {
    prepareQuestion();
  }, [currentIdx, prepareQuestion]);

  const handleSelectOption = (selectedOption, optionIdx) => {
    if (kickStatus !== null || !currentCard) return;

    const isCorrect = selectedOption === (currentCard.back || currentCard.front);

    // Ball flight target positions centered inside larger goal frame
    const ballTargets = [
      { top: '150px', left: '34%' }, // A (Top-Left corner)
      { top: '150px', left: '66%' }, // B (Top-Right corner)
      { top: '230px', left: '34%' }, // C (Bottom-Left corner)
      { top: '230px', left: '66%' }  // D (Bottom-Right corner)
    ];

    const keeperDives = isCorrect
      ? (optionIdx % 2 === 0 ? 'right' : 'left')  // Keeper dives WRONG way
      : (optionIdx % 2 === 0 ? 'left' : 'right');  // Keeper SAVES

    setBallPos(ballTargets[optionIdx] || { top: '170px', left: '50%' });
    setKeeperPos(keeperDives);

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
      }, 1800);
    }, 450);
  };

  if (!currentCard) return null;

  return (
    <div style={{
      maxWidth: '1150px',
      width: '100%',
      margin: '0 auto',
      borderRadius: '24px',
      overflow: 'hidden',
      boxShadow: '0 16px 50px rgba(0, 0, 0, 0.7)',
      border: '4px solid #0099ff',
      background: '#0a0f1d',
      position: 'relative'
    }}>
      {/* 1. TOP QUESTION BANNER (Wider High-Res IOE Header) */}
      <div style={{
        background: 'linear-gradient(180deg, #00bfff 0%, #0088ff 100%)',
        border: '3px dashed #ffffff',
        margin: '12px 14px 0 14px',
        borderRadius: '16px',
        padding: '16px 24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
        boxShadow: '0 6px 15px rgba(0,136,255,0.4)'
      }}>
        <div style={{
          position: 'absolute',
          left: '20px',
          background: '#ffffff',
          width: '44px',
          height: '44px',
          borderRadius: '50%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '1.8rem'
        }}>
          ⚽
        </div>
        <div style={{
          color: '#ffffff',
          fontSize: '1.65rem',
          fontWeight: 'bold',
          textAlign: 'center',
          fontFamily: deck?.language === 'ja' ? 'var(--font-japanese)' : 'sans-serif',
          textShadow: '0 2px 6px rgba(0,0,0,0.4)'
        }}>
          {deck?.language === 'ja' ? `Nghĩa của từ "${currentCard.front}" là gì?` : `What is the meaning of "${currentCard.front}"?`}
        </div>
      </div>

      {/* 2. EXPANDED STADIUM FIELD ARENA (420px Height) */}
      <div style={{
        position: 'relative',
        height: '420px',
        background: 'linear-gradient(180deg, #050a14 0%, #0c1829 25%, #00b000 25%, #008a00 100%)',
        overflow: 'hidden'
      }}>
        {/* Crowd Spectators & Flags Silhouette at top */}
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '105px',
          background: 'radial-gradient(ellipse at top, #1e293b 0%, #090d16 100%)',
          display: 'flex',
          justifyContent: 'space-around',
          alignItems: 'flex-end',
          paddingBottom: '8px',
          opacity: 0.95
        }}>
          <div style={{ fontSize: '1.8rem' }}>🚩👥👥🚩👥👥🚩👥</div>
          <div style={{ fontSize: '1.8rem' }}>👥👥🚩👥👥🚩👥👥</div>
          <div style={{ fontSize: '1.8rem' }}>🚩👥👥🚩👥👥🚩👥</div>
        </div>

        {/* Top-Left IOE User & Score Badge */}
        <div style={{
          position: 'absolute',
          top: '115px',
          left: '25px',
          zIndex: 10,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start'
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            background: 'rgba(0,0,0,0.7)',
            padding: '8px 16px',
            borderRadius: '10px',
            border: '2px solid #ff9900'
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
              <div style={{ color: '#ffff00', fontWeight: 'bold', fontSize: '1.05rem' }}>
                Score: <span style={{ color: '#ffffff' }}>{score}</span>
              </div>
              <div style={{ color: '#ffff00', fontWeight: 'bold', fontSize: '0.95rem' }}>
                Question: <span style={{ color: '#ffffff' }}>{currentIdx + 1}/{cards.length}</span>
              </div>
            </div>
          </div>
          <div style={{ color: '#a3e635', fontWeight: 'bold', fontSize: '1.05rem', marginTop: '6px', textShadow: '0 2px 4px #000' }}>
            {userName}
          </div>
        </div>

        {/* Top-Right Big Timer */}
        <div style={{
          position: 'absolute',
          top: '115px',
          right: '30px',
          zIndex: 10,
          color: '#ffffff',
          fontSize: '2.5rem',
          fontWeight: '900',
          fontFamily: 'monospace',
          textShadow: '0 2px 10px rgba(0,0,0,0.9)'
        }}>
          {formatTime(secondsLeft)}
        </div>

        {/* PROPORTIONAL Goal Post Frame Structure (Wider 480px Net) */}
        <div style={{
          position: 'absolute',
          top: '105px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '480px',
          height: '175px',
          border: '7px solid #ffffff',
          borderBottom: 'none',
          borderRadius: '12px 12px 0 0',
          background: 'repeating-linear-gradient(0deg, transparent, transparent 10px, rgba(255,255,255,0.2) 10px, rgba(255,255,255,0.2) 11px), repeating-linear-gradient(90deg, transparent, transparent 10px, rgba(255,255,255,0.2) 10px, rgba(255,255,255,0.2) 11px)',
          boxShadow: '0 6px 20px rgba(0,0,0,0.6)',
          zIndex: 2
        }}></div>

        {/* Pitch Lines (Penalty Line & Goal Area Box) */}
        <div style={{
          position: 'absolute',
          top: '280px',
          left: 0,
          right: 0,
          height: '5px',
          background: '#ffffff'
        }}></div>
        <div style={{
          position: 'absolute',
          top: '280px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '580px',
          height: '140px',
          border: '5px solid #ffffff',
          borderTop: 'none'
        }}></div>

        {/* Penalty Spot Dot */}
        <div style={{
          position: 'absolute',
          top: '350px',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: '14px',
          height: '14px',
          borderRadius: '50%',
          background: '#ffffff',
          boxShadow: '0 0 6px #000'
        }}></div>

        {/* Animated IOE Goalkeeper Character (Larger 6rem) */}
        <div style={{
          position: 'absolute',
          top: keeperPos === 'left' ? '150px' : keeperPos === 'right' ? '150px' : '135px',
          left: keeperPos === 'left' ? '36%' : keeperPos === 'right' ? '64%' : '50%',
          transform: keeperPos === 'left' ? 'translate(-50%, 0) rotate(-30deg) scale(1.15)' : keeperPos === 'right' ? 'translate(-50%, 0) rotate(30deg) scale(1.15)' : 'translateX(-50%)',
          transition: 'all 0.35s ease-out',
          fontSize: '5.5rem',
          filter: 'drop-shadow(0 8px 12px rgba(0,0,0,0.6))',
          zIndex: 5
        }}>
          🤾‍♂️
        </div>

        {/* Football Ball (Larger 3rem Ball) */}
        <div style={{
          position: 'absolute',
          top: ballPos.top,
          left: ballPos.left,
          fontSize: '3rem',
          transition: 'all 0.45s cubic-bezier(0.2, 0.8, 0.4, 1)',
          transform: 'translate(-50%, -50%)',
          filter: 'drop-shadow(0 8px 14px rgba(0,0,0,0.7))',
          zIndex: 6
        }}>
          ⚽
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
            zIndex: 20,
            animation: 'popIn 0.3s ease'
          }}>
            <div style={{ fontSize: '4rem', fontWeight: '900', color: '#ffffff', textShadow: '0 4px 12px #000' }}>
              ⚽ GOALLL! SIUUUUU! 🔥
            </div>
            <div style={{ fontSize: '1.6rem', color: '#ffff00', marginTop: '0.75rem', fontWeight: 'bold' }}>
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
            zIndex: 20,
            animation: 'popIn 0.3s ease'
          }}>
            <div style={{ fontSize: '3.5rem', fontWeight: '900', color: '#ffffff' }}>
              ❌ THỦ MÔN BẮT BÓNG!
            </div>
            <div style={{ fontSize: '1.3rem', color: '#ffffff', marginTop: '0.75rem' }}>
              Đáp án đúng: <strong style={{ color: '#ffff00' }}>{currentCard.back || currentCard.front}</strong>
            </div>
          </div>
        )}
      </div>

      {/* 3. BOTTOM IOE HEXAGONAL ANSWER BUTTONS (Wider & Larger Text) */}
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
