import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAppStore } from './store';
import Auth from './pages/Auth-fixed';
import Home from './pages/Home-working';
import Likes from './pages/Likes';
import Messages from './pages/Messages';
import SpeedDating from './pages/SpeedDating';
import Gifts from './pages/Gifts';
import Profile from './pages/Profile';
import VideoCall from './components/VideoCall';

const App: React.FC = () => {
  const { currentUser, isAuthenticated, isLoading, error } = useAppStore();

  // Show loading screen while checking auth state
  if (isLoading) {
    return (
      <div style={{
        minHeight: '100vh',
        background: 'linear-gradient(to bottom right, #ec4899, #3b82f6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}>
        <div style={{ color: 'white', textAlign: 'center' }}>
          <div style={{
            width: '64px',
            height: '64px',
            border: '2px solid white',
            borderTop: '2px solid transparent',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '0 auto 16px'
          }}></div>
          <p style={{ fontSize: '20px' }}>Loading Nurse Mingle...</p>
        </div>
      </div>
    );
  }

  // Show error screen if there's a critical error
  if (error && !isAuthenticated) {
    return (
      <div style={{
        minHeight: '100vh',
        background: 'linear-gradient(to bottom right, #ec4899, #3b82f6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px'
      }}>
        <div style={{
          backgroundColor: 'white',
          borderRadius: '24px',
          boxShadow: '0 25px 50px rgba(0,0,0,0.25)',
          padding: '32px',
          width: '100%',
          maxWidth: '400px',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '64px', marginBottom: '16px' }}>⚠️</div>
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#1f2937', marginBottom: '16px' }}>Something went wrong</h1>
          <p style={{ color: '#6b7280', marginBottom: '24px' }}>{error}</p>
          <button
            onClick={() => window.location.reload()}
            style={{
              background: 'linear-gradient(to right, #ec4899, #3b82f6)',
              color: 'white',
              padding: '12px 24px',
              borderRadius: '12px',
              fontWeight: '600',
              border: 'none',
              cursor: 'pointer',
              boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
              transition: 'box-shadow 0.2s'
            }}
          >
            Reload App
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="App">
      <Routes>
        {/* Public routes */}
        <Route
          path="/auth"
          element={isAuthenticated ? <Navigate to="/home" replace /> : <Auth />}
        />

        {/* Protected routes */}
        <Route
          path="/home"
          element={isAuthenticated ? <Home /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/likes"
          element={isAuthenticated ? <Likes /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/messages"
          element={isAuthenticated ? <Messages /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/speed-dating"
          element={isAuthenticated ? <SpeedDating /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/gifts"
          element={isAuthenticated ? <Gifts /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/profile"
          element={isAuthenticated ? <Profile /> : <Navigate to="/auth" replace />}
        />

        <Route
          path="/video-call/:roomName"
          element={isAuthenticated ? <VideoCall /> : <Navigate to="/auth" replace />}
        />

        {/* Default route */}
        <Route
          path="/"
          element={
            isAuthenticated ? <Navigate to="/home" replace /> : <Navigate to="/auth" replace />
          }
        />

        {/* Catch all route */}
        <Route
          path="*"
          element={
            isAuthenticated ? <Navigate to="/home" replace /> : <Navigate to="/auth" replace />
          }
        />
      </Routes>

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default App;