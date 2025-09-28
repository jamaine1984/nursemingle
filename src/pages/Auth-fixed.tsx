import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { useAppStore } from '../store';

const Auth = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSignup, setIsSignup] = useState(true);
  const navigate = useNavigate();
  const { setLoading, setError, error, isLoading } = useAppStore();

  useEffect(() => {
    const unsubscribe = authService.onAuthStateChanged(user => {
      if (user) {
        navigate('/home');
      }
    });
    return unsubscribe;
  }, [navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (isSignup) {
        await authService.signUp(email, password);
        navigate('/home');
      } else {
        await authService.signIn(email, password);
        navigate('/home');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px'
    }}>
      <div style={{
        backgroundColor: 'white',
        borderRadius: '15px',
        boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
        padding: '40px',
        width: '100%',
        maxWidth: '400px'
      }}>
        <h1 style={{
          fontSize: '28px',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: '30px',
          color: '#333'
        }}>
          {isSignup ? 'Join Nurse Mingle' : 'Welcome Back'}
        </h1>

        {error && (
          <div style={{
            backgroundColor: '#fef2f2',
            border: '1px solid #fecaca',
            color: '#dc2626',
            padding: '12px',
            borderRadius: '8px',
            marginBottom: '20px'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div>
            <label style={{
              display: 'block',
              fontSize: '14px',
              fontWeight: '500',
              color: '#374151',
              marginBottom: '8px'
            }}>
              Email
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px',
                border: '1px solid #d1d5db',
                borderRadius: '8px',
                fontSize: '16px',
                outline: 'none',
                transition: 'border-color 0.2s',
                boxSizing: 'border-box'
              }}
              onFocus={(e) => e.target.style.borderColor = '#f472b6'}
              onBlur={(e) => e.target.style.borderColor = '#d1d5db'}
              required
            />
          </div>

          <div>
            <label style={{
              display: 'block',
              fontSize: '14px',
              fontWeight: '500',
              color: '#374151',
              marginBottom: '8px'
            }}>
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px',
                border: '1px solid #d1d5db',
                borderRadius: '8px',
                fontSize: '16px',
                outline: 'none',
                transition: 'border-color 0.2s',
                boxSizing: 'border-box'
              }}
              onFocus={(e) => e.target.style.borderColor = '#f472b6'}
              onBlur={(e) => e.target.style.borderColor = '#d1d5db'}
              required
              minLength={6}
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            style={{
              width: '100%',
              background: isLoading ? '#9ca3af' : 'linear-gradient(135deg, #e91e63 0%, #3b82f6 100%)',
              color: 'white',
              padding: '12px 16px',
              borderRadius: '8px',
              fontSize: '16px',
              fontWeight: '600',
              border: 'none',
              cursor: isLoading ? 'not-allowed' : 'pointer',
              transition: 'all 0.2s',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px'
            }}
            onMouseOver={(e) => {
              if (!isLoading) {
                e.currentTarget.style.transform = 'translateY(-1px)';
                e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
              }
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'none';
            }}
          >
            {isLoading ? (
              <>
                <div style={{
                  width: '16px',
                  height: '16px',
                  border: '2px solid rgba(255,255,255,0.3)',
                  borderTop: '2px solid white',
                  borderRadius: '50%',
                  animation: 'spin 1s linear infinite'
                }}></div>
                {isSignup ? 'Creating Account...' : 'Logging In...'}
              </>
            ) : (
              isSignup ? 'Create Account' : 'Log In'
            )}
          </button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '24px' }}>
          <button
            onClick={() => setIsSignup(!isSignup)}
            style={{
              color: '#3b82f6',
              fontWeight: '500',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              fontSize: '14px'
            }}
            onMouseOver={(e) => e.currentTarget.style.color = '#e91e63'}
            onMouseOut={(e) => e.currentTarget.style.color = '#3b82f6'}
          >
            {isSignup ? 'Already have an account? Log in' : "Don't have an account? Sign up"}
          </button>
        </div>

        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    </div>
  );
};

export default Auth;