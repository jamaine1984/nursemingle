import '../models/gift_model.dart';

class GiftCatalog {
  static List<Gift> getAllGifts() {
    final List<Gift> gifts = [];
    
    // Free Gifts (accessible via rewarded ads) - 50 gifts
    final List<Map<String, dynamic>> freeGifts = [
      // Hearts & Love Category
      {'id': 'free_001', 'name': 'Red Heart', 'icon': '❤️', 'description': 'Classic red heart'},
      {'id': 'free_002', 'name': 'Blue Heart', 'icon': '💙', 'description': 'Cool blue heart'},
      {'id': 'free_003', 'name': 'Green Heart', 'icon': '💚', 'description': 'Nature\'s heart'},
      {'id': 'free_004', 'name': 'Yellow Heart', 'icon': '💛', 'description': 'Sunny heart'},
      {'id': 'free_005', 'name': 'Purple Heart', 'icon': '💜', 'description': 'Royal heart'},
      {'id': 'free_006', 'name': 'Heart with Ribbon', 'icon': '💝', 'description': 'Gift of love'},
      {'id': 'free_007', 'name': 'Sparkling Heart', 'icon': '💖', 'description': 'Shining love'},
      {'id': 'free_008', 'name': 'Growing Heart', 'icon': '💗', 'description': 'Love that grows'},
      
      // Flowers Category
      {'id': 'free_009', 'name': 'Rose', 'icon': '🌹', 'description': 'Beautiful rose'},
      {'id': 'free_010', 'name': 'Sunflower', 'icon': '🌻', 'description': 'Bright sunflower'},
      {'id': 'free_011', 'name': 'Tulip', 'icon': '🌷', 'description': 'Elegant tulip'},
      {'id': 'free_012', 'name': 'Cherry Blossom', 'icon': '🌸', 'description': 'Delicate bloom'},
      {'id': 'free_013', 'name': 'Bouquet', 'icon': '💐', 'description': 'Flower bouquet'},
      {'id': 'free_014', 'name': 'Hibiscus', 'icon': '🌺', 'description': 'Tropical flower'},
      
      // Medical/Nursing Category
      {'id': 'free_015', 'name': 'Pill', 'icon': '💊', 'description': 'Medicine pill'},
      {'id': 'free_016', 'name': 'Syringe', 'icon': '💉', 'description': 'Medical syringe'},
      {'id': 'free_017', 'name': 'Bandage', 'icon': '🩹', 'description': 'Healing bandage'},
      {'id': 'free_018', 'name': 'Thermometer', 'icon': '🌡️', 'description': 'Temperature check'},
      {'id': 'free_019', 'name': 'Mask', 'icon': '😷', 'description': 'Safety first'},
      
      // Food & Drinks Category
      {'id': 'free_020', 'name': 'Coffee', 'icon': '☕', 'description': 'Hot coffee'},
      {'id': 'free_021', 'name': 'Tea', 'icon': '🍵', 'description': 'Relaxing tea'},
      {'id': 'free_022', 'name': 'Donut', 'icon': '🍩', 'description': 'Sweet treat'},
      {'id': 'free_023', 'name': 'Cookie', 'icon': '🍪', 'description': 'Chocolate chip'},
      {'id': 'free_024', 'name': 'Cake', 'icon': '🍰', 'description': 'Slice of cake'},
      {'id': 'free_025', 'name': 'Chocolate', 'icon': '🍫', 'description': 'Sweet chocolate'},
      
      // Celebration Category
      {'id': 'free_026', 'name': 'Party Popper', 'icon': '🎉', 'description': 'Celebration time'},
      {'id': 'free_027', 'name': 'Balloon', 'icon': '🎈', 'description': 'Festive balloon'},
      {'id': 'free_028', 'name': 'Gift Box', 'icon': '🎁', 'description': 'Mystery gift'},
      {'id': 'free_029', 'name': 'Confetti', 'icon': '🎊', 'description': 'Party confetti'},
      
      // Nature Category
      {'id': 'free_030', 'name': 'Rainbow', 'icon': '🌈', 'description': 'Colorful rainbow'},
      {'id': 'free_031', 'name': 'Star', 'icon': '⭐', 'description': 'Shining star'},
      {'id': 'free_032', 'name': 'Sun', 'icon': '☀️', 'description': 'Bright sunshine'},
      {'id': 'free_033', 'name': 'Moon', 'icon': '🌙', 'description': 'Night moon'},
      {'id': 'free_034', 'name': 'Cloud', 'icon': '☁️', 'description': 'Fluffy cloud'},
      
      // Animals Category
      {'id': 'free_035', 'name': 'Teddy Bear', 'icon': '🧸', 'description': 'Cuddly bear'},
      {'id': 'free_036', 'name': 'Butterfly', 'icon': '🦋', 'description': 'Beautiful butterfly'},
      {'id': 'free_037', 'name': 'Dove', 'icon': '🕊️', 'description': 'Peace dove'},
      {'id': 'free_038', 'name': 'Cat', 'icon': '🐱', 'description': 'Cute kitty'},
      {'id': 'free_039', 'name': 'Dog', 'icon': '🐶', 'description': 'Loyal puppy'},
      
      // Symbols Category
      {'id': 'free_040', 'name': 'Peace', 'icon': '✌️', 'description': 'Peace sign'},
      {'id': 'free_041', 'name': 'Thumbs Up', 'icon': '👍', 'description': 'Good job'},
      {'id': 'free_042', 'name': 'Clap', 'icon': '👏', 'description': 'Applause'},
      {'id': 'free_043', 'name': 'Wave', 'icon': '👋', 'description': 'Hello there'},
      {'id': 'free_044', 'name': 'Hug', 'icon': '🤗', 'description': 'Virtual hug'},
      
      // Fun Category
      {'id': 'free_045', 'name': 'Smile', 'icon': '😊', 'description': 'Happy smile'},
      {'id': 'free_046', 'name': 'Wink', 'icon': '😉', 'description': 'Playful wink'},
      {'id': 'free_047', 'name': 'Kiss', 'icon': '😘', 'description': 'Blow a kiss'},
      {'id': 'free_048', 'name': 'Heart Eyes', 'icon': '😍', 'description': 'Love struck'},
      {'id': 'free_049', 'name': 'Angel', 'icon': '😇', 'description': 'Sweet angel'},
      {'id': 'free_050', 'name': 'Music Note', 'icon': '🎵', 'description': 'Musical vibes'},
    ];
    
    // Premium Gifts (for paid users) - 60 gifts
    final List<Map<String, dynamic>> premiumGifts = [
      // Luxury Items Category
      {'id': 'premium_001', 'name': 'Diamond', 'icon': '💎', 'description': 'Precious diamond'},
      {'id': 'premium_002', 'name': 'Crown', 'icon': '👑', 'description': 'Royal crown'},
      {'id': 'premium_003', 'name': 'Ring', 'icon': '💍', 'description': 'Diamond ring'},
      {'id': 'premium_004', 'name': 'Gem', 'icon': '💠', 'description': 'Blue gem'},
      
      // Special Medical Category
      {'id': 'premium_005', 'name': 'Stethoscope', 'icon': '🩺', 'description': 'Doctor\'s tool'},
      {'id': 'premium_006', 'name': 'Heart Monitor', 'icon': '❤️‍🩹', 'description': 'Caring heart'},
      {'id': 'premium_007', 'name': 'Medical Bag', 'icon': '🏥', 'description': 'Hospital care'},
      {'id': 'premium_008', 'name': 'Ambulance', 'icon': '🚑', 'description': 'Emergency care'},
      
      // Premium Flowers Category
      {'id': 'premium_009', 'name': 'Orchid', 'icon': '🏵️', 'description': 'Exotic orchid'},
      {'id': 'premium_010', 'name': 'Lotus', 'icon': '🪷', 'description': 'Sacred lotus'},
      {'id': 'premium_011', 'name': 'Rose Bouquet', 'icon': '🌹🌹', 'description': 'Dozen roses'},
      
      // Luxury Food Category
      {'id': 'premium_012', 'name': 'Champagne', 'icon': '🍾', 'description': 'Celebration drink'},
      {'id': 'premium_013', 'name': 'Wine', 'icon': '🍷', 'description': 'Fine wine'},
      {'id': 'premium_014', 'name': 'Cocktail', 'icon': '🍹', 'description': 'Tropical drink'},
      {'id': 'premium_015', 'name': 'Sushi', 'icon': '🍣', 'description': 'Gourmet sushi'},
      {'id': 'premium_016', 'name': 'Lobster', 'icon': '🦞', 'description': 'Luxury seafood'},
      
      // Travel & Adventure Category
      {'id': 'premium_017', 'name': 'Airplane', 'icon': '✈️', 'description': 'Travel together'},
      {'id': 'premium_018', 'name': 'Cruise Ship', 'icon': '🚢', 'description': 'Ocean voyage'},
      {'id': 'premium_019', 'name': 'Island', 'icon': '🏝️', 'description': 'Private island'},
      {'id': 'premium_020', 'name': 'Castle', 'icon': '🏰', 'description': 'Fairy tale'},
      
      // Romance Category
      {'id': 'premium_021', 'name': 'Love Letter', 'icon': '💌', 'description': 'Secret message'},
      {'id': 'premium_022', 'name': 'Cupid', 'icon': '💘', 'description': 'Arrow of love'},
      {'id': 'premium_023', 'name': 'Wedding', 'icon': '💒', 'description': 'Chapel of love'},
      {'id': 'premium_024', 'name': 'Kiss Mark', 'icon': '💋', 'description': 'Sealed with kiss'},
      
      // Achievement Category
      {'id': 'premium_025', 'name': 'Trophy', 'icon': '🏆', 'description': 'Champion award'},
      {'id': 'premium_026', 'name': 'Medal', 'icon': '🥇', 'description': 'Gold medal'},
      {'id': 'premium_027', 'name': 'Ribbon', 'icon': '🎗️', 'description': 'Honor ribbon'},
      {'id': 'premium_028', 'name': 'Certificate', 'icon': '📜', 'description': 'Achievement'},
      
      // Entertainment Category
      {'id': 'premium_029', 'name': 'Movie', 'icon': '🎬', 'description': 'Movie night'},
      {'id': 'premium_030', 'name': 'Concert', 'icon': '🎤', 'description': 'Live music'},
      {'id': 'premium_031', 'name': 'Game', 'icon': '🎮', 'description': 'Game together'},
      {'id': 'premium_032', 'name': 'Fireworks', 'icon': '🎆', 'description': 'Spectacular show'},
      
      // Luxury Vehicles Category
      {'id': 'premium_033', 'name': 'Sports Car', 'icon': '🏎️', 'description': 'Fast ride'},
      {'id': 'premium_034', 'name': 'Yacht', 'icon': '🛥️', 'description': 'Luxury boat'},
      {'id': 'premium_035', 'name': 'Helicopter', 'icon': '🚁', 'description': 'Sky tour'},
      
      // Special Occasions Category
      {'id': 'premium_036', 'name': 'Birthday Cake', 'icon': '🎂', 'description': 'Special day'},
      {'id': 'premium_037', 'name': 'Anniversary', 'icon': '💑', 'description': 'Together forever'},
      {'id': 'premium_038', 'name': 'New Year', 'icon': '🎊', 'description': 'Fresh start'},
      
      // Zodiac Category
      {'id': 'premium_039', 'name': 'Aries', 'icon': '♈', 'description': 'Fire sign'},
      {'id': 'premium_040', 'name': 'Taurus', 'icon': '♉', 'description': 'Earth sign'},
      {'id': 'premium_041', 'name': 'Gemini', 'icon': '♊', 'description': 'Air sign'},
      {'id': 'premium_042', 'name': 'Cancer', 'icon': '♋', 'description': 'Water sign'},
      {'id': 'premium_043', 'name': 'Leo', 'icon': '♌', 'description': 'Fire sign'},
      {'id': 'premium_044', 'name': 'Virgo', 'icon': '♍', 'description': 'Earth sign'},
      
      // Mystical Category
      {'id': 'premium_045', 'name': 'Crystal Ball', 'icon': '🔮', 'description': 'See the future'},
      {'id': 'premium_046', 'name': 'Magic Wand', 'icon': '🪄', 'description': 'Make magic'},
      {'id': 'premium_047', 'name': 'Unicorn', 'icon': '🦄', 'description': 'Mythical creature'},
      {'id': 'premium_048', 'name': 'Dragon', 'icon': '🐉', 'description': 'Powerful dragon'},
      
      // Tech & Modern Category
      {'id': 'premium_049', 'name': 'Robot', 'icon': '🤖', 'description': 'AI companion'},
      {'id': 'premium_050', 'name': 'Rocket', 'icon': '🚀', 'description': 'To the moon'},
      {'id': 'premium_051', 'name': 'Satellite', 'icon': '🛰️', 'description': 'Space tech'},
      
      // Art Category
      {'id': 'premium_052', 'name': 'Art Palette', 'icon': '🎨', 'description': 'Creative soul'},
      {'id': 'premium_053', 'name': 'Frame', 'icon': '🖼️', 'description': 'Picture perfect'},
      {'id': 'premium_054', 'name': 'Sculpture', 'icon': '🗿', 'description': 'Timeless art'},
      
      // Music Category
      {'id': 'premium_055', 'name': 'Piano', 'icon': '🎹', 'description': 'Grand piano'},
      {'id': 'premium_056', 'name': 'Guitar', 'icon': '🎸', 'description': 'Rock on'},
      {'id': 'premium_057', 'name': 'Violin', 'icon': '🎻', 'description': 'Classical music'},
      {'id': 'premium_058', 'name': 'Drums', 'icon': '🥁', 'description': 'Beat drop'},
      {'id': 'premium_059', 'name': 'Trumpet', 'icon': '🎺', 'description': 'Jazz vibes'},
      {'id': 'premium_060', 'name': 'Microphone', 'icon': '🎙️', 'description': 'Sing together'},
    ];
    
    // Convert free gifts to Gift objects
    for (var giftData in freeGifts) {
      gifts.add(Gift(
        id: giftData['id'],
        name: giftData['name'],
        description: giftData['description'],
        imageUrl: '', // Will be replaced with actual URLs
        icon: giftData['icon'],
        price: 0, // Free gifts have no coin cost
        category: 'free',
        isAvailable: true,
      ));
    }
    
    // Convert premium gifts to Gift objects
    for (var giftData in premiumGifts) {
      gifts.add(Gift(
        id: giftData['id'],
        name: giftData['name'],
        description: giftData['description'],
        imageUrl: '', // Will be replaced with actual URLs
        icon: giftData['icon'],
        price: 10, // Premium gifts cost 10 coins
        category: 'premium',
        isAvailable: true,
      ));
    }
    
    return gifts;
  }
  
  static List<Gift> getFreeGifts() {
    return getAllGifts().where((gift) => gift.category == 'free').toList();
  }
  
  static List<Gift> getPremiumGifts() {
    return getAllGifts().where((gift) => gift.category == 'premium').toList();
  }
  
  static Gift? getGiftById(String id) {
    try {
      return getAllGifts().firstWhere((gift) => gift.id == id);
    } catch (e) {
      return null;
    }
  }
} 