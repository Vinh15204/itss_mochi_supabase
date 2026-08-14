import { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useSpeech } from '../hooks/useSpeech';

const QUICK_OPTIONS = [
  { value: 5,    tagKey: 'quick' },
  { value: 10,   tagKey: 'standard' },
  { value: 15,   tagKey: 'challenge' },
  { value: 20,   tagKey: 'full' },
  { value: null, tagKey: 'all' },   // null = all cards
];

const QUICK_TAGS = {
  quick:     { vi: 'nhanh',    en: 'Quick',     ja: 'クイック' },
  standard:  { vi: 'cơ bản',  en: 'Standard',  ja: '標準' },
  challenge: { vi: 'thử thách', en: 'Challenge', ja: '挑戦' },
  full:      { vi: 'đầy đủ',  en: 'Full',      ja: 'フル' },
  all:       { vi: 'tất cả',  en: 'All',       ja: '全て' },
};

const MiniTestPage = () => {
  const { deckId } = useParams();
  const navigate = useNavigate();
  const { addToast, ToastContainer } = useToast();
  const { t, currentLang } = useTranslation();
  const { speak, currentlySpeaking, isSupported: speechSupported } = useSpeech();

  const [decks, setDecks] = useState([]);
  const [selectedDeck, setSelectedDeck] = useState(deckId || '');
  const [questions, setQuestions] = useState([]);
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState([]);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [showResult, setShowResult] = useState(false);
  const [result, setResult] = useState(null);
  const [testStarted, setTestStarted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [answered, setAnswered] = useState(false);

  // Setup modal state
  const [showSetupModal, setShowSetupModal] = useState(false);
  const [pendingDeck, setPendingDeck] = useState(null);   // { id, title, cardCount }
  const [questionCount, setQuestionCount] = useState(10);
  const [activePreset, setActivePreset] = useState(10);   // tracks which quick-btn is active

  const activeDeckLang = pendingDeck?.language
    || decks.find(d => (d.id || d._id) === (selectedDeck || deckId))?.language
    || 'ja';

  const startTest = useCallback(async (id, count = 10) => {
    setLoading(true);
    try {
      const { data: cards, error } = await supabase
        .from('cards')
        .select('*')
        .eq('deck_id', id);

      if (error) throw error;
      if (!cards || cards.length < 4) {
        throw new Error(currentLang === 'vi' ? 'Cần ít nhất 4 thẻ để tạo bài test' : 'Need at least 4 cards');
      }

      const shuffle = arr => [...arr].sort(() => 0.5 - Math.random());
      const selectedCards = shuffle(cards).slice(0, count);

      const generatedQuestions = selectedCards.map(card => {
        const otherBacks = cards.filter(c => c.id !== card.id && c.back).map(c => c.back);
        const shuffledOthers = shuffle(otherBacks).slice(0, 3);
        while (shuffledOthers.length < 3) {
          shuffledOthers.push(`Lựa chọn ${shuffledOthers.length + 1}`);
        }
        const options = shuffle([card.back || card.front, ...shuffledOthers]);
        return {
          cardId: card.id,
          question: card.front,
          reading: card.reading,
          correctAnswer: card.back || card.front,
          options
        };
      });

      setQuestions(generatedQuestions);
      setCurrentQ(0);
      setAnswers([]);
      setSelectedAnswer(null);
      setTestStarted(true);
      setShowResult(false);
      setAnswered(false);
    } catch (err) {
      console.error('Test generation error:', err);
      addToast(
        err.message || (
          currentLang === 'vi' ? 'Lỗi khi tạo bài test'
          : currentLang === 'en' ? 'Failed to generate test'
          : 'テストの作成に失敗しました'
        ),
        'error'
      );
    } finally {
      setLoading(false);
    }
  }, [currentLang, addToast]);

  const confirmAndStart = () => {
    if (!pendingDeck) return;
    setShowSetupModal(false);
    const targetId = pendingDeck.id || pendingDeck._id;
    setSelectedDeck(targetId);
    startTest(targetId, questionCount);
  };

  const handleTryAgainClick = () => {
    const currentDeck = decks.find(d => (d.id || d._id) === (selectedDeck || deckId));
    if (currentDeck) {
      openSetupModal(currentDeck);
    } else {
      const activeId = selectedDeck || deckId;
      if (activeId) {
        startTest(activeId, questionCount || 10);
      }
    }
  };

  const loadDecks = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from('decks')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setDecks(data || []);
    } catch (err) {
      console.error('Error loading decks for test:', err);
      addToast(
        currentLang === 'vi' ? 'Lỗi khi tải bộ thẻ từ'
        : currentLang === 'en' ? 'Failed to load decks'
        : 'デッキの読み込みに失敗しました',
        'error'
      );
    }
  }, [currentLang, addToast]);

  useEffect(() => {
    loadDecks();
  }, [loadDecks]);

  useEffect(() => {
    if (deckId) {
      startTest(deckId, 10);
    }
  }, [deckId, startTest]);

  const openSetupModal = (deck) => {
    setPendingDeck(deck);
    const count = deck.card_count || deck.cardCount || 10;
    const defaultCount = Math.min(10, count);
    setQuestionCount(defaultCount);
    setActivePreset(defaultCount);
    setShowSetupModal(true);
  };

  const handlePresetSelect = (deck, presetValue) => {
    const max = deck?.card_count ?? deck?.cardCount ?? pendingDeck?.card_count ?? pendingDeck?.cardCount ?? 999;
    const resolved = presetValue === null ? max : Math.min(presetValue, max);
    setQuestionCount(resolved);
    setActivePreset(presetValue);
  };

  const handleCustomInput = (val) => {
    const max = pendingDeck?.card_count ?? pendingDeck?.cardCount ?? 999;
    const parsed = parseInt(val, 10);
    if (!isNaN(parsed)) {
      const clamped = Math.max(4, Math.min(parsed, max));
      setQuestionCount(clamped);
      setActivePreset(null);
    }
  };

  const selectAnswer = (option) => {
    if (answered) return;
    setSelectedAnswer(option);
    setAnswered(true);

    const currentQuestion = questions[currentQ];
    const isCorrect = option === currentQuestion.correctAnswer;

    setAnswers(prev => [...prev, {
      cardId: currentQuestion.cardId,
      userAnswer: option,
      correctAnswer: currentQuestion.correctAnswer,
      correct: isCorrect
    }]);

    setTimeout(() => {
      if (currentQ < questions.length - 1) {
        setCurrentQ(prev => prev + 1);
        setSelectedAnswer(null);
        setAnswered(false);
      } else {
        submitTest();
      }
    }, 1200);
  };

  const submitTest = async () => {
    try {
      const updatedAnswers = [...answers];
      if (answers.length < questions.length) {
        const currentQuestion = questions[currentQ];
        updatedAnswers.push({
          cardId: currentQuestion.cardId,
          userAnswer: selectedAnswer,
          correctAnswer: currentQuestion.correctAnswer,
          correct: selectedAnswer === currentQuestion.correctAnswer
        });
      }

      const correctCount = updatedAnswers.filter(a => a.correct).length;
      const total = questions.length;
      const percentage = Math.round((correctCount / total) * 100);

      const { data: { user: currentUser } } = await supabase.auth.getUser();

      await supabase.from('test_results').insert([{
        user_id: currentUser?.id,
        deck_id: selectedDeck || deckId,
        score: correctCount,
        total_questions: total
      }]);

      setResult({ score: correctCount, totalQuestions: total, percentage });
      setShowResult(true);

    } catch (err) {
      console.error('Error submitting test result:', err);
      addToast(
        currentLang === 'vi' ? 'Lỗi khi gửi kết quả kiểm tra'
        : currentLang === 'en' ? 'Failed to submit test'
        : 'テストの提出に失敗しました',
        'error'
      );
    }
  };

  const getOptionClass = (option) => {
    if (!answered) return selectedAnswer === option ? 'selected' : '';
    const currentQuestion = questions[currentQ];
    if (option === currentQuestion.correctAnswer) return 'correct';
    if (option === selectedAnswer && option !== currentQuestion.correctAnswer) return 'incorrect';
    return '';
  };

  const maxCards = pendingDeck?.card_count ?? pendingDeck?.cardCount ?? 999;
  const setupModalJSX = showSetupModal && pendingDeck ? (
    <div className="test-setup-overlay" onClick={(e) => { if (e.target === e.currentTarget) setShowSetupModal(false); }}>
      <div className="test-setup-card">
        <div className="test-setup-header">
          <div className="test-setup-icon">⚙️</div>
          <h2>{t('test.setupTitle')}</h2>
          <p>{t('test.setupSubtitle')}</p>
          <div className="test-setup-deck-name">
            📚 {pendingDeck.title}
          </div>
        </div>

        <div className="setup-section-label">{t('test.quickSelect')}</div>
        <div className="question-count-options">
          {QUICK_OPTIONS.map((opt) => {
            const displayNum = opt.value === null ? maxCards : Math.min(opt.value, maxCards);
            const isDisabled = opt.value !== null && opt.value > maxCards;
            const isActive = activePreset === opt.value;
            const tag = QUICK_TAGS[opt.tagKey]?.[currentLang] || QUICK_TAGS[opt.tagKey]?.en;

            return (
              <button
                key={opt.tagKey}
                className={`count-option${isActive ? ' active' : ''}`}
                onClick={() => handlePresetSelect(pendingDeck, opt.value)}
                disabled={isDisabled}
                title={isDisabled ? t('test.maxCardsHint', { max: maxCards }) : undefined}
              >
                <span className="count-num">{displayNum}</span>
                <span className="count-tag">{tag}</span>
              </button>
            );
          })}
        </div>

        <div className="setup-section-label">{t('test.customCount')}</div>
        <div className="count-input-group">
          <label htmlFor="custom-count">{t('test.questionCountLabel')}</label>
          <input
            id="custom-count"
            type="number"
            min={4}
            max={maxCards}
            value={questionCount}
            onChange={(e) => handleCustomInput(e.target.value)}
          />
          <span className="count-hint">{t('test.maxCardsHint', { max: maxCards })}</span>
        </div>

        <div className="test-setup-actions">
          <button className="btn btn-secondary" onClick={() => setShowSetupModal(false)}>
            {t('test.cancelSetup')}
          </button>
          <button className="btn btn-primary" onClick={confirmAndStart}>
            {t('test.beginTest')} — {questionCount} {currentLang === 'vi' ? 'câu' : currentLang === 'en' ? 'Q' : '問'}
          </button>
        </div>
      </div>
    </div>
  ) : null;

  if (!testStarted && !deckId) {
    return (
      <div>
        <ToastContainer />
        {setupModalJSX}
        <div className="page-header">
          <h1 className="page-title">📝 <span className="text-gradient">{t('test.title')}</span></h1>
          <p className="page-subtitle">
            {currentLang === 'vi' ? 'Kiểm tra kiến thức của bạn với các bài trắc nghiệm nhanh'
            : currentLang === 'en' ? 'Test your knowledge with quick quizzes'
            : 'クイッククイズで知識をテストしましょう'}
          </p>
        </div>

        {decks.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">📝</div>
            <div className="empty-title">
              {currentLang === 'vi' ? 'Không có bộ thẻ nào'
              : currentLang === 'en' ? 'No decks available'
              : '利用可能なデッキがありません'}
            </div>
            <div className="empty-desc">
              {currentLang === 'vi' ? 'Hãy tạo bộ thẻ từ vựng với ít nhất 4 thẻ trước'
              : currentLang === 'en' ? 'Create a flashcard deck with at least 4 cards first'
              : '最初に少なくとも4枚のカードを持つデッキを作成してください'}
            </div>
            <button className="btn btn-primary" onClick={() => navigate('/decks')}>
              {t('test.backBtn')}
            </button>
          </div>
        ) : (
          <div className="deck-grid">
            {decks.filter(d => (d.card_count || d.cardCount || 0) >= 4).map(deck => {
              const deckIdVal = deck.id || deck._id;
              const cardCnt = deck.card_count || deck.cardCount || 0;
              return (
                <div
                  key={deckIdVal}
                  className="glass-card deck-card"
                  onClick={() => openSetupModal(deck)}
                >
                  <span className="deck-lang">
                    {deck.language === 'ja' ? t('decks.langJa') : t('decks.langEn')}
                  </span>
                  <h3 className="deck-title">{deck.title}</h3>
                  <p className="deck-desc">{t('decks.totalCards', { count: cardCnt })}</p>
                  <button className="btn btn-primary btn-sm" style={{ marginTop: 'var(--space-md)' }}>
                    {t('test.startBtn')} →
                  </button>
                </div>
              );
            })}
            {decks.filter(d => (d.card_count || d.cardCount || 0) >= 4).length === 0 && (
              <div className="empty-state">
                <div className="empty-title">
                  {currentLang === 'vi' ? 'Không đủ số thẻ từ'
                  : currentLang === 'en' ? 'Not enough cards'
                  : 'カードが不足しています'}
                </div>
                <div className="empty-desc">
                  {currentLang === 'vi' ? 'Mỗi bộ thẻ cần ít nhất 4 thẻ để có thể làm bài test'
                  : currentLang === 'en' ? 'Each deck needs at least 4 cards for a test'
                  : 'テストを行うには、各デッキに少なくとも4枚のカードが必要です'}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  if (showResult && result) {
    const isGood = result.percentage >= 80;
    const isPerfect = result.percentage === 100;

    return (
      <div>
        <ToastContainer />
        {setupModalJSX}
        <div className="test-container">
          <div className="glass-card test-result">
            <div style={{ fontSize: '4rem', marginBottom: 'var(--space-lg)' }}>
              {isPerfect ? '🎉' : isGood ? '👏' : '💪'}
            </div>
            <h2 style={{ marginBottom: 'var(--space-lg)' }}>
              {isPerfect
                ? (currentLang === 'vi' ? 'Điểm tuyệt đối!' : currentLang === 'en' ? 'Perfect Score!' : '満点です！')
                : isGood
                  ? (currentLang === 'vi' ? 'Làm tốt lắm!' : currentLang === 'en' ? 'Great Job!' : '素晴らしい！')
                  : (currentLang === 'vi' ? 'Cố gắng lên nhé!' : currentLang === 'en' ? 'Keep Practicing!' : '練習を続けましょう！')}
            </h2>
            <div className="score-circle" style={{
              borderColor: isGood ? 'var(--accent-green)' : 'var(--accent-orange)'
            }}>
              <div className="score-value" style={{
                color: isGood ? 'var(--accent-green)' : 'var(--accent-orange)'
              }}>
                {result.percentage}%
              </div>
              <div className="score-label">{result.score}/{result.totalQuestions}</div>
            </div>

            <div style={{ display: 'flex', gap: 'var(--space-md)', justifyContent: 'center', marginTop: 'var(--space-xl)' }}>
              <button className="btn btn-primary" onClick={handleTryAgainClick}>
                🔄 {currentLang === 'vi' ? 'Thử lại' : currentLang === 'en' ? 'Try Again' : 'もう一度試す'}
              </button>
              <button className="btn btn-secondary" onClick={() => navigate('/decks')}>
                {t('test.backBtn')}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const question = questions[currentQ];
  if (!question) return null;

  return (
    <div>
      <ToastContainer />
      <div className="test-container">
        <div className="test-progress">
          <div className="test-progress-bar">
            <div className="test-progress-fill" style={{ width: `${((currentQ + 1) / questions.length) * 100}%` }}></div>
          </div>
          <span className="test-progress-text">{currentQ + 1}/{questions.length}</span>
        </div>

        <div className="glass-card test-question-card">
          <div className="question-number">{t('test.questionLabel', { num: currentQ + 1 })}</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-md)', marginBottom: 'var(--space-md)' }}>
            <div className="question-text" style={{ margin: 0, flex: 1 }}>{question.question}</div>
            {speechSupported && (
              <button
                className={`speak-btn speak-btn-lg${currentlySpeaking === question.question ? ' speaking' : ''}`}
                onClick={() => speak(question.question, activeDeckLang)}
                title={currentLang === 'vi' ? 'Nghe phát âm' : currentLang === 'en' ? 'Listen to pronunciation' : '発音を聞く'}
              >
                🔊
              </button>
            )}
          </div>
          {question.reading && (
            <div style={{ color: 'var(--accent-purple-light)', fontSize: '1rem', marginBottom: 'var(--space-lg)', fontFamily: 'var(--font-japanese)' }}>
              {question.reading}
            </div>
          )}
          <p style={{ color: 'var(--text-secondary)', marginBottom: 'var(--space-xl)' }}>
            {currentLang === 'vi' ? 'Chọn nghĩa chính xác:' : currentLang === 'en' ? 'Choose the correct meaning:' : '正しい意味を選択してください：'}
          </p>

          <div className="test-options">
            {question.options?.map((option, idx) => (
              <button
                key={idx}
                className={`test-option ${getOptionClass(option)}`}
                onClick={() => selectAnswer(option)}
                disabled={answered}
              >
                <span className="test-option-letter">
                  {String.fromCharCode(65 + idx)}
                </span>
                {option}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MiniTestPage;
