import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
import { useDeckStatus } from '../hooks/useDeckStatus';
import OnboardingModal from '../components/Onboarding/OnboardingModal';

const MAJOR_NAMES = {
  it: { title: 'Công nghệ Thông tin & Phần mềm', icon: '💻', prefix: 'it -' },
  medical: { title: 'Y Khoa & Dược phẩm Lâm sàng', icon: '🏥', prefix: 'y khoa -' },
  economics: { title: 'Kinh Tế, Tài Chính & Ngân Hàng', icon: '📊', prefix: 'kinh tế -' },
  engineering: { title: 'Kỹ Thuật & Cơ Khí Chế Tạo', icon: '⚙️', prefix: 'kỹ thuật -' },
  law: { title: 'Luật Pháp, Chính Trị & Ngoại Giao', icon: '⚖️', prefix: 'luật' },
  toeic: { title: 'Luyện thi TOEIC & Giao tiếp Công sở', icon: '💼', prefix: 'toeic -' },
  ielts: { title: 'Luyện thi IELTS Academic 7.0+', icon: '🎓', prefix: 'ielts' },
  japanese: { title: 'Tiếng Nhật Chuyên Sâu', icon: '🇯🇵', prefix: '' }
};

const ACADEMIC_LEVEL_NAMES = {
  high_school: 'Học sinh THPT',
  university_year_1: 'Sinh viên Năm 1',
  university_year_2: 'Sinh viên Năm 2',
  university_year_3: 'Sinh viên Năm 3',
  university_year_4: 'Sinh viên Năm 4',
  working: 'Đã đi làm'
};

const RoadmapPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const { addToast, ToastContainer } = useToast();

  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showEditModal, setShowEditModal] = useState(false);

  // Hook quản lý trạng thái Đang học / Đã học / Chưa học của từng bộ thẻ
  const { getStatus, setStatus, DECK_STATUS } = useDeckStatus(decks);

  // Load user profile config
  const userProfile = useMemo(() => {
    const cached = user?.id ? localStorage.getItem(`lingua_profile_${user.id}`) : null;
    const local = cached ? JSON.parse(cached) : {};
    return {
      academicLevel: user?.academic_level || user?.academicLevel || local.academicLevel || 'university_year_2',
      major: user?.major || local.major || 'it',
      dailyMinutes: user?.dailyMinutes || local.dailyMinutes || 15,
      dailyWords: user?.dailyWords || local.dailyWords || 15,
      studyGoal: user?.studyGoal || local.studyGoal || 'career'
    };
  }, [user]);

  useEffect(() => {
    const fetchDecks = async () => {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('decks')
          .select('*')
          .order('created_at', { ascending: true });

        if (error) throw error;
        setDecks(data || []);
      } catch (err) {
        console.error('Error fetching roadmap decks:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchDecks();
  }, []);

  const majorInfo = MAJOR_NAMES[userProfile.major] || MAJOR_NAMES.it;

  // Lọc danh sách bài học theo lộ trình chuyên ngành của người dùng
  const roadmapDecks = useMemo(() => {
    return decks.filter(d => {
      const title = (d.title || '').toLowerCase();
      if (majorInfo.prefix && title.startsWith(majorInfo.prefix)) return true;
      if (userProfile.major === 'japanese' && d.language === 'ja') return true;
      return false;
    });
  }, [decks, majorInfo, userProfile.major]);

  // Thống kê tiến độ lộ trình
  const { completedCount, learningCount, currentActiveIndex, currentDeck, progressPercent, totalWords, estimatedDays } = useMemo(() => {
    const total = roadmapDecks.length;
    let completed = 0;
    let learning = 0;
    let firstIncompleteIndex = -1;

    roadmapDecks.forEach((deck, idx) => {
      const status = getStatus(deck.id || deck._id);
      if (status === DECK_STATUS.COMPLETED) {
        completed++;
      } else if (status === DECK_STATUS.LEARNING) {
        learning++;
        if (firstIncompleteIndex === -1) firstIncompleteIndex = idx;
      } else {
        if (firstIncompleteIndex === -1) firstIncompleteIndex = idx;
      }
    });

    // Nếu bài đầu tiên chưa học, tìm bài đang học hoặc bài chưa học đầu tiên
    const activeIdx = firstIncompleteIndex !== -1 ? firstIncompleteIndex : (completed === total && total > 0 ? 0 : 0);
    const activeDeck = roadmapDecks[activeIdx] || null;

    const words = roadmapDecks.reduce((sum, d) => sum + (d.card_count || 15), 0);
    const days = Math.max(1, Math.ceil(words / (userProfile.dailyWords || 15)));
    const percent = total > 0 ? Math.round((completed / total) * 100) : 0;

    return {
      completedCount: completed,
      learningCount: learning,
      currentActiveIndex: activeIdx,
      currentDeck: activeDeck,
      progressPercent: percent,
      totalWords: words,
      estimatedDays: days
    };
  }, [roadmapDecks, getStatus, DECK_STATUS, userProfile.dailyWords]);

  const handleToggleStatus = (e, deckId, newStatus) => {
    e.stopPropagation();
    setStatus(deckId, newStatus);
    const msg = newStatus === DECK_STATUS.COMPLETED 
      ? '🎉 Tuyệt vời! Đã ghi nhận hoàn thành bài học!' 
      : newStatus === DECK_STATUS.LEARNING 
      ? 'Đã đặt làm bài học đang tiến hành!' 
      : 'Đã chuyển về trạng thái chưa học';
    addToast(msg, 'success');
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  const allCompleted = roadmapDecks.length > 0 && completedCount === roadmapDecks.length;

  return (
    <div style={{ maxWidth: '960px', margin: '0 auto', paddingBottom: '3rem' }}>
      <ToastContainer />

      {/* Onboarding / Edit Setup Modal */}
      <OnboardingModal
        isOpen={showEditModal}
        onClose={() => setShowEditModal(false)}
        onComplete={() => {
          setShowEditModal(false);
        }}
      />

      {/* Header Banner */}
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-md)', marginBottom: '1.5rem' }}>
        <div>
          <h1 className="page-title">
            🧭 <span className="text-gradient">Lộ Trình Học Cá Nhân Hóa</span>
          </h1>
          <p className="page-subtitle">
            Tự động theo dõi tiến độ từng chặng theo chuyên ngành của bạn
          </p>
        </div>
        <button className="btn btn-secondary" onClick={() => setShowEditModal(true)}>
          ⚙️ Thay đổi ngành & mục tiêu
        </button>
      </div>

      {/* Profile Overview Card */}
      <div className="glass-card" style={{ padding: '1.5rem', marginBottom: '1.75rem', border: '1px solid rgba(99, 102, 241, 0.25)', background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(168, 85, 247, 0.05) 100%)' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1.25rem', marginBottom: '1.25rem' }}>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>🎓 Đối tượng & Trình độ:</span>
            <div style={{ fontWeight: '600', fontSize: '0.95rem', marginTop: '2px' }}>
              {ACADEMIC_LEVEL_NAMES[userProfile.academicLevel] || 'Sinh viên Đại học'}
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>📚 Khoa / Chuyên ngành:</span>
            <div style={{ fontWeight: '600', fontSize: '0.95rem', marginTop: '2px', color: 'var(--primary-color)' }}>
              {majorInfo.icon} {majorInfo.title}
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>⏱️ Thời gian học mỗi ngày:</span>
            <div style={{ fontWeight: '600', fontSize: '0.95rem', marginTop: '2px' }}>
              {userProfile.dailyMinutes} phút / ngày
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>🎯 Tốc độ mục tiêu:</span>
            <div style={{ fontWeight: '600', fontSize: '0.95rem', marginTop: '2px', color: '#10b981' }}>
              {userProfile.dailyWords} từ / ngày (~{estimatedDays} ngày)
            </div>
          </div>
        </div>

        {/* Thanh tiến độ toàn diện */}
        <div style={{ borderTop: '1px solid rgba(255,255,255,0.08)', paddingTop: '1rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.875rem', marginBottom: '0.4rem' }}>
            <span style={{ fontWeight: '600', color: '#fff' }}>
              📊 Tiến độ lộ trình: {completedCount} / {roadmapDecks.length} bài học hoàn thành
            </span>
            <span style={{ fontWeight: '700', color: progressPercent === 100 ? '#10b981' : 'var(--primary-color)' }}>
              {progressPercent}%
            </span>
          </div>
          <div style={{ height: '8px', background: 'rgba(255,255,255,0.1)', borderRadius: '4px', overflow: 'hidden' }}>
            <div style={{
              width: `${progressPercent}%`,
              height: '100%',
              background: progressPercent === 100 ? 'linear-gradient(90deg, #10b981, #06b6d4)' : 'linear-gradient(90deg, #6366f1, #a855f7)',
              borderRadius: '4px',
              transition: 'width 0.4s ease'
            }}></div>
          </div>
        </div>
      </div>

      {/* Target Action Card: Tự động trỏ vào bài học tiếp theo cần học */}
      {roadmapDecks.length > 0 && currentDeck && (
        <div className="glass-card" style={{
          padding: '1.5rem',
          marginBottom: '2rem',
          borderLeft: allCompleted ? '4px solid #10b981' : '4px solid var(--primary-color)',
          background: allCompleted ? 'rgba(16, 185, 129, 0.08)' : 'rgba(99, 102, 241, 0.08)'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
            <div>
              <span style={{
                fontSize: '0.8rem',
                padding: '3px 10px',
                borderRadius: '12px',
                background: allCompleted ? 'rgba(16, 185, 129, 0.2)' : 'rgba(99, 102, 241, 0.2)',
                color: allCompleted ? '#34d399' : 'var(--primary-color)',
                fontWeight: '700'
              }}>
                {allCompleted ? '🏆 ĐÃ HOÀN THÀNH TOÀN BỘ LỘ TRÌNH' : `🌟 BÀI HỌC TIẾP THEO (DAY ${currentActiveIndex + 1})`}
              </span>
              <h2 style={{ fontSize: '1.35rem', marginTop: '0.5rem', fontWeight: '700' }}>
                {allCompleted ? 'Chúc mừng bạn đã chinh phục 100% lộ trình!' : currentDeck?.title}
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
                {allCompleted 
                  ? 'Hãy tiếp tục làm bài Mini Test và tham gia Games để củng cố phản xạ từ vựng.' 
                  : (currentDeck?.description || 'Tiếp tục chặng học để hoàn thành mục tiêu chuyên ngành!')}
              </p>
            </div>

            <button
              className="btn btn-primary"
              style={{ padding: '0.75rem 1.75rem', fontSize: '1rem' }}
              onClick={() => navigate(`/decks/${currentDeck?.id}`)}
            >
              {allCompleted ? '🔄 Ôn tập bài học' : `🚀 Học ngay bài tiếp theo (${currentDeck?.card_count || 15} từ)`}
            </button>
          </div>
        </div>
      )}

      {/* Roadmap Timeline */}
      <div style={{ marginBottom: '1.5rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem', flexWrap: 'wrap', gap: '0.5rem' }}>
          <h2 style={{ fontSize: '1.25rem', fontWeight: '700', margin: 0 }}>
            📍 Toàn Bộ Chặng Lộ Trình ({roadmapDecks.length} bài học - {totalWords} từ vựng)
          </h2>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            🟢 {learningCount} đang học • 🔵 {completedCount} đã xong
          </span>
        </div>

        {roadmapDecks.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">📂</div>
            <div className="empty-title">Chưa nạp bộ từ chuyên ngành</div>
            <div className="empty-desc">
              Hãy chạy file <code>data/seed_vocabulary.sql</code> trong Supabase SQL Editor để kích hoạt 70 bài học chuyên ngành có sẵn!
            </div>
            <button className="btn btn-primary" onClick={() => navigate('/decks')}>
              Xem tất cả bộ thẻ
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
            {roadmapDecks.map((deck, idx) => {
              const deckId = deck.id || deck._id;
              const dayNumber = idx + 1;
              const status = getStatus(deckId);
              const isCompleted = status === DECK_STATUS.COMPLETED;
              const isLearning = status === DECK_STATUS.LEARNING;
              const isCurrentActive = idx === currentActiveIndex && !allCompleted;

              return (
                <div
                  key={deckId}
                  className="glass-card"
                  onClick={() => navigate(`/decks/${deckId}`)}
                  style={{
                    padding: '1.15rem 1.35rem',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    cursor: 'pointer',
                    transition: 'all 0.2s ease',
                    border: isCurrentActive 
                      ? '2px solid #8b5cf6' 
                      : isCompleted 
                      ? '1px solid rgba(16, 185, 129, 0.3)' 
                      : '1px solid rgba(255,255,255,0.06)',
                    background: isCurrentActive 
                      ? 'rgba(139, 92, 246, 0.15)' 
                      : isCompleted 
                      ? 'rgba(16, 185, 129, 0.04)' 
                      : 'rgba(255,255,255,0.02)'
                  }}
                >
                  {/* Left: Icon & Info */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1.15rem' }}>
                    <div style={{
                      width: '42px',
                      height: '42px',
                      borderRadius: '50%',
                      background: isCompleted 
                        ? 'linear-gradient(135deg, #10b981, #059669)' 
                        : isCurrentActive 
                        ? 'linear-gradient(135deg, #8b5cf6, #6366f1)' 
                        : isLearning 
                        ? 'rgba(34, 197, 94, 0.2)' 
                        : 'rgba(255,255,255,0.06)',
                      color: '#fff',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: '700',
                      fontSize: '0.95rem',
                      boxShadow: isCurrentActive ? '0 0 12px rgba(139, 92, 246, 0.4)' : 'none'
                    }}>
                      {isCompleted ? '✓' : dayNumber}
                    </div>

                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '2px' }}>
                        <span style={{ fontSize: '0.75rem', color: isCurrentActive ? '#a78bfa' : isCompleted ? '#34d399' : 'var(--text-muted)', fontWeight: '700' }}>
                          DAY {dayNumber} • {userProfile.dailyMinutes} PHÚT
                        </span>

                        {/* Status Badge */}
                        <span style={{
                          fontSize: '0.675rem',
                          padding: '1px 6px',
                          borderRadius: '4px',
                          fontWeight: '700',
                          background: isCompleted ? 'rgba(16, 185, 129, 0.2)' : isLearning ? 'rgba(34, 197, 94, 0.2)' : 'rgba(255,255,255,0.08)',
                          color: isCompleted ? '#34d399' : isLearning ? '#4ade80' : '#94a3b8'
                        }}>
                          {isCompleted ? 'ĐÃ HOÀN THÀNH' : isLearning ? 'ĐANG HỌC' : 'CHƯA HỌC'}
                        </span>
                      </div>

                      <h3 style={{ fontSize: '1.05rem', fontWeight: '600', margin: 0, color: '#fff' }}>
                        {deck.title}
                      </h3>
                      <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', margin: '2px 0 0' }}>
                        {deck.description}
                      </p>
                    </div>
                  </div>

                  {/* Right: Word Count & Action Button */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                      {deck.card_count || 15} từ
                    </span>

                    <button className={`btn btn-sm ${isCurrentActive ? 'btn-primary' : isCompleted ? 'btn-outline' : 'btn-secondary'}`}>
                      {isCompleted ? 'Ôn tập lại' : isCurrentActive ? 'Học ngay' : 'Vào bài'}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default RoadmapPage;
