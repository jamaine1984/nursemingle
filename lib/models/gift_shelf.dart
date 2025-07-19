import 'gift_model.dart';

class GiftShelf {
  static List<Gift> get allGifts => [
    Gift(
      id: '1',
      name: 'Heart',
      description: 'Show your love',
      imageUrl: '❤️',
      icon: '❤️',
      price: 10,
      category: 'romantic',
    ),
    Gift(
      id: '2',
      name: 'Rose',
      description: 'A beautiful rose',
      imageUrl: '🌹',
      icon: '🌹',
      price: 15,
      category: 'romantic',
    ),
    Gift(
      id: '3',
      name: 'Coffee',
      description: 'Buy them a coffee',
      imageUrl: '☕',
      icon: '☕',
      price: 5,
      category: 'casual',
    ),
    Gift(
      id: '4',
      name: 'Diamond',
      description: 'Premium gift',
      imageUrl: '💎',
      icon: '💎',
      price: 50,
      category: 'premium',
    ),
  ];

  static List<Gift> getGiftsByCategory(String category) {
    return allGifts.where((gift) => gift.category == category).toList();
  }
} 