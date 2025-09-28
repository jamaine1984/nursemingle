import React, { useState, useEffect } from 'react';
import { MessageSquare, Video, Search } from 'lucide-react';
import BottomNavigation from '../components/BottomNavigation';

interface Match {
  id: string;
  name: string;
  avatar?: string;
  lastMessage: string;
  timestamp: Date;
  unreadCount: number;
  isOnline: boolean;
}

const Messages: React.FC = () => {
  const [matches, setMatches] = useState<Match[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock data - replace with actual Firebase data
    const mockMatches: Match[] = [
      {
        id: '1',
        name: 'Sarah Chen',
        avatar: 'https://images.unsplash.com/photo-1494790108755-2616c2747f50?w=150',
        lastMessage: 'Hey! How was your shift today?',
        timestamp: new Date(Date.now() - 1000 * 60 * 15), // 15 minutes ago
        unreadCount: 2,
        isOnline: true
      },
      {
        id: '2',
        name: 'Emily Rodriguez',
        avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        lastMessage: 'Would love to meet for coffee sometime!',
        timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
        unreadCount: 0,
        isOnline: false
      },
      {
        id: '3',
        name: 'Jessica Park',
        avatar: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=150',
        lastMessage: 'Thanks for the great conversation yesterday!',
        timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
        unreadCount: 1,
        isOnline: true
      }
    ];

    setTimeout(() => {
      setMatches(mockMatches);
      setLoading(false);
    }, 1000);
  }, []);

  const filteredMatches = matches.filter(match =>
    match.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

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
          Messages
        </h1>
        <p style={{ textAlign: 'center', opacity: 0.9, marginTop: '8px', margin: 0 }}>
          {matches.length} conversations
        </p>
      </div>

      {/* Search Bar */}
      <div style={{ padding: '16px', backgroundColor: 'white' }}>
        <div style={{
          position: 'relative',
          display: 'flex',
          alignItems: 'center'
        }}>
          <Search
            size={20}
            style={{
              position: 'absolute',
              left: '12px',
              color: '#9ca3af',
              zIndex: 1
            }}
          />
          <input
            type="text"
            placeholder="Search conversations..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{
              width: '100%',
              padding: '12px 12px 12px 40px',
              border: '1px solid #e5e7eb',
              borderRadius: '12px',
              fontSize: '16px',
              outline: 'none'
            }}
          />
        </div>
      </div>

      {/* Messages List */}
      <div style={{ backgroundColor: 'white' }}>
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
            <p style={{ color: '#6b7280' }}>Loading messages...</p>
          </div>
        ) : filteredMatches.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <div style={{ fontSize: '48px', marginBottom: '16px' }}>💬</div>
            <h3 style={{ color: '#374151', marginBottom: '8px' }}>
              {searchQuery ? 'No matches found' : 'No messages yet'}
            </h3>
            <p style={{ color: '#6b7280' }}>
              {searchQuery
                ? 'Try searching for a different name'
                : 'Start matching with people to begin conversations!'
              }
            </p>
          </div>
        ) : (
          filteredMatches.map((match) => (
            <div
              key={match.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                padding: '16px',
                borderBottom: '1px solid #f3f4f6',
                cursor: 'pointer',
                transition: 'background-color 0.2s'
              }}
              onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#f9fafb'}
              onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'white'}
            >
              {/* Avatar with online indicator */}
              <div style={{ position: 'relative', marginRight: '12px' }}>
                {match.avatar ? (
                  <img
                    src={match.avatar}
                    alt={match.name}
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
                {match.isOnline && (
                  <div style={{
                    position: 'absolute',
                    bottom: '2px',
                    right: '2px',
                    width: '16px',
                    height: '16px',
                    backgroundColor: '#10b981',
                    borderRadius: '50%',
                    border: '2px solid white'
                  }}></div>
                )}
              </div>

              {/* Message content */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <h3 style={{
                    fontSize: '16px',
                    fontWeight: '600',
                    margin: 0,
                    color: '#1f2937',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap'
                  }}>
                    {match.name}
                  </h3>
                  <span style={{ fontSize: '12px', color: '#9ca3af' }}>
                    {timeAgo(match.timestamp)}
                  </span>
                </div>
                <p style={{
                  fontSize: '14px',
                  color: '#6b7280',
                  margin: 0,
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap'
                }}>
                  {match.lastMessage}
                </p>
              </div>

              {/* Right side icons and badge */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginLeft: '12px' }}>
                <button
                  style={{
                    padding: '8px',
                    backgroundColor: '#ec4899',
                    color: 'white',
                    border: 'none',
                    borderRadius: '50%',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  <Video size={16} />
                </button>

                {match.unreadCount > 0 && (
                  <div style={{
                    minWidth: '20px',
                    height: '20px',
                    backgroundColor: '#ef4444',
                    color: 'white',
                    borderRadius: '10px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '12px',
                    fontWeight: '600',
                    padding: '0 6px'
                  }}>
                    {match.unreadCount}
                  </div>
                )}
              </div>
            </div>
          ))
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

export default Messages;