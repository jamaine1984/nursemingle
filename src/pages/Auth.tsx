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
        // New user, redirect to onboarding after signup
        navigate('/onboarding');
      } else {
        await authService.signIn(email, password);
        // Existing user, go to home
        navigate('/home');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-400 to-blue-500 flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl shadow-xl p-8 w-full max-w-md">
        <h1 className="text-3xl font-bold text-center mb-8 text-gray-800">
          {isSignup ? 'Join Nurse Mingle' : 'Welcome Back'}
        </h1>

        {error && <div className="bg-red-100 text-red-700 p-3 rounded-lg mb-4">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-pink-400 focus:border-transparent"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-pink-400 focus:border-transparent"
              required
              minLength={6}
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-pink-500 to-blue-500 text-white py-3 px-4 rounded-xl font-semibold hover:shadow-lg transition-shadow disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                {isSignup ? 'Creating Account...' : 'Logging In...'}
              </div>
            ) : (
              isSignup ? 'Create Account' : 'Log In'
            )}
          </button>
        </form>

        <div className="text-center mt-6">
          <button
            onClick={() => setIsSignup(!isSignup)}
            className="text-blue-600 hover:text-pink-600 font-medium"
          >
            {isSignup ? 'Already have an account? Log in' : "Don't have an account? Sign up"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default Auth;