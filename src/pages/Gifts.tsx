import React, { useState, useEffect } from 'react';
import { Gift, ShoppingCart, Star, Heart } from 'lucide-react';
import BottomNavigation from '../components/BottomNavigation';

interface GiftItem {
  id: string;
  name: string;
  emoji: string;
  category: string;
  price: number;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  description: string;
}

const Gifts: React.FC = () => {
  const [gifts, setGifts] = useState<GiftItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [giftPoints, setGiftPoints] = useState(150);
  const [loading, setLoading] = useState(true);

  const categories = [
    'all',
    'romantic',
    'food',
    'luxury',
    'experiences',
    'tech',
    'fun'
  ];

  useEffect(() => {
    // Mock 63 gifts data - replace with actual Firebase data
    const mockGifts: GiftItem[] = [
      // Romantic (10 items)
      { id: '1', name: 'Red Rose', emoji: '🌹', category: 'romantic', price: 10, rarity: 'common', description: 'A classic symbol of love' },
      { id: '2', name: 'Heart Balloon', emoji: '💖', category: 'romantic', price: 15, rarity: 'common', description: 'Share your love' },
      { id: '3', name: 'Love Letter', emoji: '💌', category: 'romantic', price: 20, rarity: 'common', description: 'Express your feelings' },
      { id: '4', name: 'Chocolate Box', emoji: '🍫', category: 'romantic', price: 25, rarity: 'rare', description: 'Sweet treats for someone sweet' },
      { id: '5', name: 'Diamond Ring', emoji: '💍', category: 'romantic', price: 200, rarity: 'legendary', description: 'The ultimate romantic gesture' },
      { id: '6', name: 'Bouquet', emoji: '💐', category: 'romantic', price: 30, rarity: 'rare', description: 'Beautiful flowers' },
      { id: '7', name: 'Love Potion', emoji: '💝', category: 'romantic', price: 40, rarity: 'epic', description: 'Magical romance' },
      { id: '8', name: 'Wedding Cake', emoji: '🎂', category: 'romantic', price: 100, rarity: 'epic', description: 'Celebrate love' },
      { id: '9', name: 'Cupid Arrow', emoji: '💘', category: 'romantic', price: 50, rarity: 'rare', description: 'Strike their heart' },
      { id: '10', name: 'Kiss Mark', emoji: '💋', category: 'romantic', price: 5, rarity: 'common', description: 'A sweet kiss' },

      // Food & Drinks (15 items)
      { id: '11', name: 'Coffee', emoji: '☕', category: 'food', price: 8, rarity: 'common', description: 'Energy for long shifts' },
      { id: '12', name: 'Pizza Slice', emoji: '🍕', category: 'food', price: 12, rarity: 'common', description: 'Quick comfort food' },
      { id: '13', name: 'Sushi', emoji: '🍣', category: 'food', price: 35, rarity: 'rare', description: 'Elegant dining' },
      { id: '14', name: 'Champagne', emoji: '🍾', category: 'food', price: 60, rarity: 'epic', description: 'Celebrate special moments' },
      { id: '15', name: 'Birthday Cake', emoji: '🎂', category: 'food', price: 25, rarity: 'rare', description: 'Sweet celebration' },
      { id: '16', name: 'Ice Cream', emoji: '🍦', category: 'food', price: 10, rarity: 'common', description: 'Cool treat' },
      { id: '17', name: 'Donut', emoji: '🍩', category: 'food', price: 6, rarity: 'common', description: 'Sweet snack' },
      { id: '18', name: 'Wine Glass', emoji: '🍷', category: 'food', price: 40, rarity: 'rare', description: 'Relaxing evening' },
      { id: '19', name: 'Cocktail', emoji: '🍸', category: 'food', price: 30, rarity: 'rare', description: 'Fun drinks' },
      { id: '20', name: 'Strawberry', emoji: '🍓', category: 'food', price: 8, rarity: 'common', description: 'Fresh and sweet' },
      { id: '21', name: 'Cupcake', emoji: '🧁', category: 'food', price: 12, rarity: 'common', description: 'Mini celebration' },
      { id: '22', name: 'Taco', emoji: '🌮', category: 'food', price: 10, rarity: 'common', description: 'Tasty meal' },
      { id: '23', name: 'Burger', emoji: '🍔', category: 'food', price: 15, rarity: 'common', description: 'Classic comfort food' },
      { id: '24', name: 'Lobster', emoji: '🦞', category: 'food', price: 80, rarity: 'epic', description: 'Luxury seafood' },
      { id: '25', name: 'Honey Pot', emoji: '🍯', category: 'food', price: 20, rarity: 'rare', description: 'Sweet natural treat' },

      // Luxury (10 items)
      { id: '26', name: 'Crown', emoji: '👑', category: 'luxury', price: 150, rarity: 'legendary', description: 'Feel like royalty' },
      { id: '27', name: 'Luxury Car', emoji: '🚗', category: 'luxury', price: 500, rarity: 'legendary', description: 'Ultimate luxury' },
      { id: '28', name: 'Gold Watch', emoji: '⌚', category: 'luxury', price: 120, rarity: 'epic', description: 'Timeless elegance' },
      { id: '29', name: 'Designer Bag', emoji: '👜', category: 'luxury', price: 100, rarity: 'epic', description: 'Fashion statement' },
      { id: '30', name: 'Pearl Necklace', emoji: '📿', category: 'luxury', price: 90, rarity: 'epic', description: 'Classic elegance' },
      { id: '31', name: 'Yacht', emoji: '🛥️', category: 'luxury', price: 1000, rarity: 'legendary', description: 'Ultimate luxury vessel' },
      { id: '32', name: 'Mansion', emoji: '🏰', category: 'luxury', price: 2000, rarity: 'legendary', description: 'Dream home' },
      { id: '33', name: 'Private Jet', emoji: '✈️', category: 'luxury', price: 1500, rarity: 'legendary', description: 'Sky-high luxury' },
      { id: '34', name: 'Golden Trophy', emoji: '🏆', category: 'luxury', price: 75, rarity: 'epic', description: 'You\'re a winner' },
      { id: '35', name: 'Silk Dress', emoji: '👗', category: 'luxury', price: 60, rarity: 'rare', description: 'Elegant attire' },

      // Experiences (8 items)
      { id: '36', name: 'Concert Ticket', emoji: '🎵', category: 'experiences', price: 50, rarity: 'rare', description: 'Live music experience' },
      { id: '37', name: 'Movie Night', emoji: '🎬', category: 'experiences', price: 25, rarity: 'common', description: 'Cozy evening together' },
      { id: '38', name: 'Beach Vacation', emoji: '🏖️', category: 'experiences', price: 200, rarity: 'epic', description: 'Tropical getaway' },
      { id: '39', name: 'Spa Day', emoji: '🧖‍♀️', category: 'experiences', price: 80, rarity: 'rare', description: 'Relaxation and wellness' },
      { id: '40', name: 'Mountain Hike', emoji: '🏔️', category: 'experiences', price: 30, rarity: 'common', description: 'Adventure together' },
      { id: '41', name: 'Cooking Class', emoji: '👨‍🍳', category: 'experiences', price: 40, rarity: 'rare', description: 'Learn together' },
      { id: '42', name: 'Hot Air Balloon', emoji: '🎈', category: 'experiences', price: 120, rarity: 'epic', description: 'Sky-high romance' },
      { id: '43', name: 'Art Gallery', emoji: '🎨', category: 'experiences', price: 35, rarity: 'rare', description: 'Cultural experience' },

      // Tech Gadgets (10 items)
      { id: '44', name: 'Smartphone', emoji: '📱', category: 'tech', price: 100, rarity: 'epic', description: 'Stay connected' },
      { id: '45', name: 'Laptop', emoji: '💻', category: 'tech', price: 150, rarity: 'epic', description: 'Work and play' },
      { id: '46', name: 'Gaming Console', emoji: '🎮', category: 'tech', price: 120, rarity: 'epic', description: 'Gaming fun' },
      { id: '47', name: 'Headphones', emoji: '🎧', category: 'tech', price: 60, rarity: 'rare', description: 'Personal audio' },
      { id: '48', name: 'Camera', emoji: '📷', category: 'tech', price: 80, rarity: 'rare', description: 'Capture memories' },
      { id: '49', name: 'Smart Watch', emoji: '⌚', category: 'tech', price: 90, rarity: 'epic', description: 'Fitness tracker' },
      { id: '50', name: 'Tablet', emoji: '📱', category: 'tech', price: 75, rarity: 'rare', description: 'Portable computing' },
      { id: '51', name: 'VR Headset', emoji: '🥽', category: 'tech', price: 200, rarity: 'legendary', description: 'Virtual reality' },
      { id: '52', name: 'Drone', emoji: '🚁', category: 'tech', price: 110, rarity: 'epic', description: 'Aerial photography' },
      { id: '53', name: 'Robot', emoji: '🤖', category: 'tech', price: 300, rarity: 'legendary', description: 'Future is here' },

      // Fun Items (10 items)
      { id: '54', name: 'Party Hat', emoji: '🎉', category: 'fun', price: 5, rarity: 'common', description: 'Celebration time' },
      { id: '55', name: 'Magic Wand', emoji: '🪄', category: 'fun', price: 20, rarity: 'rare', description: 'Make wishes come true' },
      { id: '56', name: 'Unicorn', emoji: '🦄', category: 'fun', price: 50, rarity: 'epic', description: 'Magical creature' },
      { id: '57', name: 'Rainbow', emoji: '🌈', category: 'fun', price: 15, rarity: 'common', description: 'Colorful joy' },
      { id: '58', name: 'Fireworks', emoji: '🎆', category: 'fun', price: 30, rarity: 'rare', description: 'Light up the sky' },
      { id: '59', name: 'Balloon Animal', emoji: '🎈', category: 'fun', price: 8, rarity: 'common', description: 'Playful fun' },
      { id: '60', name: 'Magic 8 Ball', emoji: '🎱', category: 'fun', price: 12, rarity: 'common', description: 'Ask the future' },
      { id: '61', name: 'Confetti', emoji: '🎊', category: 'fun', price: 6, rarity: 'common', description: 'Celebration confetti' },
      { id: '62', name: 'Clown Nose', emoji: '🔴', category: 'fun', price: 4, rarity: 'common', description: 'Be silly together' },
      { id: '63', name: 'Shooting Star', emoji: '⭐', category: 'fun', price: 25, rarity: 'rare', description: 'Make a wish' }
    ];

    setTimeout(() => {
      setGifts(mockGifts);
      setLoading(false);
    }, 1000);
  }, []);

  const filteredGifts = selectedCategory === 'all'
    ? gifts
    : gifts.filter(gift => gift.category === selectedCategory);

  const getRarityColor = (rarity: string) => {
    switch (rarity) {
      case 'common': return '#6b7280';
      case 'rare': return '#3b82f6';
      case 'epic': return '#8b5cf6';
      case 'legendary': return '#f59e0b';
      default: return '#6b7280';
    }
  };

  const sendGift = (gift: GiftItem) => {
    if (giftPoints >= gift.price) {
      setGiftPoints(prev => prev - gift.price);
      // Here you would implement the actual gift sending logic
      console.log('Sending gift:', gift.name);
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f8fafc', paddingBottom: '80px' }}>
      {/* Header */}
      <div style={{
        background: 'linear-gradient(135deg, #f59e0b 0%, #ec4899 100%)',
        padding: '20px',
        color: 'white'
      }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', textAlign: 'center', margin: 0 }}>
          Gift Shop
        </h1>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', marginTop: '8px' }}>
          <Star size={20} fill="white" />
          <span style={{ fontSize: '18px', fontWeight: '600' }}>
            {giftPoints} Gift Points
          </span>
        </div>
      </div>

      {/* Category Filter */}
      <div style={{
        backgroundColor: 'white',
        padding: '16px',
        borderBottom: '1px solid #e5e7eb',
        overflowX: 'auto'
      }}>
        <div style={{ display: 'flex', gap: '8px', minWidth: 'max-content' }}>
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              style={{
                padding: '8px 16px',
                border: '1px solid #e5e7eb',
                borderRadius: '20px',
                background: selectedCategory === category ? '#ec4899' : 'white',
                color: selectedCategory === category ? 'white' : '#6b7280',
                cursor: 'pointer',
                fontWeight: '500',
                textTransform: 'capitalize',
                whiteSpace: 'nowrap'
              }}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Gifts Grid */}
      <div style={{ padding: '16px' }}>
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
            <p style={{ color: '#6b7280' }}>Loading gifts...</p>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))',
            gap: '12px'
          }}>
            {filteredGifts.map((gift) => (
              <div
                key={gift.id}
                style={{
                  backgroundColor: 'white',
                  borderRadius: '12px',
                  padding: '16px',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                  border: `2px solid ${getRarityColor(gift.rarity)}`,
                  textAlign: 'center',
                  position: 'relative'
                }}
              >
                {/* Rarity Badge */}
                <div style={{
                  position: 'absolute',
                  top: '8px',
                  right: '8px',
                  padding: '2px 6px',
                  backgroundColor: getRarityColor(gift.rarity),
                  color: 'white',
                  borderRadius: '8px',
                  fontSize: '10px',
                  fontWeight: '600',
                  textTransform: 'capitalize'
                }}>
                  {gift.rarity}
                </div>

                {/* Gift Emoji */}
                <div style={{ fontSize: '40px', marginBottom: '8px' }}>
                  {gift.emoji}
                </div>

                {/* Gift Name */}
                <h3 style={{
                  fontSize: '14px',
                  fontWeight: '600',
                  margin: '0 0 4px 0',
                  color: '#1f2937'
                }}>
                  {gift.name}
                </h3>

                {/* Price */}
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                  marginBottom: '8px'
                }}>
                  <Star size={12} fill="#f59e0b" color="#f59e0b" />
                  <span style={{ fontSize: '12px', fontWeight: '600', color: '#f59e0b' }}>
                    {gift.price}
                  </span>
                </div>

                {/* Description */}
                <p style={{
                  fontSize: '10px',
                  color: '#6b7280',
                  margin: '0 0 12px 0',
                  lineHeight: '1.3'
                }}>
                  {gift.description}
                </p>

                {/* Send Button */}
                <button
                  onClick={() => sendGift(gift)}
                  disabled={giftPoints < gift.price}
                  style={{
                    width: '100%',
                    padding: '8px',
                    backgroundColor: giftPoints >= gift.price ? '#ec4899' : '#9ca3af',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    fontSize: '12px',
                    fontWeight: '600',
                    cursor: giftPoints >= gift.price ? 'pointer' : 'not-allowed',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '4px'
                  }}
                >
                  <Gift size={12} />
                  Send
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

export default Gifts;