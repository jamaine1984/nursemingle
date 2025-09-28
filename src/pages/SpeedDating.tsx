import React, { useState, useEffect } from 'react';
import { Video, Users, Clock, Plus, Play } from 'lucide-react';
import BottomNavigation from '../components/BottomNavigation';

interface SpeedDatingRoom {
  id: string;
  title: string;
  duration: number; // in minutes
  participants: number;
  maxParticipants: number;
  scheduledTime: Date;
  status: 'waiting' | 'active' | 'completed';
  description: string;
}

const SpeedDating: React.FC = () => {
  const [rooms, setRooms] = useState<SpeedDatingRoom[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateRoom, setShowCreateRoom] = useState(false);

  useEffect(() => {
    // Mock data - replace with actual Firebase data
    const mockRooms: SpeedDatingRoom[] = [
      {
        id: '1',
        title: 'Quick Connect',
        duration: 5,
        participants: 8,
        maxParticipants: 20,
        scheduledTime: new Date(Date.now() + 1000 * 60 * 15), // 15 minutes from now
        status: 'waiting',
        description: 'Fast-paced 5-minute conversations for busy nurses'
      },
      {
        id: '2',
        title: 'Coffee Chat',
        duration: 7,
        participants: 12,
        maxParticipants: 16,
        scheduledTime: new Date(Date.now() + 1000 * 60 * 30), // 30 minutes from now
        status: 'waiting',
        description: 'Relaxed 7-minute conversations over virtual coffee'
      },
      {
        id: '3',
        title: 'Deep Dive',
        duration: 20,
        participants: 6,
        maxParticipants: 12,
        scheduledTime: new Date(Date.now() + 1000 * 60 * 60), // 1 hour from now
        status: 'waiting',
        description: 'Longer conversations to really get to know each other'
      },
      {
        id: '4',
        title: 'Extended Chat',
        duration: 40,
        participants: 4,
        maxParticipants: 8,
        scheduledTime: new Date(Date.now() + 1000 * 60 * 60 * 2), // 2 hours from now
        status: 'waiting',
        description: 'Extended conversations for meaningful connections'
      },
      {
        id: '5',
        title: 'Weekend Social',
        duration: 120,
        participants: 15,
        maxParticipants: 30,
        scheduledTime: new Date(Date.now() + 1000 * 60 * 60 * 24), // 1 day from now
        status: 'waiting',
        description: 'Relaxed weekend socializing with multiple conversation rounds'
      }
    ];

    setTimeout(() => {
      setRooms(mockRooms);
      setLoading(false);
    }, 1000);
  }, []);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const getTimeUntil = (date: Date) => {
    const now = new Date();
    const diff = date.getTime() - now.getTime();
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(minutes / 60);

    if (hours > 24) {
      const days = Math.floor(hours / 24);
      return `${days}d ${hours % 24}h`;
    }
    if (hours > 0) return `${hours}h ${minutes % 60}m`;
    if (minutes > 0) return `${minutes}m`;
    return 'Starting soon!';
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'waiting': return '#3b82f6';
      case 'active': return '#10b981';
      case 'completed': return '#6b7280';
      default: return '#6b7280';
    }
  };

  const joinRoom = (roomId: string) => {
    // This would integrate with your LiveKit video calling system
    console.log('Joining room:', roomId);
    // Navigate to video call component
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f8fafc', paddingBottom: '80px' }}>
      {/* Header */}
      <div style={{
        background: 'linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%)',
        padding: '20px',
        color: 'white'
      }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', textAlign: 'center', margin: 0 }}>
          Speed Dating Rooms
        </h1>
        <p style={{ textAlign: 'center', opacity: 0.9, marginTop: '8px', margin: 0 }}>
          Join video speed dating sessions with other nurses
        </p>
      </div>

      {/* Create Room Button */}
      <div style={{ padding: '16px', backgroundColor: 'white', borderBottom: '1px solid #e5e7eb' }}>
        <button
          onClick={() => setShowCreateRoom(true)}
          style={{
            width: '100%',
            padding: '12px',
            backgroundColor: '#8b5cf6',
            color: 'white',
            border: 'none',
            borderRadius: '12px',
            fontWeight: '600',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            fontSize: '16px'
          }}
        >
          <Plus size={20} />
          Create New Room
        </button>
      </div>

      {/* Rooms List */}
      <div style={{ padding: '16px' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <div style={{
              width: '40px',
              height: '40px',
              border: '3px solid #f3f4f6',
              borderTop: '3px solid #8b5cf6',
              borderRadius: '50%',
              animation: 'spin 1s linear infinite',
              margin: '0 auto 16px'
            }}></div>
            <p style={{ color: '#6b7280' }}>Loading rooms...</p>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
            gap: '16px'
          }}>
            {rooms.map((room) => (
              <div
                key={room.id}
                style={{
                  backgroundColor: 'white',
                  borderRadius: '16px',
                  padding: '20px',
                  boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
                  border: '1px solid #f3f4f6'
                }}
              >
                {/* Room Header */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: 'bold', margin: 0, color: '#1f2937' }}>
                    {room.title}
                  </h3>
                  <div style={{
                    padding: '4px 8px',
                    backgroundColor: getStatusColor(room.status),
                    color: 'white',
                    borderRadius: '12px',
                    fontSize: '12px',
                    fontWeight: '600',
                    textTransform: 'capitalize'
                  }}>
                    {room.status}
                  </div>
                </div>

                {/* Duration and Time */}
                <div style={{ display: 'flex', gap: '16px', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                    <Clock size={16} color="#6b7280" />
                    <span style={{ fontSize: '14px', color: '#6b7280' }}>
                      {room.duration}min sessions
                    </span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                    <Users size={16} color="#6b7280" />
                    <span style={{ fontSize: '14px', color: '#6b7280' }}>
                      {room.participants}/{room.maxParticipants}
                    </span>
                  </div>
                </div>

                {/* Description */}
                <p style={{ fontSize: '14px', color: '#6b7280', marginBottom: '16px', lineHeight: '1.4' }}>
                  {room.description}
                </p>

                {/* Scheduled Time */}
                <div style={{
                  backgroundColor: '#f8fafc',
                  padding: '12px',
                  borderRadius: '8px',
                  marginBottom: '16px'
                }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '14px', color: '#374151', fontWeight: '600' }}>
                      Starts at {formatTime(room.scheduledTime)}
                    </span>
                    <span style={{ fontSize: '12px', color: '#8b5cf6', fontWeight: '600' }}>
                      {getTimeUntil(room.scheduledTime)}
                    </span>
                  </div>
                </div>

                {/* Join Button */}
                <button
                  onClick={() => joinRoom(room.id)}
                  disabled={room.participants >= room.maxParticipants}
                  style={{
                    width: '100%',
                    padding: '12px',
                    backgroundColor: room.participants >= room.maxParticipants ? '#9ca3af' : '#8b5cf6',
                    color: 'white',
                    border: 'none',
                    borderRadius: '12px',
                    fontWeight: '600',
                    cursor: room.participants >= room.maxParticipants ? 'not-allowed' : 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                    transition: 'background-color 0.2s'
                  }}
                  onMouseOver={(e) => {
                    if (room.participants < room.maxParticipants) {
                      e.currentTarget.style.backgroundColor = '#7c3aed';
                    }
                  }}
                  onMouseOut={(e) => {
                    if (room.participants < room.maxParticipants) {
                      e.currentTarget.style.backgroundColor = '#8b5cf6';
                    }
                  }}
                >
                  {room.status === 'active' ? <Play size={18} /> : <Video size={18} />}
                  {room.participants >= room.maxParticipants ? 'Room Full' :
                   room.status === 'active' ? 'Join Now' : 'Join Room'}
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

export default SpeedDating;