import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useTranslation } from '../../hooks/useTranslation';

const Sidebar = ({ sidebarOpen, setSidebarOpen }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { t } = useTranslation();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const navItems = [
    { path: '/dashboard', icon: '🏠', label: t('sidebar.dashboard') },
    { path: '/roadmap', icon: '🧭', label: 'Lộ trình học' },
    { path: '/decks', icon: '📚', label: t('sidebar.flashcards') },
    { path: '/extract', icon: '✨', label: t('sidebar.extract') },
    { path: '/test', icon: '📝', label: t('sidebar.test') },
    { path: '/games', icon: '🎮', label: 'Games' },
    { path: '/survey', icon: '📋', label: 'Khảo sát ĐMST' },
    { path: '/profile', icon: '⚙️', label: t('sidebar.settings') },
  ];

  return (
    <>
      <button className="mobile-nav-toggle" onClick={() => setSidebarOpen(!sidebarOpen)}>
        {sidebarOpen ? '✕' : '☰'}
      </button>

      <nav className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-header">
          <div className="sidebar-logo">🎓</div>
          <span className="sidebar-brand">
            <span className="text-gradient">Lingua</span>
          </span>
        </div>

        <div className="sidebar-nav">
          {navItems.map(item => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
              onClick={() => setSidebarOpen(false)}
            >
              <span className="nav-icon">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </div>

        <div className="sidebar-footer">
          <div className="user-info">
            {user?.avatar_url ? (
              <img
                src={user.avatar_url}
                alt="Avatar"
                className="user-avatar"
                style={{ width: '36px', height: '36px', borderRadius: '50%', objectFit: 'cover' }}
              />
            ) : (
              <div className="user-avatar">
                {user?.username?.charAt(0).toUpperCase() || 'U'}
              </div>
            )}
            <div className="user-details">
              <div className="user-name">{user?.username}</div>
              <div style={{ fontSize: '0.75rem', opacity: 0.7, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                {user?.email}
              </div>
            </div>
          </div>
          <button
            className="btn btn-ghost"
            onClick={handleLogout}
            style={{ width: '100%', marginTop: '0.75rem' }}
          >
            🚪 {t('sidebar.logout')}
          </button>
        </div>
      </nav>
    </>
  );
};

export default Sidebar;
