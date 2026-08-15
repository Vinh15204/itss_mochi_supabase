import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Sidebar from './components/Layout/Sidebar';
import OnboardingModal from './components/Onboarding/OnboardingModal';
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import RoadmapPage from './pages/RoadmapPage';
import DecksPage from './pages/DecksPage';
import FlashcardPage from './pages/FlashcardPage';
import ExtractPage from './pages/ExtractPage';
import MiniTestPage from './pages/MiniTestPage';
import GamesPage from './pages/GamesPage';
import ProfilePage from './pages/ProfilePage';

const ProtectedRoute = ({ children }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-spinner" style={{ minHeight: '100vh' }}>
        <div className="spinner"></div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" />;
  }

  return children;
};

const AppLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { user } = useAuth();
  const [showOnboarding, setShowOnboarding] = useState(false);

  useEffect(() => {
    if (user?.id) {
      const isCompletedMeta = user?.profile_setup_completed;
      const isCompletedLocal = localStorage.getItem(`lingua_onboarding_${user.id}`);
      
      // If user hasn't completed setup yet, show onboarding modal
      if (!isCompletedMeta && !isCompletedLocal) {
        setShowOnboarding(true);
      }
    }
  }, [user]);

  return (
    <div className="app-layout">
      <Sidebar sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />
      <main className="main-content">
        {children}
      </main>

      {/* Global Onboarding Modal for first-time users */}
      <OnboardingModal
        isOpen={showOnboarding}
        onClose={() => setShowOnboarding(false)}
        onComplete={() => setShowOnboarding(false)}
      />
    </div>
  );
};

const App = () => {
  return (
    <Router>
      <AuthProvider>
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Protected Routes */}
          <Route path="/dashboard" element={
            <ProtectedRoute>
              <AppLayout><Dashboard /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/roadmap" element={
            <ProtectedRoute>
              <AppLayout><RoadmapPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/decks" element={
            <ProtectedRoute>
              <AppLayout><DecksPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/decks/:deckId" element={
            <ProtectedRoute>
              <AppLayout><FlashcardPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/extract" element={
            <ProtectedRoute>
              <AppLayout><ExtractPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/test" element={
            <ProtectedRoute>
              <AppLayout><MiniTestPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/test/:deckId" element={
            <ProtectedRoute>
              <AppLayout><MiniTestPage /></AppLayout>
            </ProtectedRoute>
          } />
          <Route path="/games" element={
            <ProtectedRoute>
              <AppLayout><GamesPage /></AppLayout>
            </ProtectedRoute>
          } />

          <Route path="/profile" element={
            <ProtectedRoute>
              <AppLayout><ProfilePage /></AppLayout>
            </ProtectedRoute>
          } />
        </Routes>
      </AuthProvider>
    </Router>
  );
};

export default App;
