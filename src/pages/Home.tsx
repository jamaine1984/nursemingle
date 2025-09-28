import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import TinderCard from 'react-tinder-card';
import { Heart, X, RotateCcw, MessageSquare, Zap } from 'lucide-react';
import { authService, userService, matchingService } from '../services/authService';
import { useAppStore } from '../store';
import { User } from '../types';

const Home = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [swipedUsers, setSwipedUsers] = useState(new Set<string>());
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
          // Show match notification
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

  const currentCards = users.slice(currentIndex, currentIndex + 5);

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-400 to-blue-500 p-4">
      <div className="max-w-md mx-auto">
        <h1 className="text-white text-2xl font-bold text-center mb-6">Find Your Match</h1>

        {loading ? (
          <div className="relative h-96 flex items-center justify-center">
            <div className="text-white text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
              <p>Loading profiles...</p>
            </div>
          </div>
        ) : (
          <div className="relative h-96">
            {currentCards.map((user, index) => (
              <TinderCard
                key={user.id}
                onSwipe={(dir) => onSwipe(dir, user.id)}
                preventSwipe={['up', 'down']}
                className="absolute w-full h-full"
              >
                <div className="bg-white rounded-xl shadow-lg p-6 h-full flex flex-col justify-between border-2 border-white">
                  {user.avatar ? (
                    <img
                      src={user.avatar}
                      alt={user.name}
                      className="w-full h-48 object-cover rounded-lg"
                    />
                  ) : (
                    <div className="w-full h-48 bg-gray-300 rounded-lg flex items-center justify-center">
                      <span className="text-gray-500">No Photo</span>
                    </div>
                  )}
                  <div className="text-center">
                    <h3 className="text-xl font-bold text-gray-800">
                      {user.name}, {user.age}
                    </h3>
                    <p className="text-gray-600">{user.specialty}</p>
                    <p className="text-gray-600 text-sm">{user.location}</p>
                    <p className="text-gray-700 text-sm mt-2">{user.about}</p>
                    <div className="flex flex-wrap justify-center gap-1 mt-2">
                      {user.interests && user.interests.slice(0, 3).map((interest, i) => (
                        <span key={i} className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs">
                          {interest}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </TinderCard>
            ))}
          </div>
        )}

        {users.length === 0 && !loading && (
          <div className="text-center text-white mt-8">
            <p className="text-lg">No more profiles to swipe!</p>
            <p className="text-sm opacity-80">Check back later.</p>
          </div>
        )}

        <div className="flex justify-center space-x-6 mt-8">
          <button
            onClick={() => currentIndex > 0 && setCurrentIndex(prev => prev - 1)}
            className="bg-white bg-opacity-20 text-white p-4 rounded-full hover:bg-opacity-30 transition-colors"
          >
            <RotateCcw size={24} />
          </button>
          <button
            onClick={() => currentIndex < users.length - 1 && setCurrentIndex(prev => prev + 1)}
            className="bg-red-500 text-white p-4 rounded-full hover:bg-red-600 transition-colors"
          >
            <X size={24} />
          </button>
          <button
            onClick={() => currentIndex < users.length - 1 && setCurrentIndex(prev => prev + 1)}
            className="bg-green-500 text-white p-4 rounded-full hover:bg-green-600 transition-colors"
          >
            <Heart size={24} />
          </button>
          <button
            onClick={() => navigate('/messages')}
            className="bg-white bg-opacity-20 text-white p-4 rounded-full hover:bg-opacity-30 transition-colors"
          >
            <MessageSquare size={24} />
          </button>
          <button className="bg-purple-500 text-white p-4 rounded-full hover:bg-purple-600 transition-colors">
            <Zap size={24} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default Home;