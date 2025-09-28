import React, { useState, useEffect } from 'react';
import { Settings, Edit, Heart, MessageSquare, Video, Star, Gift, Trophy } from 'lucide-react';
import BottomNavigation from '../components/BottomNavigation';
import { useAppStore } from '../store';

interface UserStats {
  matches: number;
  messages: number;
  likes: number;
  superlikes: number;
  giftsSent: number;
  giftsReceived: number;
  videoMinutes: number;
  speedDatingSessions: number;
}

const Profile: React.FC = () => {
  const { currentUser } = useAppStore();
  const [userStats, setUserStats] = useState<UserStats>({
    matches: 0,
    messages: 0,
    likes: 0,
    superlikes: 0,
    giftsSent: 0,
    giftsReceived: 0,
    videoMinutes: 0,
    speedDatingSessions: 0
  });
  const [activeTab, setActiveTab] = useState<'profile' | 'activity' | 'rewards' | 'settings'>('profile');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock user stats - replace with actual Firebase data
    const mockStats: UserStats = {
      matches: 24,
      messages: 156,
      likes: 89,
      superlikes: 12,
      giftsSent: 34,
      giftsReceived: 28,
      videoMinutes: 240,
      speedDatingSessions: 8
    };

    setTimeout(() => {
      setUserStats(mockStats);
      setLoading(false);
    }, 1000);
  }, []);

  const tabs = [
    { id: 'profile', label: 'Profile', icon: Edit },
    { id: 'activity', label: 'Activity', icon: Trophy },
    { id: 'rewards', label: 'Rewards', icon: Star },
    { id: 'settings', label: 'Settings', icon: Settings }
  ];

  const renderProfile = () => (
    <div style={{ padding: '20px' }}>
      {/* Profile Picture and Basic Info */}
      <div style={{ textAlign: 'center', marginBottom: '24px' }}>
        <div style={{
          width: '120px',
          height: '120px',
          borderRadius: '50%',
          backgroundColor: '#e5e7eb',
          margin: '0 auto 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '48px'
        }}>
          👩‍⚕️
        </div>
        <h2 style={{ fontSize: '24px', fontWeight: 'bold', margin: '0 0 4px 0', color: '#1f2937' }}>
          {currentUser?.displayName || 'Sarah Johnson'}
        </h2>
        <p style={{ color: '#6b7280', fontSize: '16px', margin: 0 }}>
          ICU Nurse • 28 years old
        </p>
        <p style={{ color: '#9ca3af', fontSize: '14px', marginTop: '4px' }}>
          New York, NY
        </p>
      </div>

      {/* Bio */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '8px', color: '#1f2937' }}>
          About Me
        </h3>
        <p style={{ color: '#6b7280', lineHeight: '1.5', margin: 0 }}>
          Passionate ICU nurse who loves helping people and making connections.
          Looking for someone who shares my values of compassion and dedication.
          In my free time, I enjoy hiking, reading, and trying new restaurants.
        </p>
      </div>

      {/* Interests */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '16px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '12px', color: '#1f2937' }}>
          Interests
        </h3>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
          {['Hiking', 'Reading', 'Cooking', 'Travel', 'Photography', 'Yoga'].map((interest, index) => (
            <span
              key={index}
              style={{
                backgroundColor: '#dbeafe',
                color: '#1e40af',
                padding: '6px 12px',
                borderRadius: '16px',
                fontSize: '14px',
                fontWeight: '500'
              }}
            >
              {interest}
            </span>
          ))}
        </div>
      </div>
    </div>
  );

  const renderActivity = () => (
    <div style={{ padding: '20px' }}>
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
        gap: '16px'
      }}>
        {[
          { label: 'Matches', value: userStats.matches, icon: Heart, color: '#ec4899' },
          { label: 'Messages', value: userStats.messages, icon: MessageSquare, color: '#3b82f6' },
          { label: 'Likes Given', value: userStats.likes, icon: Heart, color: '#10b981' },
          { label: 'Super Likes', value: userStats.superlikes, icon: Star, color: '#f59e0b' },
          { label: 'Gifts Sent', value: userStats.giftsSent, icon: Gift, color: '#8b5cf6' },
          { label: 'Gifts Received', value: userStats.giftsReceived, icon: Gift, color: '#06b6d4' },
          { label: 'Video Minutes', value: userStats.videoMinutes, icon: Video, color: '#ef4444' },
          { label: 'Speed Dating', value: userStats.speedDatingSessions, icon: Video, color: '#84cc16' }
        ].map((stat, index) => {
          const IconComponent = stat.icon;
          return (
            <div
              key={index}
              style={{
                backgroundColor: 'white',
                borderRadius: '12px',
                padding: '16px',
                textAlign: 'center',
                boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
              }}
            >
              <div style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                backgroundColor: `${stat.color}20`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 8px'
              }}>
                <IconComponent size={24} color={stat.color} />
              </div>
              <p style={{ fontSize: '24px', fontWeight: 'bold', margin: '0 0 4px 0', color: '#1f2937' }}>
                {stat.value}
              </p>
              <p style={{ fontSize: '12px', color: '#6b7280', margin: 0 }}>
                {stat.label}
              </p>
            </div>
          );
        })}
      </div>
    </div>
  );

  const renderRewards = () => (
    <div style={{ padding: '20px' }}>
      {/* Current Rewards */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '16px',
        marginBottom: '16px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '12px', color: '#1f2937' }}>
          Current Balance
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#f59e0b' }}>150</div>
            <div style={{ fontSize: '12px', color: '#6b7280' }}>Gift Points</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#8b5cf6' }}>5</div>
            <div style={{ fontSize: '12px', color: '#6b7280' }}>Super Likes</div>
          </div>
        </div>
      </div>

      {/* Achievements */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '16px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '12px', color: '#1f2937' }}>
          Achievements
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {[
            { title: 'First Match', description: 'Got your first match!', icon: '🎉', completed: true },
            { title: 'Conversationalist', description: 'Sent 50 messages', icon: '💬', completed: true },
            { title: 'Gift Giver', description: 'Sent 10 gifts', icon: '🎁', completed: true },
            { title: 'Speed Dater', description: 'Join 5 speed dating sessions', icon: '⚡', completed: false },
            { title: 'Social Butterfly', description: 'Get 100 likes', icon: '🦋', completed: false }
          ].map((achievement, index) => (
            <div
              key={index}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '8px',
                backgroundColor: achievement.completed ? '#f0fdf4' : '#f9fafb',
                borderRadius: '8px',
                opacity: achievement.completed ? 1 : 0.6
              }}
            >
              <div style={{ fontSize: '24px' }}>{achievement.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: '14px', fontWeight: '600', color: '#1f2937' }}>
                  {achievement.title}
                </div>
                <div style={{ fontSize: '12px', color: '#6b7280' }}>
                  {achievement.description}
                </div>
              </div>
              {achievement.completed && (
                <div style={{ color: '#10b981', fontSize: '20px' }}>✓</div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderSettings = () => (
    <div style={{ padding: '20px' }}>
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        padding: '0',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        overflow: 'hidden'
      }}>
        {[
          { label: 'Edit Profile', icon: Edit },
          { label: 'Privacy Settings', icon: Settings },
          { label: 'Notifications', icon: MessageSquare },
          { label: 'Account Settings', icon: Settings },
          { label: 'Help & Support', icon: Heart },
          { label: 'Logout', icon: Settings }
        ].map((item, index) => {
          const IconComponent = item.icon;
          return (
            <div
              key={index}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '16px',
                borderBottom: index < 5 ? '1px solid #f3f4f6' : 'none',
                cursor: 'pointer'
              }}
            >
              <IconComponent size={20} color="#6b7280" />
              <span style={{ fontSize: '16px', color: '#1f2937' }}>{item.label}</span>
            </div>
          );
        })}
      </div>
    </div>
  );

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f8fafc', paddingBottom: '80px' }}>
      {/* Header */}
      <div style={{
        background: 'linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%)',
        padding: '20px',
        color: 'white'
      }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', textAlign: 'center', margin: 0 }}>
          My Profile
        </h1>
      </div>

      {/* Tab Navigation */}
      <div style={{
        backgroundColor: 'white',
        display: 'flex',
        borderBottom: '1px solid #e5e7eb'
      }}>
        {tabs.map((tab) => {
          const IconComponent = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              style={{
                flex: 1,
                padding: '12px 8px',
                border: 'none',
                background: activeTab === tab.id ? '#ec4899' : 'transparent',
                color: activeTab === tab.id ? 'white' : '#6b7280',
                cursor: 'pointer',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '4px',
                fontSize: '12px',
                fontWeight: '500'
              }}
            >
              <IconComponent size={16} />
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Tab Content */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>
          <div style={{
            width: '40px',
            height: '40px',
            border: '3px solid #f3f4f6',
            borderTop: '3px solid #ec4899',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '0 auto 16px'
          }}></div>
          <p style={{ color: '#6b7280' }}>Loading profile...</p>
        </div>
      ) : (
        <>
          {activeTab === 'profile' && renderProfile()}
          {activeTab === 'activity' && renderActivity()}
          {activeTab === 'rewards' && renderRewards()}
          {activeTab === 'settings' && renderSettings()}
        </>
      )}

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

export default Profile;