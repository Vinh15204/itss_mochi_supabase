import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../services/supabase';
import { useTranslation } from '../hooks/useTranslation';

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

const Dashboard = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);

  const userProfile = useMemo(() => {
    const cached = user?.id ? localStorage.getItem(`lingua_profile_${user.id}`) : null;
    const local = cached ? JSON.parse(cached) : {};
    return {
      academicLevel: user?.academicLevel || local.academicLevel || 'university_year_2',
      major: user?.major || local.major || 'it',
      dailyMinutes: user?.dailyMinutes || local.dailyMinutes || 15,
      dailyWords: user?.dailyWords || local.dailyWords || 15,
    };
  }, [user]);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('decks')
        .select('*')
        .order('created_at', { ascending: true });

      if (error) throw error;
      setDecks(data || []);
    } catch (err) {
      console.error('Error loading dashboard data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboardData();
  }, []);

  const majorInfo = MAJOR_NAMES[userProfile.major] || MAJOR_NAMES.it;

  // Filter roadmap decks
  const roadmapDecks = useMemo(() => {
    return decks.filter(d => {
      const title = (d.title || '').toLowerCase();
      if (majorInfo.prefix && title.startsWith(majorInfo.prefix)) return true;
      if (userProfile.major === 'japanese' && d.language === 'ja') return true;
      return false;
    });
  }, [decks, majorInfo, userProfile.major]);

  const todayDeck = roadmapDecks[0] || decks[0];

  if (loading) {
    return (
      <div className="loading-spinner">
        <div className="spinner"></div>
      </div>
    );
  }

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">
          {t('dashboard.welcome')}, <span className="text-gradient">{user?.username}</span>! 👋
        </h1>
        <p className="page-subtitle">Sẵn sàng chinh phục mục tiêu từ vựng chuyên ngành hôm nay!</p>
      </div>

      {/* Featured: Personalized Daily Roadmap Action */}
      <div className="glass-card" style={{ padding: '2rem', marginBottom: '2rem', background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.15) 0%, rgba(168, 85, 247, 0.08) 100%)', border: '1px solid rgba(99, 102, 241, 0.3)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1.5rem' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
              <span style={{ fontSize: '0.8rem', padding: '3px 10px', borderRadius: '12px', background: 'rgba(99, 102, 241, 0.2)', color: 'var(--primary-color)', fontWeight: '600' }}>
                🧭 LỘ TRÌNH CHUYÊN NGÀNH: {majorInfo.title.toUpperCase()}
              </span>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                ⏱️ {userProfile.dailyMinutes} phút / {userProfile.dailyWords} từ mỗi ngày
              </span>
            </div>
            
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700' }}>
              {todayDeck ? todayDeck.title : 'Chưa có bài học trong lộ trình'}
            </h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem', marginTop: '0.35rem', maxWidth: '600px' }}>
              {todayDeck ? (todayDeck.description || 'Học ngay bài học hôm nay với các thẻ ghi nhớ flashcard có sẵn.') : 'Vào mục Lộ trình học để chọn chuyên ngành phù hợp!'}
            </p>
          </div>

          <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
            {todayDeck && (
              <button
                className="btn btn-primary"
                style={{ padding: '0.85rem 1.75rem', fontSize: '1rem' }}
                onClick={() => navigate(`/decks/${todayDeck.id}`)}
              >
                🚀 Bắt đầu học bài hôm nay ({todayDeck.card_count || 15} từ)
              </button>
            )}
            <button
              className="btn btn-secondary"
              style={{ padding: '0.85rem 1.25rem' }}
              onClick={() => navigate('/roadmap')}
            >
              🧭 Xem toàn bộ lộ trình
            </button>
          </div>
        </div>
      </div>

      {/* Stat Cards */}
      <div className="stat-cards" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', marginBottom: '2rem' }}>
        <div className="glass-card stat-card" onClick={() => navigate('/roadmap')} style={{ cursor: 'pointer' }}>
          <div className="stat-icon">{majorInfo.icon}</div>
          <div className="stat-value text-gradient">{roadmapDecks.length} bài</div>
          <div className="stat-label">Lộ trình {majorInfo.title}</div>
        </div>

        <div className="glass-card stat-card" onClick={() => navigate('/decks')} style={{ cursor: 'pointer' }}>
          <div className="stat-icon">📚</div>
          <div className="stat-value text-gradient">{decks.length}</div>
          <div className="stat-label">Tổng số bài học sẵn có</div>
        </div>

        <div className="glass-card stat-card" onClick={() => navigate('/profile')} style={{ cursor: 'pointer' }}>
          <div className="stat-icon">⏱️</div>
          <div className="stat-value text-gradient">{userProfile.dailyMinutes} phút</div>
          <div className="stat-label">Mục tiêu học mỗi ngày</div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="glass-card section-card">
        <div className="section-title">⚡ {t('dashboard.quickActions')}</div>
        <div className="quick-actions">
          <button className="quick-action-btn" onClick={() => navigate('/roadmap')}>
            <span className="action-icon">🧭</span>
            <span className="action-label">Lộ trình của tôi</span>
          </button>
          <button className="quick-action-btn" onClick={() => navigate('/decks')}>
            <span className="action-icon">📇</span>
            <span className="action-label">Kho bài học có sẵn</span>
          </button>
          <button className="quick-action-btn" onClick={() => navigate('/test')}>
            <span className="action-icon">📝</span>
            <span className="action-label">{t('dashboard.takeTest')}</span>
          </button>
          <button className="quick-action-btn" onClick={() => navigate('/extract')}>
            <span className="action-icon">✨</span>
            <span className="action-label">{t('dashboard.extractWords')}</span>
          </button>
        </div>
      </div>

      {/* Innovation & Startup Survey Banner */}
      <div 
        className="glass-card" 
        style={{ 
          marginTop: '2rem', 
          padding: '1.5rem 2rem', 
          background: 'linear-gradient(135deg, rgba(245, 158, 11, 0.12) 0%, rgba(239, 68, 68, 0.08) 100%)', 
          border: '1px solid rgba(245, 158, 11, 0.3)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1rem'
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '700', fontSize: '1.1rem', color: '#fbbf24' }}>
            <span>📋</span>
            <span>Khảo Sát Đổi Mới Sáng Tạo & Trải Nghiệm MVP</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginTop: '0.25rem' }}>
            Dành 1 phút chia sẻ cảm nhận trải nghiệm để giúp nhóm hoàn thiện sản phẩm môn CH2021!
          </p>
        </div>
        <button 
          className="btn btn-primary" 
          onClick={() => navigate('/survey')}
          style={{ background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)', border: 'none', color: '#fff', fontWeight: '600' }}
        >
          ✍️ Làm Khảo Sát Ngay
        </button>
      </div>
    </div>
  );
};

export default Dashboard;
