import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useTranslation } from '../hooks/useTranslation';

const Login = () => {
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { loginWithGoogle } = useAuth();
  const { t } = useTranslation();

  const handleGoogleLogin = async () => {
    setError('');
    setLoading(true);
    try {
      await loginWithGoogle();
    } catch (err) {
      setError(err.message || 'Failed to sign in with Google');
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="glass-card" style={{ textAlign: 'center', padding: '3rem 2rem' }}>
          <div className="auth-logo-section" style={{ marginBottom: '2rem' }}>
            <div className="auth-logo" style={{ fontSize: '3.5rem', marginBottom: '1rem' }}>🎓</div>
            <h1 className="auth-title" style={{ fontSize: '2rem', fontWeight: '700' }}>Lingua Mochi</h1>
            <p className="auth-subtitle" style={{ opacity: 0.8, marginTop: '0.5rem' }}>
              Học từ vựng thông minh cùng Supabase
            </p>
          </div>

          {error && (
            <div className="auth-error" style={{ marginBottom: '1.5rem' }}>
              {error}
            </div>
          )}

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem', marginTop: '1rem' }}>
            <button
              type="button"
              className="btn"
              onClick={handleGoogleLogin}
              disabled={loading}
              style={{
                background: '#ffffff',
                color: '#1f2937',
                border: '1px solid #e5e7eb',
                padding: '0.875rem 1.5rem',
                borderRadius: '12px',
                fontSize: '1rem',
                fontWeight: '600',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '0.75rem',
                boxShadow: '0 4px 14px rgba(0, 0, 0, 0.1)',
                cursor: loading ? 'not-allowed' : 'pointer',
                transition: 'all 0.2s ease',
                width: '100%'
              }}
              onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
              onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
              {loading ? 'Đang kết nối tới Google...' : 'Đăng nhập bằng Google'}
            </button>
          </div>

          <div style={{ marginTop: '2rem', fontSize: '0.875rem', color: '#9ca3af' }}>
            Bằng cách đăng nhập, bạn đồng ý với Điều khoản & Chính sách quyền riêng tư
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
