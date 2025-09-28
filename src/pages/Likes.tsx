import React, { useState, useEffect } from 'react';
import { Heart, Star, MessageSquare } from 'lucide-react';
import BottomNavigation from '../components/BottomNavigation';

interface Like {
  id: string;
  name: string;
  age: number;
  avatar?: string;
  specialty: string;
  location: string;
  likeType: 'like' | 'superlike';
  timestamp: Date;
}

const Likes: React.FC = () => {
  const [likes, setLikes] = useState<Like[]>([]);
  const [activeTab, setActiveTab] = useState<'likes' | 'superlikes'>('likes');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock data - replace with actual Firebase data
    const mockLikes: Like[] = [
      {
        id: '1',
        name: 'Sarah',
        age: 28,
        avatar: 'https://images.unsplash.com/photo-1494790108755-2616c2747f50?w=150',
        specialty: 'ICU Nurse',
        location: 'New York, NY',
        likeType: 'like',
        timestamp: new Date(Date.now() - 1000 * 60 * 30) // 30 minutes ago
      },
      {
        id: '2',
        name: 'Emily',
        age: 26,
        avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        specialty: 'ER Nurse',
        location: 'Los Angeles, CA',
        likeType: 'superlike',
        timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2) // 2 hours ago
      }
    ];

    setTimeout(() => {
      setLikes(mockLikes);
      setLoading(false);
    }, 1000);
  }, []);

  const filteredLikes = likes.filter(like => like.likeType === activeTab.replace('s', '') as 'like' | 'superlike');

  const timeAgo = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days}d ago`;
    if (hours > 0) return `${hours}h ago`;
    return `${minutes}m ago`;
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f8fafc', paddingBottom: '80px' }}>
      {/* Header */}
      <div style={{
        background: 'linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%)',
        padding: '20px',
        color: 'white'
      }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', textAlign: 'center', margin: 0 }}>
          People Who Like You
        </h1>
        <p style={{ textAlign: 'center', opacity: 0.9, marginTop: '8px', margin: 0 }}>
          {likes.length} people are interested in you
        </p>
      </div>

      {/* Tabs */}
      <div style={{
        display: 'flex',
        backgroundColor: 'white',
        borderBottom: '1px solid #e5e7eb'
      }}>
        <button
          onClick={() => setActiveTab('likes')}
          style={{
            flex: 1,
            padding: '16px',
            border: 'none',
            background: activeTab === 'likes' ? '#ec4899' : 'transparent',
            color: activeTab === 'likes' ? 'white' : '#6b7280',
            fontWeight: '600',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px'
          }}
        >
          <Heart size={20} />
          Likes ({likes.filter(l => l.likeType === 'like').length})
        </button>
        <button
          onClick={() => setActiveTab('superlikes')}
          style={{
            flex: 1,
            padding: '16px',
            border: 'none',
            background: activeTab === 'superlikes' ? '#8b5cf6' : 'transparent',
            color: activeTab === 'superlikes' ? 'white' : '#6b7280',
            fontWeight: '600',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px'
          }}
        >
          <Star size={20} />
          Super Likes ({likes.filter(l => l.likeType === 'superlike').length})
        </button>
      </div>

      {/* Content */}
      <div style={{ padding: '20px' }}>
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
            <p style={{ color: '#6b7280' }}>Loading likes...</p>
          </div>
        ) : filteredLikes.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>💔</div>
            <h3 style={{ color: '#374151', marginBottom: '8px' }}>No {activeTab} yet</h3>
            <p style={{ color: '#6b7280' }}>
              Keep swiping to find people who like you!
            </p>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
            gap: '16px'
          }}>
            {filteredLikes.map((like) => (
              <div
                key={like.id}
                style={{
                  backgroundColor: 'white',
                  borderRadius: '16px',
                  padding: '20px',
                  boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
                  border: '1px solid #f3f4f6'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                  {like.avatar ? (
                    <img
                      src={like.avatar}
                      alt={like.name}
                      style={{
                        width: '60px',
                        height: '60px',
                        borderRadius: '50%',
                        objectFit: 'cover'
                      }}
                    />
                  ) : (
                    <div style={{
                      width: '60px',
                      height: '60px',
                      borderRadius: '50%',
                      backgroundColor: '#e5e7eb',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: '#6b7280'
                    }}>
                      👤
                    </div>
                  )}
                  <div style={{ flex: 1 }}>
                    <h3 style={{ fontSize: '18px', fontWeight: 'bold', margin: 0, color: '#1f2937' }}>
                      {like.name}, {like.age}
                    </h3>
                    <p style={{ color: '#6b7280', fontSize: '14px', margin: '4px 0' }}>
                      {like.specialty}
                    </p>
                    <p style={{ color: '#9ca3af', fontSize: '12px', margin: 0 }}>
                      {like.location} • {timeAgo(like.timestamp)}
                    </p>
                  </div>
                  <div style={{
                    padding: '8px',
                    borderRadius: '50%',
                    backgroundColor: like.likeType === 'superlike' ? '#8b5cf6' : '#ec4899'
                  }}>
                    {like.likeType === 'superlike' ? (
                      <Star size={16} fill="white" color="white" />
                    ) : (
                      <Heart size={16} fill="white" color="white" />
                    )}
                  </div>
                </div>

                <button
                  style={{
                    width: '100%',
                    padding: '12px',
                    backgroundColor: '#ec4899',
                    color: 'white',
                    border: 'none',
                    borderRadius: '12px',
                    fontWeight: '600',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                    transition: 'background-color 0.2s'
                  }}
                  onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#db2777'}
                  onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#ec4899'}
                >
                  <MessageSquare size={18} />
                  Start Conversation
                </button>
              </div>
            ))}
          </div>
        )}
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

export default Likes;