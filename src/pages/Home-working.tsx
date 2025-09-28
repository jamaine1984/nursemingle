import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Heart, X, RotateCcw, MessageSquare, Zap } from 'lucide-react';
import { authService, userService, matchingService } from '../services/authService';
import { useAppStore } from '../store';
import { User } from '../types';
import BottomNavigation from '../components/BottomNavigation';

const Home = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { currentUser, setError } = useAppStore();

  useEffect(() => {
    const initializeHome = async () => {
      try {
        setLoading(true);

        // Check if user is authenticated
        const user = authService.getCurrentUser();
        if (!user) {
          navigate('/auth');
          return;
        }

        // Load available users
        const availableUsers = await userService.getUsers([user.uid]);
        setUsers(availableUsers);
        setCurrentIndex(0);

      } catch (error) {
        console.error('Error loading home:', error);
        setError('Failed to load users');
      } finally {
        setLoading(false);
      }
    };

    initializeHome();

    // Auth state listener
    const unsubscribe = authService.onAuthStateChanged(user => {
      if (!user) navigate('/auth');
    });

    return () => {
      unsubscribe();
    };
  }, [navigate, setError]);

  const onSwipe = async (direction: string, userId: string) => {
    try {
      if (direction === 'right') {
        const isMatch = await matchingService.likeUser(userId);
        if (isMatch) {
          alert("It's a match! 🎉");
        }
      } else {
        await matchingService.passUser(userId);
      }

      // Move to next user
      const maxIndex = users.length - 1;
      if (currentIndex < maxIndex) {
        setCurrentIndex(prev => prev + 1);
      } else {
        // All users swiped, reload available users
        const user = authService.getCurrentUser();
        if (user) {
          const availableUsers = await userService.getUsers([user.uid]);
          setUsers(availableUsers);
          setCurrentIndex(0);
        }
      }
    } catch (error) {
      console.error('Error swiping:', error);
      setError('Failed to process swipe');
    }
  };

  const currentUser_card = users[currentIndex];

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
      padding: '20px'
    }}>
      <div style={{ maxWidth: '400px', margin: '0 auto' }}>
        <h1 style={{
          color: 'white',
          fontSize: '24px',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: '24px'
        }}>
          Find Your Match
        </h1>

        {loading ? (
          <div style={{
            position: 'relative',
            height: '400px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            <div style={{ textAlign: 'center', color: 'white' }}>
              <div style={{
                width: '48px',
                height: '48px',
                border: '3px solid rgba(255,255,255,0.3)',
                borderTop: '3px solid white',
                borderRadius: '50%',
                animation: 'spin 1s linear infinite',
                margin: '0 auto 16px'
              }}></div>
              <p>Loading profiles...</p>
            </div>
          </div>
        ) : currentUser_card ? (
          <div style={{
            position: 'relative',
            height: '400px',
            marginBottom: '32px'
          }}>
            <div style={{
              backgroundColor: 'white',
              borderRadius: '12px',
              boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
              padding: '24px',
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              border: '2px solid white'
            }}>
              {currentUser_card.avatar ? (
                <img
                  src={currentUser_card.avatar}
                  alt={currentUser_card.name}
                  style={{
                    width: '100%',
                    height: '200px',
                    objectFit: 'cover',
                    borderRadius: '8px'
                  }}
                />
              ) : (
                <div style={{
                  width: '100%',
                  height: '200px',
                  backgroundColor: '#d1d5db',
                  borderRadius: '8px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <span style={{ color: '#6b7280' }}>No Photo</span>
                </div>
              )}

              <div style={{ textAlign: 'center' }}>
                <h3 style={{
                  fontSize: '20px',
                  fontWeight: 'bold',
                  color: '#1f2937',
                  marginBottom: '8px'
                }}>
                  {currentUser_card.name}, {currentUser_card.age}
                </h3>
                <p style={{ color: '#4b5563', marginBottom: '4px' }}>
                  {currentUser_card.specialty}
                </p>
                <p style={{ color: '#4b5563', fontSize: '14px', marginBottom: '8px' }}>
                  {currentUser_card.location}
                </p>
                <p style={{ color: '#374151', fontSize: '14px', marginBottom: '8px' }}>
                  {currentUser_card.about}
                </p>

                <div style={{
                  display: 'flex',
                  flexWrap: 'wrap',
                  justifyContent: 'center',
                  gap: '4px'
                }}>
                  {currentUser_card.interests && currentUser_card.interests.slice(0, 3).map((interest, i) => (
                    <span
                      key={i}
                      style={{
                        backgroundColor: '#dbeafe',
                        color: '#1e40af',
                        padding: '4px 8px',
                        borderRadius: '16px',
                        fontSize: '12px'
                      }}
                    >
                      {interest}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div style={{
            textAlign: 'center',
            color: 'white',
            marginTop: '32px'
          }}>
            <p style={{ fontSize: '18px' }}>No more profiles to swipe!</p>
            <p style={{ fontSize: '14px', opacity: 0.8 }}>Check back later.</p>
          </div>
        )}

        <div style={{
          display: 'flex',
          justifyContent: 'center',
          gap: '24px'
        }}>
          <button
            onClick={() => currentIndex > 0 && setCurrentIndex(prev => prev - 1)}
            style={{
              backgroundColor: 'rgba(255,255,255,0.2)',
              color: 'white',
              padding: '16px',
              borderRadius: '50%',
              border: 'none',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.3)'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.2)'}
          >
            <RotateCcw size={24} />
          </button>

          <button
            onClick={() => currentUser_card && onSwipe('left', currentUser_card.id)}
            style={{
              backgroundColor: '#ef4444',
              color: 'white',
              padding: '16px',
              borderRadius: '50%',
              border: 'none',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#dc2626'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#ef4444'}
          >
            <X size={24} />
          </button>

          <button
            onClick={() => currentUser_card && onSwipe('right', currentUser_card.id)}
            style={{
              backgroundColor: '#10b981',
              color: 'white',
              padding: '16px',
              borderRadius: '50%',
              border: 'none',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#059669'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#10b981'}
          >
            <Heart size={24} />
          </button>

          <button
            onClick={() => navigate('/messages')}
            style={{
              backgroundColor: 'rgba(255,255,255,0.2)',
              color: 'white',
              padding: '16px',
              borderRadius: '50%',
              border: 'none',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.3)'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.2)'}
          >
            <MessageSquare size={24} />
          </button>

          <button
            style={{
              backgroundColor: '#8b5cf6',
              color: 'white',
              padding: '16px',
              borderRadius: '50%',
              border: 'none',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#7c3aed'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#8b5cf6'}
          >
            <Zap size={24} />
          </button>
        </div>
      </div>

      <BottomNavigation />

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default Home;