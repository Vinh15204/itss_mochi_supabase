import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../hooks/useToast';
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
  const { ToastContainer } = useToast();

  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showEditModal, setShowEditModal] = useState(false);

  // Load user profile config from user metadata or localStorage
  const userProfile = useMemo(() => {
    const cached = user?.id ? localStorage.getItem(`lingua_profile_${user.id}`) : null;
    const local = cached ? JSON.parse(cached) : {};
    return {
      academicLevel: user?.academicLevel || local.academicLevel || 'university_year_2',
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

  // Filter roadmap decks according to user major
  const roadmapDecks = useMemo(() => {
    return decks.filter(d => {
      const title = (d.title || '').toLowerCase();
      if (majorInfo.prefix && title.startsWith(majorInfo.prefix)) return true;
      if (userProfile.major === 'japanese' && d.language === 'ja') return true;
      return false;
    });
  }, [decks, majorInfo, userProfile.major]);

  const totalWords = roadmapDecks.reduce((sum, d) => sum + (d.card_count || 15), 0);
  const estimatedDays = Math.max(1, Math.ceil(totalWords / (userProfile.dailyWords || 15)));

  if (loading) {
    return <div className="loading-spinner"><div className="spinner"></div></div>;
  }

  return (
    <div>
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
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-md)' }}>
        <div>
          <h1 className="page-title">
            🧭 <span className="text-gradient">Lộ Trình Học Cá Nhân Hóa</span>
          </h1>
          <p className="page-subtitle">
            Học chuẩn theo chuyên ngành đại học và mục tiêu thời gian mỗi ngày của bạn
          </p>
        </div>
        <button className="btn btn-secondary" onClick={() => setShowEditModal(true)}>
          ⚙️ Thay đổi ngành & mục tiêu
        </button>
      </div>

      {/* Profile Overview Card */}
      <div className="glass-card" style={{ padding: '1.5rem', marginBottom: '2rem', border: '1px solid rgba(99, 102, 241, 0.25)', background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(168, 85, 247, 0.05) 100%)' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1.25rem' }}>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>🎓 Đối tượng & Trình độ:</span>
            <div style={{ fontWeight: '600', fontSize: '1rem', marginTop: '2px' }}>
              {ACADEMIC_LEVEL_NAMES[userProfile.academicLevel] || 'Sinh viên Đại học'}
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>📚 Khoa / Chuyên ngành:</span>
            <div style={{ fontWeight: '600', fontSize: '1rem', marginTop: '2px', color: 'var(--primary-color)' }}>
              {majorInfo.icon} {majorInfo.title}
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>⏱️ Thời gian học mỗi ngày:</span>
            <div style={{ fontWeight: '600', fontSize: '1rem', marginTop: '2px' }}>
              {userProfile.dailyMinutes} phút / ngày
            </div>
          </div>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>🎯 Tốc độ mục tiêu:</span>
            <div style={{ fontWeight: '600', fontSize: '1rem', marginTop: '2px', color: '#10b981' }}>
              {userProfile.dailyWords} từ / ngày (~{estimatedDays} ngày về đích)
            </div>
          </div>
        </div>
      </div>

      {/* Today's Target Action Card */}
      {roadmapDecks.length > 0 && (
        <div className="glass-card" style={{ padding: '1.5rem', marginBottom: '2rem', borderLeft: '4px solid var(--primary-color)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
            <div>
              <span style={{ fontSize: '0.8rem', padding: '3px 10px', borderRadius: '12px', background: 'rgba(99, 102, 241, 0.2)', color: 'var(--primary-color)', fontWeight: '600' }}>
                🌟 BÀI HỌC HÔM NAY (DAY 1)
              </span>
              <h2 style={{ fontSize: '1.35rem', marginTop: '0.5rem', fontWeight: '700' }}>
                {roadmapDecks[0]?.title}
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
                {roadmapDecks[0]?.description || 'Bắt đầu bài học đầu tiên trong lộ trình chuyên ngành của bạn.'}
              </p>
            </div>
            <button
              className="btn btn-primary"
              style={{ padding: '0.75rem 1.75rem', fontSize: '1rem' }}
              onClick={() => navigate(`/decks/${roadmapDecks[0]?.id}`)}
            >
              🚀 Bắt đầu học ngay ({roadmapDecks[0]?.card_count || 15} từ)
            </button>
          </div>
        </div>
      )}

      {/* Roadmap Timeline */}
      <div style={{ marginBottom: '1.5rem' }}>
        <h2 style={{ fontSize: '1.25rem', fontWeight: '700', marginBottom: '1rem' }}>
          📍 Toàn Bộ Chặng Lộ Trình ({roadmapDecks.length} bài học - {totalWords} từ vựng)
        </h2>

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
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {roadmapDecks.map((deck, idx) => {
              const dayNumber = idx + 1;
              const isFirst = idx === 0;

              return (
                <div
                  key={deck.id}
                  className="glass-card"
                  onClick={() => navigate(`/decks/${deck.id}`)}
                  style={{
                    padding: '1.25rem 1.5rem',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    cursor: 'pointer',
                    transition: 'all 0.2s ease',
                    border: isFirst ? '1px solid var(--primary-color)' : '1px solid rgba(255,255,255,0.06)',
                    background: isFirst ? 'rgba(99, 102, 241, 0.08)' : 'rgba(255,255,255,0.02)'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
                    <div style={{
                      width: '44px',
                      height: '44px',
                      borderRadius: '50%',
                      background: isFirst ? 'var(--primary-color)' : 'rgba(255,255,255,0.05)',
                      color: '#fff',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: '700',
                      fontSize: '0.95rem'
                    }}>
                      {dayNumber}
                    </div>

                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <span style={{ fontSize: '0.75rem', color: isFirst ? 'var(--primary-color)' : 'var(--text-muted)', fontWeight: '600' }}>
                          DAY {dayNumber} • {userProfile.dailyMinutes} PHÚT
                        </span>
                      </div>
                      <h3 style={{ fontSize: '1.05rem', fontWeight: '600', marginTop: '2px' }}>
                        {deck.title}
                      </h3>
                      <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                        {deck.description}
                      </p>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                      {deck.card_count || 15} từ
                    </span>
                    <button className={`btn btn-sm ${isFirst ? 'btn-primary' : 'btn-secondary'}`}>
                      {isFirst ? 'Học ngay' : 'Vào bài'}
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
