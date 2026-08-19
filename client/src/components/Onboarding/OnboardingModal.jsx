import { useState } from 'react';
import { supabase } from '../../services/supabase';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../hooks/useToast';
import { useNavigate } from 'react-router-dom';

const OnboardingModal = ({ isOpen, onClose, onComplete }) => {
  const { user, updateUser } = useAuth();
  const { addToast } = useToast();
  const navigate = useNavigate();

  const [step, setStep] = useState(1);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    academicLevel: 'university_year_2', // high_school | university_year_1/2/3/4 | graduated | working
    major: 'it', // it | medical | economics | engineering | law | toeic | ielts | japanese | other
    majorNameCustom: '',
    dailyMinutes: 15,
    dailyWords: 15,
    studyGoal: 'career', // career | exam | study_abroad | general
  });

  if (!isOpen) return null;

  const handleNext = () => {
    if (step < 3) {
      setStep(prev => prev + 1);
    } else {
      handleFinish();
    }
  };

  const handleBack = () => {
    if (step > 1) setStep(prev => prev - 1);
  };

  const handleFinish = async () => {
    try {
      setSaving(true);
      const profileData = {
        academicLevel: formData.academicLevel,
        major: formData.major,
        majorNameCustom: formData.majorNameCustom,
        dailyMinutes: parseInt(formData.dailyMinutes),
        dailyWords: parseInt(formData.dailyWords),
        studyGoal: formData.studyGoal,
        profile_setup_completed: true,
        setup_date: new Date().toISOString()
      };

      // 1. Update Supabase user metadata
      const { error } = await supabase.auth.updateUser({
        data: profileData
      });

      if (error) throw error;

      // 2. Cache in localStorage for instant retrieval
      if (user?.id) {
        localStorage.setItem(`lingua_profile_${user.id}`, JSON.stringify(profileData));
        localStorage.setItem(`lingua_onboarding_${user.id}`, 'completed');
      }

      updateUser(profileData);
      addToast('🎉 Đã thiết lập lộ trình học cá nhân hóa thành công!', 'success');

      if (onComplete) onComplete(profileData);
      if (onClose) onClose();

      navigate('/roadmap');
    } catch (err) {
      console.error('Error saving onboarding profile:', err);
      addToast('Lỗi khi lưu thông tin thiết lập. Vui lòng thử lại!', 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay" style={{ zIndex: 1100 }}>
      <div className="modal-content" style={{ maxWidth: '580px', width: '92%' }} onClick={e => e.stopPropagation()}>
        <div className="glass-card" style={{ padding: '2rem' }}>

          {/* Header */}
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
            <div style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>🎯</div>
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '0.25rem' }}>
              Thiết Lập Lộ Trình Học Cá Nhân
            </h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
              Hãy trả lời 3 câu hỏi nhanh để Siuuu Learn tối ưu hóa bài học theo đúng ngành học & thời gian của bạn
            </p>

            {/* Step Indicators */}
            <div style={{ display: 'flex', justifyContent: 'center', gap: '0.5rem', marginTop: '1rem' }}>
              {[1, 2, 3].map(i => (
                <div
                  key={i}
                  style={{
                    height: '6px',
                    width: i === step ? '36px' : '16px',
                    borderRadius: '3px',
                    background: i === step ? 'var(--primary-color)' : i < step ? 'rgba(99, 102, 241, 0.4)' : 'rgba(255,255,255,0.1)',
                    transition: 'all 0.3s ease'
                  }}
                />
              ))}
            </div>
          </div>

          {/* STEP 1: Academic Level */}
          {step === 1 && (
            <div>
              <h3 style={{ fontSize: '1.1rem', marginBottom: '1rem', color: 'var(--text-primary)' }}>
                1. Bạn hiện đang học năm mấy hoặc đã đi làm?
              </h3>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
                {[
                  { id: 'high_school', label: 'Học sinh THPT (Lớp 10-12)', icon: '🏫' },
                  { id: 'university_year_1', label: 'Sinh viên Năm 1 (Đại học)', icon: '🌱' },
                  { id: 'university_year_2', label: 'Sinh viên Năm 2 (Đại học)', icon: '📘' },
                  { id: 'university_year_3', label: 'Sinh viên Năm 3 (Đại học)', icon: '📙' },
                  { id: 'university_year_4', label: 'Sinh viên Năm 4 / Cuối', icon: '🎓' },
                  { id: 'working', label: 'Đã tốt nghiệp / Đi làm', icon: '💼' }
                ].map(item => (
                  <div
                    key={item.id}
                    onClick={() => setFormData(p => ({ ...p, academicLevel: item.id }))}
                    style={{
                      padding: '1rem',
                      borderRadius: 'var(--radius-md)',
                      border: '1px solid',
                      borderColor: formData.academicLevel === item.id ? 'var(--primary-color)' : 'rgba(255,255,255,0.1)',
                      background: formData.academicLevel === item.id ? 'rgba(99, 102, 241, 0.15)' : 'rgba(255,255,255,0.03)',
                      cursor: 'pointer',
                      transition: 'all 0.2s ease',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.75rem'
                    }}
                  >
                    <span style={{ fontSize: '1.4rem' }}>{item.icon}</span>
                    <span style={{ fontSize: '0.85rem', fontWeight: formData.academicLevel === item.id ? '600' : '400' }}>
                      {item.label}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* STEP 2: Major / Field of Study */}
          {step === 2 && (
            <div>
              <h3 style={{ fontSize: '1.1rem', marginBottom: '1rem', color: 'var(--text-primary)' }}>
                2. Khoa / Ngành học chính mà bạn quan tâm?
              </h3>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem', maxHeight: '280px', overflowY: 'auto', paddingRight: '4px' }}>
                {[
                  { id: 'it', label: 'Công nghệ Thông tin / Phần mềm', icon: '💻', words: '150 từ (10 bài)' },
                  { id: 'medical', label: 'Y Khoa / Dược / Lâm sàng', icon: '🏥', words: '150 từ (10 bài)' },
                  { id: 'economics', label: 'Kinh Tế / Tài Chính / Ngân Hàng', icon: '📊', words: '150 từ (10 bài)' },
                  { id: 'engineering', label: 'Kỹ Thuật / Cơ Khí / Điện Tử', icon: '⚙️', words: '150 từ (10 bài)' },
                  { id: 'law', label: 'Luật Pháp / Chính Trị / Ngoại Giao', icon: '⚖️', words: '120 từ (8 bài)' },
                  { id: 'toeic', label: 'Luyện thi TOEIC & Công Sở', icon: '💼', words: '180 từ (12 bài)' },
                  { id: 'ielts', label: 'Luyện thi IELTS Academic (7.0+)', icon: '🎓', words: '150 từ (10 bài)' },
                  { id: 'japanese', label: 'Tiếng Nhật Chuyên Sâu', icon: '🇯🇵', words: 'Từ vựng JLPT' }
                ].map(item => (
                  <div
                    key={item.id}
                    onClick={() => setFormData(p => ({ ...p, major: item.id }))}
                    style={{
                      padding: '0.85rem',
                      borderRadius: 'var(--radius-md)',
                      border: '1px solid',
                      borderColor: formData.major === item.id ? 'var(--primary-color)' : 'rgba(255,255,255,0.1)',
                      background: formData.major === item.id ? 'rgba(99, 102, 241, 0.15)' : 'rgba(255,255,255,0.03)',
                      cursor: 'pointer',
                      transition: 'all 0.2s ease',
                      display: 'flex',
                      flexDirection: 'column',
                      gap: '0.25rem'
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <span style={{ fontSize: '1.2rem' }}>{item.icon}</span>
                      <strong style={{ fontSize: '0.85rem' }}>{item.label}</strong>
                    </div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginLeft: '1.7rem' }}>
                      {item.words}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* STEP 3: Daily Time & Word Target */}
          {step === 3 && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              <h3 style={{ fontSize: '1.1rem', marginBottom: '0.25rem', color: 'var(--text-primary)' }}>
                3. Mục tiêu học tập mỗi ngày của bạn
              </h3>

              {/* Time Selection */}
              <div>
                <label className="form-label" style={{ marginBottom: '0.5rem', display: 'block' }}>
                  ⏱️ Thời gian có thể dành để học mỗi ngày:
                </label>
                <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                  {[
                    { min: 10, label: '10 phút' },
                    { min: 15, label: '15 phút (Khuyên dùng)' },
                    { min: 30, label: '30 phút' },
                    { min: 45, label: '45 phút' },
                    { min: 60, label: '60 phút' }
                  ].map(t => (
                    <button
                      key={t.min}
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, dailyMinutes: t.min }))}
                      style={{
                        padding: '0.5rem 0.85rem',
                        borderRadius: 'var(--radius-md)',
                        border: '1px solid',
                        borderColor: formData.dailyMinutes === t.min ? 'var(--primary-color)' : 'rgba(255,255,255,0.1)',
                        background: formData.dailyMinutes === t.min ? 'rgba(99, 102, 241, 0.2)' : 'rgba(255,255,255,0.03)',
                        color: formData.dailyMinutes === t.min ? '#fff' : 'var(--text-secondary)',
                        cursor: 'pointer',
                        fontSize: '0.85rem'
                      }}
                    >
                      {t.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Words Target Selection */}
              <div>
                <label className="form-label" style={{ marginBottom: '0.5rem', display: 'block' }}>
                  📖 Số từ vựng muốn học mỗi ngày:
                </label>
                <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                  {[
                    { words: 10, label: '10 từ / ngày' },
                    { words: 15, label: '15 từ (1 bài) / ngày' },
                    { words: 20, label: '20 từ / ngày' },
                    { words: 30, label: '30 từ (2 bài) / ngày' }
                  ].map(w => (
                    <button
                      key={w.words}
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, dailyWords: w.words }))}
                      style={{
                        padding: '0.5rem 0.85rem',
                        borderRadius: 'var(--radius-md)',
                        border: '1px solid',
                        borderColor: formData.dailyWords === w.words ? 'var(--accent-green, #10b981)' : 'rgba(255,255,255,0.1)',
                        background: formData.dailyWords === w.words ? 'rgba(16, 185, 129, 0.2)' : 'rgba(255,255,255,0.03)',
                        color: formData.dailyWords === w.words ? '#fff' : 'var(--text-secondary)',
                        cursor: 'pointer',
                        fontSize: '0.85rem'
                      }}
                    >
                      {w.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Estimate banner */}
              <div style={{ padding: '0.85rem', borderRadius: 'var(--radius-md)', background: 'rgba(99, 102, 241, 0.1)', border: '1px dashed rgba(99, 102, 241, 0.4)', fontSize: '0.85rem' }}>
                💡 <strong>Dự tính lộ trình:</strong> Với <strong>{formData.dailyWords} từ/ngày</strong> (~{formData.dailyMinutes} phút), bạn sẽ làm chủ trọn bộ 150 từ vựng chuyên ngành trong vòng <strong>{Math.ceil(150 / formData.dailyWords)} ngày</strong>!
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '1.75rem', gap: '0.75rem' }}>
            {step > 1 ? (
              <button className="btn btn-secondary" onClick={handleBack}>
                ⬅️ Quay lại
              </button>
            ) : <div />}

            <button
              className="btn btn-primary"
              onClick={handleNext}
              disabled={saving}
              style={{ minWidth: '140px' }}
            >
              {saving ? 'Đang tạo lộ trình...' : step === 3 ? 'Hoàn tất & Bắt đầu 🚀' : 'Tiếp tục ➡️'}
            </button>
          </div>

        </div>
      </div>
    </div>
  );
};

export default OnboardingModal;
