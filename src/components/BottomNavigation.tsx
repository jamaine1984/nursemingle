import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Home, Heart, MessageSquare, Video, Gift, User } from 'lucide-react';

const BottomNavigation: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { icon: Home, label: 'Home', path: '/home' },
    { icon: Heart, label: 'Likes', path: '/likes' },
    { icon: MessageSquare, label: 'Messages', path: '/messages' },
    { icon: Video, label: 'Speed Dating', path: '/speed-dating' },
    { icon: Gift, label: 'Gifts', path: '/gifts' },
    { icon: User, label: 'Profile', path: '/profile' }
  ];

  return (
    <div style={{
      position: 'fixed',
      bottom: 0,
      left: 0,
      right: 0,
      backgroundColor: 'white',
      borderTopLeftRadius: '20px',
      borderTopRightRadius: '20px',
      boxShadow: '0 -4px 20px rgba(0,0,0,0.1)',
      padding: '8px 0',
      zIndex: 1000
    }}>
      <div style={{
        display: 'flex',
        justifyContent: 'space-around',
        alignItems: 'center',
        maxWidth: '600px',
        margin: '0 auto'
      }}>
        {navItems.map((item, index) => {
          const isActive = location.pathname === item.path;
          const IconComponent = item.icon;

          return (
            <button
              key={index}
              onClick={() => navigate(item.path)}
              style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '4px',
                padding: '8px 12px',
                border: 'none',
                background: 'transparent',
                cursor: 'pointer',
                borderRadius: '12px',
                transition: 'all 0.2s ease',
                color: isActive ? '#ec4899' : '#6b7280'
              }}
            >
              <IconComponent
                size={24}
                fill={isActive ? '#ec4899' : 'none'}
                stroke={isActive ? '#ec4899' : '#6b7280'}
              />
              <span style={{
                fontSize: '10px',
                fontWeight: isActive ? '600' : '400',
                color: isActive ? '#ec4899' : '#6b7280'
              }}>
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default BottomNavigation;