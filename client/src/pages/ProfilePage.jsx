import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../services/supabase';
import { useToast } from '../hooks/useToast';
import { useTranslation } from '../hooks/useTranslation';
import { useNavigate } from 'react-router-dom';

const ProfilePage = () => {
  const { user, updateUser, logout } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const { t, setLanguage } = useTranslation();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    username: '',
    academicLevel: 'university_year_2',
    major: 'it',
    dailyMinutes: 15,
    dailyWords: 15,
    studyGoal: 'career',
    preferredLanguage: 'vi'
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (user) {
      const cached = localStorage.getItem(`lingua_profile_${user.id}`);
      const local = cached ? JSON.parse(cached) : {};

      setForm({
        username: user.username || user.email?.split('@')[0] || '',
        academicLevel: user.academicLevel || local.academicLevel || 'university_year_2',
        major: user.major || local.major || 'it',
        dailyMinutes: user.dailyMinutes || local.dailyMinutes || 15,
        dailyWords: user.dailyWords || local.dailyWords || 15,
        studyGoal: user.studyGoal || local.studyGoal || 'career',
        preferredLanguage: user.preferredLanguage || local.preferredLanguage || 'vi'
      });
    }
  }, [user]);

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const updatedData = {
        username: form.username,
        academicLevel: form.academicLevel,
        major: form.major,
        dailyMinutes: parseInt(form.dailyMinutes),
        dailyWords: parseInt(form.dailyWords),
        studyGoal: form.studyGoal,
        preferredLanguage: form.preferredLanguage,
        profile_setup_completed: true
      };

      // 1. Update Supabase auth user metadata
      const { error } = await supabase.auth.updateUser({
        data: updatedData
      });

      if (error) throw error;

      // 2. Cache in localStorage
      if (user?.id) {
        localStorage.setItem(`lingua_profile_${user.id}`, JSON.stringify(updatedData));
      }

      updateUser(updatedData);
      setLanguage(form.preferredLanguage);
      addToast('✅ Đã lưu thông tin hồ sơ và cập nhật lộ trình học!', 'success');
    } catch (err) {
      console.error('Error saving profile:', err);
      addToast('Lỗi khi lưu thông tin hồ sơ.', 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <ToastContainer />
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-md)' }}>
        <div>
          <h1 className="page-title">⚙️ <span className="text-gradient">Hồ Sơ & Thiết Lập Lộ Trình</span></h1>
          <p className="page-subtitle">Quản lý chuyên ngành, mục tiêu học và tài khoản của bạn</p>
        </div>
        <button className="btn btn-primary" onClick={() => navigate('/roadmap')}>
          🧭 Xem Lộ Trình Học
        </button>
      </div>

      <div style={{ maxWidth: '720px', margin: '0 auto' }}>
        <div className="glass-card" style={{ padding: '2rem' }}>
          
          {/* Avatar & Basic Info */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', marginBottom: '2rem', paddingBottom: '1.5rem', borderBottom: '1px solid rgba(255,255,255,0.08)' }}>
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, var(--primary-color), #ec4899)',
              color: '#fff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '1.75rem',
              fontWeight: '700'
            }}>
              {form.username?.charAt(0).toUpperCase() || 'U'}
            </div>
            <div>
              <h2 style={{ fontSize: '1.35rem', fontWeight: '700' }}>{form.username || 'Người học Lingua'}</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>{user?.email}</p>
            </div>
          </div>

          <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            
            {/* 1. Tên hiển thị */}
            <div className="form-group">
              <label className="form-label">👤 Tên hiển thị của bạn</label>
              <input
                className="form-input"
                value={form.username}
                onChange={e => setForm(p => ({ ...p, username: e.target.value }))}
                required
              />
            </div>

            {/* 2. Đối tượng / Năm học */}
            <div className="form-group">
              <label className="form-label">🎓 Bạn đang học lớp mấy / Đại học năm mấy?</label>
              <select
                className="form-select"
                value={form.academicLevel}
                onChange={e => setForm(p => ({ ...p, academicLevel: e.target.value }))}
              >
                <option value="high_school">🏫 Học sinh THPT (Lớp 10 - 12)</option>
                <option value="university_year_1">🌱 Sinh viên Đại học Năm 1</option>
                <option value="university_year_2">📘 Sinh viên Đại học Năm 2</option>
                <option value="university_year_3">📙 Sinh viên Đại học Năm 3</option>
                <option value="university_year_4">🎓 Sinh viên Đại học Năm 4 / Năm cuối</option>
                <option value="working">💼 Đã tốt nghiệp / Đang đi làm</option>
              </select>
            </div>

            {/* 3. Chuyên ngành / Khoa */}
            <div className="form-group">
              <label className="form-label">📚 Khoa / Chuyên ngành học tập chính</label>
              <select
                className="form-select"
                value={form.major}
                onChange={e => setForm(p => ({ ...p, major: e.target.value }))}
              >
                <option value="it">💻 Công nghệ Thông tin & Phần mềm (150 từ / 10 bài)</option>
                <option value="medical">🏥 Y Khoa, Dược phẩm & Lâm sàng (150 từ / 10 bài)</option>
                <option value="economics">📊 Kinh Tế, Tài Chính & Ngân Hàng (150 từ / 10 bài)</option>
                <option value="engineering">⚙️ Kỹ Thuật, Cơ Khí & Điện Tử (150 từ / 10 bài)</option>
                <option value="law">⚖️ Luật Pháp, Chính Trị & Ngoại Giao (120 từ / 8 bài)</option>
                <option value="toeic">💼 Luyện thi TOEIC & Giao tiếp Công sở (180 từ / 12 bài)</option>
                <option value="ielts">🎓 Luyện thi IELTS Academic Band 7.0+ (150 từ / 10 bài)</option>
                <option value="japanese">🇯🇵 Tiếng Nhật Chuyên Sâu (JLPT & Từ Vựng)</option>
              </select>
            </div>

            {/* 4. Thời gian học mỗi ngày & Số từ mục tiêu */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">⏱️ Thời gian học mỗi ngày</label>
                <select
                  className="form-select"
                  value={form.dailyMinutes}
                  onChange={e => setForm(p => ({ ...p, dailyMinutes: parseInt(e.target.value) }))}
                >
                  <option value={10}>10 phút / ngày</option>
                  <option value={15}>15 phút / ngày (Khuyên dùng)</option>
                  <option value={30}>30 phút / ngày</option>
                  <option value={45}>45 phút / ngày</option>
                  <option value={60}>60 phút / ngày</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">📖 Số từ mục tiêu mỗi ngày</label>
                <select
                  className="form-select"
                  value={form.dailyWords}
                  onChange={e => setForm(p => ({ ...p, dailyWords: parseInt(e.target.value) }))}
                >
                  <option value={10}>10 từ / ngày</option>
                  <option value={15}>15 từ (1 bài) / ngày</option>
                  <option value={20}>20 từ / ngày</option>
                  <option value={30}>30 từ (2 bài) / ngày</option>
                </select>
              </div>
            </div>

            {/* 5. Ngôn ngữ hiển thị */}
            <div className="form-group">
              <label className="form-label">🌐 Ngôn ngữ giao diện</label>
              <select
                className="form-select"
                value={form.preferredLanguage}
                onChange={e => setForm(p => ({ ...p, preferredLanguage: e.target.value }))}
              >
                <option value="vi">🇻🇳 Tiếng Việt</option>
                <option value="en">🇬🇧 English</option>
                <option value="ja">🇯🇵 日本語 (Japanese)</option>
              </select>
            </div>

            {/* Actions */}
            <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
              <button
                type="submit"
                className="btn btn-primary"
                disabled={saving}
                style={{ flex: 1, padding: '0.85rem' }}
              >
                {saving ? 'Đang lưu...' : '💾 Lưu thay đổi & Cập nhật lộ trình'}
              </button>

              <button
                type="button"
                className="btn btn-danger"
                onClick={logout}
                style={{ minWidth: '130px' }}
              >
                🚪 Đăng xuất
              </button>
            </div>

          </form>

        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
