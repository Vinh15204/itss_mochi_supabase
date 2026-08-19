import { useState, useEffect, useMemo } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../services/supabase';
import { useToast } from '../hooks/useToast';
import { useNavigate } from 'react-router-dom';

const SurveyPage = () => {
  const { user } = useAuth();
  const { addToast, ToastContainer } = useToast();
  const navigate = useNavigate();

  // Tab mode: 'fill' (điền khảo sát) | 'stats' (admin xem thống kê)
  const [activeTab, setActiveTab] = useState('fill');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  // Dữ liệu danh sách khảo sát tải trực tiếp từ DB Supabase
  const [surveyList, setSurveyList] = useState([]);
  const [loadingList, setLoadingList] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterMajor, setFilterMajor] = useState('all');
  const [isDemoMode, setIsDemoMode] = useState(true); // Bật mặc định khi demo để che tên & email

  // Form điền khảo sát
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    academicYear: 'K67',
    major: 'CNTT / Kỹ thuật phần mềm',
    university: 'Đại học Bách khoa Hà Nội',
    appUnderstanding: '',
    valueAttraction: 5,
    valueAttractionReason: '',
    dailyUsageScenario: 'Trong các khoảng thời gian rảnh ngắn 5-10 phút giữa các ca học hoặc khi đợi xe buýt',
    mostImportantFeature: 'auto_extract',
    featureReason: '',
    competitiveAdvantage: '',
    improvementSuggestions: '',
    willingnessToPay: '49k_month',
    npsScore: 10,
    overallRating: 5
  });

  useEffect(() => {
    if (user) {
      setFormData(prev => ({
        ...prev,
        fullName: user.full_name || user.username || user.raw?.user_metadata?.full_name || '',
        email: user.email || ''
      }));
    }
  }, [user]);

  // Tải danh sách khảo sát 100% từ Database Supabase
  const fetchSurveys = async () => {
    setLoadingList(true);
    try {
      const { data, error } = await supabase
        .from('surveys')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Lỗi tải dữ liệu khảo sát từ Supabase:', error);
        addToast(`Không thể tải dữ liệu: ${error.message}`, 'error');
      } else {
        setSurveyList(data || []);
      }
    } catch (err) {
      console.error('Supabase fetch error:', err);
    } finally {
      setLoadingList(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'stats') {
      fetchSurveys();
    }
  }, [activeTab]);

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);

    const surveyPayload = {
      user_id: user?.id || null,
      full_name: formData.fullName,
      email: formData.email,
      academic_year: formData.academicYear,
      major: formData.major,
      university: formData.university,
      app_understanding: formData.appUnderstanding,
      value_attraction_score: parseInt(formData.valueAttraction),
      value_attraction_reason: formData.valueAttractionReason,
      daily_usage_scenario: formData.dailyUsageScenario,
      most_important_feature: formData.mostImportantFeature,
      feature_reason: formData.featureReason,
      competitive_advantage: formData.competitiveAdvantage,
      improvement_suggestions: formData.improvementSuggestions,
      willingness_to_pay: formData.willingnessToPay,
      nps_score: parseInt(formData.npsScore),
      overall_rating: parseInt(formData.overallRating),
      created_at: new Date().toISOString()
    };

    try {
      const { error } = await supabase.from('surveys').insert([surveyPayload]);
      if (error) {
        throw error;
      }
      setSubmitted(true);
      addToast('🎉 Cảm ơn bạn! Phiếu khảo sát đã được lưu vào cơ sở dữ liệu.', 'success');
    } catch (err) {
      console.error('Lỗi khi gửi khảo sát:', err);
      addToast(`Gửi khảo sát thất bại: ${err.message || 'Vui lòng thử lại'}`, 'error');
    } finally {
      setSubmitting(false);
    }
  };

  // Tính toán các chỉ số thống kê (Analytics) từ dữ liệu DB
  const stats = useMemo(() => {
    const total = surveyList.length;
    if (total === 0) {
      return {
        total: 0,
        avgNps: 0,
        avgRating: 0,
        proRate: 0,
        features: {},
        pricing: {}
      };
    }

    const npsSum = surveyList.reduce((acc, cur) => acc + (cur.nps_score || 0), 0);
    const ratingSum = surveyList.reduce((acc, cur) => acc + (cur.overall_rating || 0), 0);
    const payingCount = surveyList.filter(s => s.willingness_to_pay === '49k_month' || s.willingness_to_pay === '349k_year').length;

    const features = {};
    const pricing = {};

    surveyList.forEach(s => {
      const f = s.most_important_feature || 'auto_extract';
      features[f] = (features[f] || 0) + 1;

      const p = s.willingness_to_pay || 'free_only';
      pricing[p] = (pricing[p] || 0) + 1;
    });

    return {
      total,
      avgNps: (npsSum / total).toFixed(1),
      avgRating: (ratingSum / total).toFixed(2),
      proRate: Math.round((payingCount / total) * 100),
      features,
      pricing
    };
  }, [surveyList]);

  // Lọc danh sách người dùng cho Admin
  const filteredSurveys = useMemo(() => {
    return surveyList.filter(s => {
      const matchText = (s.full_name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (s.email || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (s.major || '').toLowerCase().includes(searchTerm.toLowerCase());
      if (filterMajor === 'all') return matchText;
      return matchText && (s.major || '').toLowerCase().includes(filterMajor.toLowerCase());
    });
  }, [surveyList, searchTerm, filterMajor]);

  // Helper ẩn danh/che thông tin nhạy cảm khi thuyết trình Demo
  const maskName = (name) => {
    if (!name || typeof name !== 'string') return 'Người dùng ẩn danh';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) {
      const w = parts[0];
      return w.length > 2 ? `${w.slice(0, 1)}***${w.slice(-1)}` : `${w[0]}*`;
    }
    return parts
      .map((p, idx) => {
        if (idx === 0) return p; // Giữ họ đầu tiên
        return `${p[0]}***`;
      })
      .join(' ');
  };

  const maskEmail = (email) => {
    if (!email || typeof email !== 'string') return '***@***.com';
    const atIdx = email.indexOf('@');
    if (atIdx <= 0) return '***@***.com';
    const local = email.slice(0, atIdx);
    const domain = email.slice(atIdx + 1);

    const maskedLocal = local.length > 3
      ? `${local.slice(0, 2)}***${local.slice(-1)}`
      : `${local.slice(0, 1)}***`;

    const domainParts = domain.split('.');
    const maskedDomain = domainParts.length > 1
      ? `***.${domainParts.slice(1).join('.')}`
      : '***.com';

    return `${maskedLocal}@${maskedDomain}`;
  };

  const exportAllSurveysCSV = () => {
    if (surveyList.length === 0) {
      addToast('Chưa có dữ liệu khảo sát trong DB để xuất file!', 'info');
      return;
    }

    const headers = [
      'Thời gian', 'Họ tên', 'Email', 'Trường', 'Khóa', 'Ngành',
      'Hiểu về ứng dụng', 'Điểm giá trị (1-5)', 'Lý do giá trị',
      'Tình huống sử dụng', 'Tính năng cốt lõi', 'Lý do chọn tính năng',
      'So sánh đối thủ', 'Đề xuất cải tiến', 'Mức giá sẵn sàng trả',
      'Điểm NPS (1-10)', 'Đánh giá chung (1-5)'
    ];

    const rows = surveyList.map(r => [
      `"${r.created_at || ''}"`,
      `"${isDemoMode ? maskName(r.full_name) : (r.full_name || '')}"`,
      `"${isDemoMode ? maskEmail(r.email) : (r.email || '')}"`,
      `"${r.university || 'ĐHBK Hà Nội'}"`,
      `"${r.academic_year || ''}"`,
      `"${r.major || ''}"`,
      `"${(r.app_understanding || '').replace(/"/g, '""')}"`,
      r.value_attraction_score || 0,
      `"${(r.value_attraction_reason || '').replace(/"/g, '""')}"`,
      `"${(r.daily_usage_scenario || '').replace(/"/g, '""')}"`,
      `"${r.most_important_feature || ''}"`,
      `"${(r.feature_reason || '').replace(/"/g, '""')}"`,
      `"${(r.competitive_advantage || '').replace(/"/g, '""')}"`,
      `"${(r.improvement_suggestions || '').replace(/"/g, '""')}"`,
      `"${r.willingness_to_pay || ''}"`,
      r.nps_score || 0,
      r.overall_rating || 0
    ]);

    const csvContent = 'data:text/csv;charset=utf-8,\uFEFF' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `mochi_khao_sat_dmst_kn_${surveyList.length}_nguoi_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    addToast(`📥 Đã tải xuống file CSV chứa ${surveyList.length} phiếu khảo sát từ DB!`, 'success');
  };

  const featureLabels = {
    auto_extract: 'Trích xuất từ vựng tự động (3s)',
    flashcard_tts: 'Flashcard 3D & Giọng đọc bản xứ',
    mini_test: 'Mini Test tùy biến số câu',
    vocab_bank: 'Kho từ 6 chuyên ngành có sẵn',
    pvp_battle: 'Đấu trường PvP & Playoff'
  };

  return (
    <div style={{ maxWidth: '980px', margin: '0 auto', paddingBottom: '4rem' }}>
      <ToastContainer />

      {/* Header & Tabs */}
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem', marginBottom: '1.5rem' }}>
        <div>
          <h1 className="page-title">
            📋 <span className="text-gradient">Khảo Sát Đổi Mới Sáng Tạo</span>
          </h1>
          <p className="page-subtitle">Học phần Đổi mới sáng tạo & Khởi nghiệp (CH2021) – Đại học Bách khoa Hà Nội</p>
        </div>

        {/* Chuyển tab giữa Điền khảo sát và Xem Thống Kê Admin */}
        <div style={{ display: 'flex', gap: '0.5rem', background: 'rgba(255,255,255,0.05)', padding: '4px', borderRadius: '12px', border: '1px solid rgba(255,255,255,0.1)' }}>
          <button
            type="button"
            className={`btn ${activeTab === 'fill' ? 'btn-primary' : 'btn-ghost'}`}
            onClick={() => setActiveTab('fill')}
            style={{ padding: '0.5rem 1rem', fontSize: '0.875rem' }}
          >
            ✍️ Điền Khảo Sát
          </button>

          <button
            type="button"
            className={`btn ${activeTab === 'stats' ? 'btn-primary' : 'btn-ghost'}`}
            onClick={() => setActiveTab('stats')}
            style={{ padding: '0.5rem 1rem', fontSize: '0.875rem', position: 'relative' }}
          >
            📊 Thống Kê Admin
            {user?.isAdmin && (
              <span style={{ marginLeft: '6px', background: '#ef4444', color: '#fff', fontSize: '0.7rem', padding: '2px 6px', borderRadius: '10px', fontWeight: '700' }}>
                ADMIN
              </span>
            )}
          </button>
        </div>
      </div>

      {/* ========================================================
          TAB 1: TRANG THỐNG KÊ DÀNH CHO ADMIN (LẤY TỪ DB)
      ======================================================== */}
      {activeTab === 'stats' ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>

          {/* Header Action bar */}
          <div className="glass-card" style={{ padding: '1.25rem 1.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <span style={{ fontSize: '1.75rem' }}>📈</span>
              <div>
                <h3 style={{ fontSize: '1.15rem', fontWeight: '700', margin: 0 }}>Trung Tâm Phân Tích & Thống Kê Khảo Sát</h3>
                <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                  {loadingList ? 'Đang tải từ Database...' : `Đã tải ${stats.total} phản hồi từ cơ sở dữ liệu Supabase`}
                </p>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
              <button className="btn btn-outline" onClick={fetchSurveys} disabled={loadingList}>
                🔄 {loadingList ? 'Đang tải...' : 'Làm Mới DB'}
              </button>
              <button className="btn btn-primary" onClick={exportAllSurveysCSV} disabled={surveyList.length === 0}>
                📥 Xuất File Báo Cáo (CSV)
              </button>
            </div>
          </div>

          {/* 4 Thẻ KPI Thống Kê Tổng Quan */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' }}>
            <div className="glass-card stat-card" style={{ padding: '1.25rem' }}>
              <div className="stat-icon">👥</div>
              <div className="stat-value text-gradient">{stats.total}</div>
              <div className="stat-label">Tổng số phản hồi trong DB</div>
            </div>

            <div className="glass-card stat-card" style={{ padding: '1.25rem' }}>
              <div className="stat-icon">🌟</div>
              <div className="stat-value text-gradient">{stats.avgNps} / 10</div>
              <div className="stat-label">Điểm giới thiệu (NPS)</div>
            </div>

            <div className="glass-card stat-card" style={{ padding: '1.25rem' }}>
              <div className="stat-icon">⭐</div>
              <div className="stat-value text-gradient">{stats.avgRating} / 5.0</div>
              <div className="stat-label">Độ hài lòng chung</div>
            </div>

            <div className="glass-card stat-card" style={{ padding: '1.25rem' }}>
              <div className="stat-icon">💳</div>
              <div className="stat-value text-gradient">{stats.proRate}%</div>
              <div className="stat-label">Sẵn sàng trả phí Pro</div>
            </div>
          </div>

          {/* Biểu đồ phân tích tính năng & mức giá */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem' }}>

            {/* Phân tích tính năng yêu thích nhất */}
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ fontSize: '1.05rem', fontWeight: '700', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span>✨</span> Tính Năng Được Đánh Giá Cao Nhất
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
                {Object.entries(featureLabels).map(([key, label]) => {
                  const count = stats.features[key] || 0;
                  const percent = stats.total > 0 ? Math.round((count / stats.total) * 100) : 0;
                  return (
                    <div key={key}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.25rem' }}>
                        <span>{label}</span>
                        <span style={{ fontWeight: '700', color: 'var(--primary)' }}>{count} ({percent}%)</span>
                      </div>
                      <div style={{ height: '8px', background: 'rgba(255,255,255,0.08)', borderRadius: '4px', overflow: 'hidden' }}>
                        <div style={{ width: `${percent}%`, height: '100%', background: 'linear-gradient(90deg, #6366f1, #a855f7)', borderRadius: '4px' }}></div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Phân tích mức độ chi trả (Willingness to Pay) */}
            <div className="glass-card" style={{ padding: '1.5rem' }}>
              <h3 style={{ fontSize: '1.05rem', fontWeight: '700', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span>💰</span> Khảo Sát Mức Giá Chấp Nhận (WTP)
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
                {[
                  { key: '49k_month', label: '49.000 đ / tháng (Gói Tháng)' },
                  { key: '349k_year', label: '349.000 đ / năm (Gói Năm Tiết Kiệm)' },
                  { key: 'free_only', label: 'Chỉ dùng bản Miễn phí' },
                  { key: 'higher_pro', label: 'Sẵn sàng trả cao hơn (>50k)' }
                ].map(p => {
                  const count = stats.pricing[p.key] || 0;
                  const percent = stats.total > 0 ? Math.round((count / stats.total) * 100) : 0;
                  return (
                    <div key={p.key}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.25rem' }}>
                        <span>{p.label}</span>
                        <span style={{ fontWeight: '700', color: p.key === 'free_only' ? '#f59e0b' : '#10b981' }}>{count} ({percent}%)</span>
                      </div>
                      <div style={{ height: '8px', background: 'rgba(255,255,255,0.08)', borderRadius: '4px', overflow: 'hidden' }}>
                        <div style={{ width: `${percent}%`, height: '100%', background: p.key === 'free_only' ? 'linear-gradient(90deg, #f59e0b, #ef4444)' : 'linear-gradient(90deg, #10b981, #06b6d4)', borderRadius: '4px' }}></div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Bảng chi tiết toàn bộ phản hồi */}
          <div className="glass-card" style={{ padding: '1.5rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem', marginBottom: '1.25rem' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: '700', margin: 0 }}>
                📋 Danh Sách Phản Hồi Trong DB ({filteredSurveys.length})
              </h3>

              <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap', alignItems: 'center' }}>
                <button
                  type="button"
                  className="btn"
                  onClick={() => setIsDemoMode(prev => !prev)}
                  style={{
                    padding: '0.45rem 0.85rem',
                    fontSize: '0.8rem',
                    borderRadius: '8px',
                    border: isDemoMode ? '1px solid rgba(16, 185, 129, 0.5)' : '1px solid rgba(255, 255, 255, 0.2)',
                    background: isDemoMode ? 'rgba(16, 185, 129, 0.15)' : 'rgba(255, 255, 255, 0.05)',
                    color: isDemoMode ? '#34d399' : 'var(--text-secondary)',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.4rem',
                    fontWeight: '600'
                  }}
                  title="Bật/tắt chế độ ẩn danh thông tin cá nhân (Tên và Email) khi thuyết trình demo"
                >
                  <span>{isDemoMode ? '🛡️ Chế Độ Demo: BẬT (Đã che Tên & Email)' : '👁️ Chế Độ Demo: TẮT'}</span>
                </button>

                <input
                  type="text"
                  placeholder="🔍 Tìm kiếm..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  style={{ padding: '0.5rem 0.875rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff', fontSize: '0.875rem', minWidth: '180px' }}
                />

                <select
                  value={filterMajor}
                  onChange={(e) => setFilterMajor(e.target.value)}
                  style={{ padding: '0.5rem 0.875rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: '#1e1e2d', color: '#fff', fontSize: '0.875rem' }}
                >
                  <option value="all">Tất cả ngành</option>
                  <option value="Phần mềm">CNTT / Phần mềm</option>
                  <option value="Cơ khí">Cơ khí / Chế tạo</option>
                  <option value="Y">Y khoa / Y sinh</option>
                  <option value="Kinh tế">Kinh tế / QTKD</option>
                  <option value="Nhật">Tiếng Nhật</option>
                  <option value="Điện">Điện tử / Viễn thông</option>
                </select>
              </div>
            </div>

            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.875rem' }}>
                <thead>
                  <tr style={{ borderBottom: '1px solid rgba(255,255,255,0.12)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                    <th style={{ padding: '0.75rem 0.5rem' }}>Người Khảo Sát</th>
                    <th style={{ padding: '0.75rem 0.5rem' }}>Trường & Ngành</th>
                    <th style={{ padding: '0.75rem 0.5rem' }}>Gói Đăng Ký</th>
                    <th style={{ padding: '0.75rem 0.5rem' }}>Tính Năng Cốt Lõi</th>
                    <th style={{ padding: '0.75rem 0.5rem' }}>Tình Huống Sử Dụng</th>
                    <th style={{ padding: '0.75rem 0.5rem', textAlign: 'center' }}>Đánh Giá</th>
                    <th style={{ padding: '0.75rem 0.5rem', textAlign: 'center' }}>NPS</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredSurveys.map((item, idx) => (
                    <tr key={item.id || idx} style={{ borderBottom: '1px solid rgba(255,255,255,0.06)', transition: 'background 0.2s ease' }}>
                      <td style={{ padding: '0.75rem 0.5rem' }}>
                        <div style={{ fontWeight: '600', color: '#fff', display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                          {isDemoMode ? maskName(item.full_name) : (item.full_name || 'Khách vãng lai')}
                          {isDemoMode && (
                            <span title="Đã ẩn danh cho Demo" style={{ fontSize: '0.7rem', opacity: 0.7 }}>🔒</span>
                          )}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: isDemoMode ? '#a5b4fc' : 'var(--text-secondary)', fontFamily: isDemoMode ? 'monospace' : 'inherit' }}>
                          {isDemoMode ? maskEmail(item.email) : (item.email || 'Chưa cung cấp')}
                        </div>
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem' }}>
                        <div>{item.major || 'Chưa cập nhật'}</div>
                        <div style={{ fontSize: '0.75rem', color: '#6366f1' }}>{item.academic_year} • {item.university || 'HUST'}</div>
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem' }}>
                        <span style={{
                          padding: '3px 8px',
                          borderRadius: '6px',
                          background: item.willingness_to_pay === 'free_only' ? 'rgba(245, 158, 11, 0.15)' : 'rgba(16, 185, 129, 0.15)',
                          color: item.willingness_to_pay === 'free_only' ? '#fbbf24' : '#34d399',
                          fontSize: '0.75rem',
                          fontWeight: '700'
                        }}>
                          {item.willingness_to_pay === 'free_only' ? 'FREE ONLY' : item.willingness_to_pay === '349k_year' ? 'GÓI NĂM' : 'PRO THÁNG'}
                        </span>
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem' }}>
                        <span style={{ padding: '3px 8px', borderRadius: '6px', background: 'rgba(99, 102, 241, 0.15)', color: '#818cf8', fontSize: '0.8rem', fontWeight: '600' }}>
                          {featureLabels[item.most_important_feature] || item.most_important_feature}
                        </span>
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem', maxWidth: '220px', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                        {item.daily_usage_scenario}
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem', textAlign: 'center', fontWeight: '700', color: '#fbbf24' }}>
                        {item.overall_rating || 0} ⭐
                      </td>
                      <td style={{ padding: '0.75rem 0.5rem', textAlign: 'center', fontWeight: '700', color: item.nps_score >= 9 ? '#10b981' : item.nps_score >= 7 ? '#60a5fa' : '#f59e0b' }}>
                        {item.nps_score || 0}/10
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>

              {!loadingList && filteredSurveys.length === 0 && (
                <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>
                  Chưa có phản hồi nào trong DB hoặc không khớp bộ lọc.
                </div>
              )}
            </div>
          </div>
        </div>
      ) : (

        /* ========================================================
            TAB 2: BIỂU MẪU ĐIỀN KHẢO SÁT DÀNH CHO NGƯỜI DÙNG
        ======================================================== */
        submitted ? (
          <div className="glass-card" style={{ padding: '3rem 2rem', textAlign: 'center' }}>
            <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🎉</div>
            <h2 style={{ fontSize: '1.75rem', fontWeight: '700', marginBottom: '1rem', color: 'var(--primary)' }}>
              Gửi Khảo Sát Thành Công!
            </h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '2rem', lineHeight: '1.6' }}>
              Cảm ơn bạn đã dành thời gian trải nghiệm Siuuu (Siuuu Learn) và cung cấp phản hồi quan trọng.<br />
              Dữ liệu của bạn đã được lưu trực tiếp vào cơ sở dữ liệu của dự án.
            </p>

            <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' }}>
              <button className="btn btn-primary" onClick={() => navigate('/dashboard')}>
                🏠 Về Bảng Điều Khiển
              </button>
              <button className="btn btn-outline" onClick={() => { setSubmitted(false); setActiveTab('stats'); }}>
                📊 Xem Thống Kê Khảo Sát
              </button>
              <button className="btn btn-ghost" onClick={() => setSubmitted(false)}>
                📝 Điền Lại Phiếu Khác
              </button>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>

            {/* PHẦN 1: THÔNG TIN SINH VIÊN */}
            <div className="glass-card" style={{ padding: '1.75rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ background: 'var(--primary)', color: '#fff', width: '28px', height: '28px', borderRadius: '50%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.9rem' }}>1</span>
                Thông Tin Khách Hàng / Sinh Viên
              </h3>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Họ và tên <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.fullName}
                    onChange={(e) => handleChange('fullName', e.target.value)}
                    placeholder="Ví dụ: Nguyễn Văn A"
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Email liên hệ
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    placeholder="user@sis.hust.edu.vn"
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Trường Đại học <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.university}
                    onChange={(e) => handleChange('university', e.target.value)}
                    placeholder="Đại học Bách khoa Hà Nội"
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Khóa / Năm học <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <select
                    value={formData.academicYear}
                    onChange={(e) => handleChange('academicYear', e.target.value)}
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: '#1e1e2d', color: '#fff' }}
                  >
                    <option value="K65">Khóa K65 (Năm 4 / Năm cuối)</option>
                    <option value="K66">Khóa K66 (Năm 3 / Năm 4)</option>
                    <option value="K67">Khóa K67 (Năm 2)</option>
                    <option value="K68">Khóa K68 (Năm 1)</option>
                    <option value="K69">Khóa K69 (Tân sinh viên)</option>
                    <option value="Graduated">Đã tốt nghiệp / Đang đi làm</option>
                  </select>
                </div>

                <div style={{ gridColumn: '1 / -1' }}>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Chuyên ngành đang theo học <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.major}
                    onChange={(e) => handleChange('major', e.target.value)}
                    placeholder="Ví dụ: Kỹ thuật phần mềm, Tự động hóa, Kinh tế, Cơ khí, Y đa khoa..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>
              </div>
            </div>

            {/* PHẦN 2: NHẬN THỨC VÀ GIÁ TRỊ GIẢI PHÁP */}
            <div className="glass-card" style={{ padding: '1.75rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ background: 'var(--primary)', color: '#fff', width: '28px', height: '28px', borderRadius: '50%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.9rem' }}>2</span>
                Nhận Thức & Giá Trị Cốt Lõi Của Sản Phẩm
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Sau khi trải nghiệm, bạn hiểu như thế nào về ứng dụng Siuuu (Siuuu Learn)? <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <textarea
                    required
                    rows={3}
                    value={formData.appUnderstanding}
                    onChange={(e) => handleChange('appUnderstanding', e.target.value)}
                    placeholder="Ví dụ: Là ứng dụng học từ vựng siêu ngắn (Micro-learning) giúp tự động trích xuất từ vựng từ bài đọc trong 3 giây và kiểm tra nhanh bằng mini test..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff', resize: 'vertical' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Mức độ hấp dẫn của giá trị mà ứng dụng mang lại đối với bạn (1 = Rất thấp, 5 = Cực kỳ hấp dẫn):
                  </label>
                  <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', marginTop: '0.5rem' }}>
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        type="button"
                        key={star}
                        onClick={() => handleChange('valueAttraction', star)}
                        style={{
                          background: formData.valueAttraction >= star ? '#f59e0b' : 'rgba(255,255,255,0.1)',
                          color: '#fff',
                          border: 'none',
                          padding: '0.5rem 1rem',
                          borderRadius: '8px',
                          cursor: 'pointer',
                          fontWeight: '700',
                          fontSize: '1rem',
                          transition: 'all 0.2s ease'
                        }}
                      >
                        ★ {star}
                      </button>
                    ))}
                    <span style={{ marginLeft: '1rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                      {formData.valueAttraction === 5 ? 'Cực kỳ hấp dẫn' : formData.valueAttraction === 4 ? 'Hấp dẫn' : 'Bình thường'}
                    </span>
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Tại sao bạn lại đánh giá như vậy? (Lý do cụ thể)
                  </label>
                  <textarea
                    rows={2}
                    value={formData.valueAttractionReason}
                    onChange={(e) => handleChange('valueAttractionReason', e.target.value)}
                    placeholder="Ví dụ: Giúp em tiết kiệm thời gian gõ từng từ tạo thẻ, rất phù hợp khi đọc tài liệu kỹ thuật dài..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Trong học tập và cuộc sống, bạn nghĩ mình sẽ sử dụng ứng dụng này trong tình huống nào? <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.dailyUsageScenario}
                    onChange={(e) => handleChange('dailyUsageScenario', e.target.value)}
                    placeholder="Ví dụ: Khi chuẩn bị cho bài kiểm tra từ vựng ngày mai, lúc rảnh 10 phút chuyển ca, trên xe buýt..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>
              </div>
            </div>

            {/* PHẦN 3: ĐÁNH GIÁ TÍNH NĂNG CỐT LÕI */}
            <div className="glass-card" style={{ padding: '1.75rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ background: 'var(--primary)', color: '#fff', width: '28px', height: '28px', borderRadius: '50%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.9rem' }}>3</span>
                Đánh Giá Tính Năng Cốt Lõi (Feature Priority)
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.75rem', fontWeight: '600' }}>
                    Theo bạn, đâu là tính năng quan trọng và mang lại giá trị lớn nhất? <span style={{ color: '#ef4444' }}>*</span>
                  </label>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '0.75rem' }}>
                    {[
                      { id: 'auto_extract', icon: '✨', title: 'Trích xuất từ vựng tự động (3s)', desc: 'Dán bài đọc dài tự bóc tách từ mới & nghĩa chuyên ngành' },
                      { id: 'flashcard_tts', icon: '📇', title: 'Flashcard 3D & Giọng đọc bản xứ', desc: 'Lật thẻ ghi nhớ ngắt quãng SRS kết hợp âm thanh phát âm' },
                      { id: 'mini_test', icon: '📝', title: 'Mini Test tùy biến số câu', desc: 'Kiểm tra 5-15 câu tức thì theo thời gian rảnh rỗi' },
                      { id: 'vocab_bank', icon: '📚', title: 'Kho từ 6 chuyên ngành có sẵn', desc: 'Hơn 1,000+ từ vựng IT, Y khoa, Cơ khí, Kinh tế, TOEIC' },
                      { id: 'pvp_battle', icon: '🎮', title: 'Đấu trường PvP & Playoff', desc: 'Thi đấu tốc độ từ vựng trực tuyến với bạn bè' }
                    ].map(f => (
                      <div
                        key={f.id}
                        onClick={() => handleChange('mostImportantFeature', f.id)}
                        style={{
                          padding: '1rem',
                          borderRadius: '12px',
                          border: formData.mostImportantFeature === f.id ? '2px solid var(--primary)' : '1px solid rgba(255,255,255,0.1)',
                          background: formData.mostImportantFeature === f.id ? 'rgba(99, 102, 241, 0.15)' : 'rgba(255,255,255,0.03)',
                          cursor: 'pointer',
                          transition: 'all 0.2s ease'
                        }}
                      >
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '700', marginBottom: '0.25rem' }}>
                          <span>{f.icon}</span>
                          <span>{f.title}</span>
                        </div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                          {f.desc}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Tại sao bạn lại chọn tính năng này là quan trọng nhất?
                  </label>
                  <textarea
                    rows={2}
                    value={formData.featureReason}
                    onChange={(e) => handleChange('featureReason', e.target.value)}
                    placeholder="Giải thích lý do lựa chọn của bạn..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>
              </div>
            </div>

            {/* PHẦN 4: SO SÁNH CẠNH TRANH & ĐỀ XUẤT CẢI TIẾN */}
            <div className="glass-card" style={{ padding: '1.75rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ background: 'var(--primary)', color: '#fff', width: '28px', height: '28px', borderRadius: '50%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.9rem' }}>4</span>
                So Sánh Thị Trường & Đề Xuất Cải Tiến
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    So với các công cụ tương tự (như Quizlet, Anki, Duolingo), Siuuu vượt trội ở điểm nào?
                  </label>
                  <textarea
                    rows={2}
                    value={formData.competitiveAdvantage}
                    onChange={(e) => handleChange('competitiveAdvantage', e.target.value)}
                    placeholder="Ví dụ: Quizlet phải tự gõ từng từ rất mệt, còn Siuuu dán văn bản là ra luôn thẻ; bài test ngắn tùy chỉnh câu hỏi linh hoạt hơn..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Để giải quyết tốt hơn bài toán học từ vựng cho bạn, ứng dụng cần cải tiến/thêm điều gì? <span style={{ color: '#ef4444' }}>*</span>
                  </label>
                  <textarea
                    required
                    rows={2}
                    value={formData.improvementSuggestions}
                    onChange={(e) => handleChange('improvementSuggestions', e.target.value)}
                    placeholder="Ví dụ: Bổ sung thêm từ vựng chuyên ngành X, tăng độ tương phản màu chữ, thêm bảng xếp hạng bạn bè..."
                    style={{ width: '100%', padding: '0.75rem 1rem', borderRadius: '8px', border: '1px solid rgba(255,255,255,0.15)', background: 'rgba(255,255,255,0.05)', color: '#fff' }}
                  />
                </div>
              </div>
            </div>

            {/* PHẦN 5: KHẢO SÁT THƯƠNG MẠI HÓA (ĐMST & KN) */}
            <div className="glass-card" style={{ padding: '1.75rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span style={{ background: 'var(--primary)', color: '#fff', width: '28px', height: '28px', borderRadius: '50%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.9rem' }}>5</span>
                Khảo Sát Thương Mại Hóa & Mức Độ Sẵn Sàng Chi Trả
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.75rem', fontWeight: '600' }}>
                    Nếu ra mắt phiên bản chính thức (Mở khóa trích xuất không giới hạn + Full 6 kho từ chuyên ngành + Đấu trường PvP), bạn sẵn sàng chi trả mức giá nào?
                  </label>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '0.75rem' }}>
                    {[
                      { id: '49k_month', label: '49.000 đ / tháng', note: 'Bằng 1 cốc cà phê / trà sữa' },
                      { id: '349k_year', label: '349.000 đ / năm', note: 'Tiết kiệm 40% chi phí' },
                      { id: 'free_only', label: 'Chỉ dùng bản miễn phí', note: 'Chấp nhận giới hạn tính năng' },
                      { id: 'higher_pro', label: 'Sẵn sàng trả cao hơn', note: 'Nếu có thêm tính năng AI nâng cao' }
                    ].map(p => (
                      <label
                        key={p.id}
                        style={{
                          padding: '1rem',
                          borderRadius: '10px',
                          border: formData.willingnessToPay === p.id ? '2px solid var(--primary)' : '1px solid rgba(255,255,255,0.1)',
                          background: formData.willingnessToPay === p.id ? 'rgba(99, 102, 241, 0.15)' : 'rgba(255,255,255,0.03)',
                          display: 'flex',
                          flexDirection: 'column',
                          cursor: 'pointer'
                        }}
                      >
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '700' }}>
                          <input
                            type="radio"
                            name="willingnessToPay"
                            checked={formData.willingnessToPay === p.id}
                            onChange={() => handleChange('willingnessToPay', p.id)}
                          />
                          {p.label}
                        </div>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '0.25rem', paddingLeft: '1.4rem' }}>
                          {p.note}
                        </span>
                      </label>
                    ))}
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Mức độ sẵn sàng giới thiệu Siuuu cho bạn bè / nhóm học (Chỉ số NPS từ 1 đến 10 điểm):
                  </label>
                  <div style={{ display: 'flex', gap: '0.35rem', flexWrap: 'wrap', marginTop: '0.5rem' }}>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(num => (
                      <button
                        type="button"
                        key={num}
                        onClick={() => handleChange('npsScore', num)}
                        style={{
                          flex: '1',
                          minWidth: '36px',
                          padding: '0.6rem 0',
                          borderRadius: '8px',
                          border: 'none',
                          background: formData.npsScore === num ? 'var(--primary)' : 'rgba(255,255,255,0.08)',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: 'pointer',
                          transition: 'all 0.15s ease'
                        }}
                      >
                        {num}
                      </button>
                    ))}
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '0.35rem' }}>
                    <span>1: Hoàn toàn không giới thiệu</span>
                    <span>10: Chắc chắn sẽ giới thiệu</span>
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.875rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                    Đánh giá tổng quan về trải nghiệm sản phẩm Siuuu (MVP):
                  </label>
                  <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
                    {[1, 2, 3, 4, 5].map((star) => (
                      <span
                        key={star}
                        onClick={() => handleChange('overallRating', star)}
                        style={{
                          fontSize: '1.75rem',
                          cursor: 'pointer',
                          color: formData.overallRating >= star ? '#fbbf24' : 'rgba(255,255,255,0.2)',
                          transition: 'color 0.2s ease'
                        }}
                      >
                        ★
                      </span>
                    ))}
                    <span style={{ marginLeft: '0.75rem', fontWeight: '600', color: '#fbbf24' }}>
                      {formData.overallRating}/5 Sao
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* NÚT SUBMIT */}
            <div style={{ display: 'flex', gap: '1rem', justifyContent: 'flex-end', marginTop: '1rem' }}>
              <button
                type="submit"
                className="btn btn-primary"
                disabled={submitting}
                style={{ minWidth: '180px', fontSize: '1rem', padding: '0.875rem 1.75rem' }}
              >
                {submitting ? 'Đang gửi...' : '🚀 Hoàn Tất & Gửi Khảo Sát'}
              </button>
            </div>
          </form>
        ))}
    </div>
  );
};

export default SurveyPage;
