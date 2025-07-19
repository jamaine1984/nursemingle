class GiftInventoryItem {
  final String giftId;
  final String type; // 'free' or 'premium'
  final int quantity;
  final DateTime lastUpdated;

  GiftInventoryItem({
    required this.giftId,
    required this.type,
    required this.quantity,
    required this.lastUpdated,
  });

  factory GiftInventoryItem.fromJson(Map<String, dynamic> json) {
    return GiftInventoryItem(
      giftId: json['giftId'] ?? json['gift_id'] ?? '',
      type: json['type'] ?? 'free',
      quantity: json['quantity'] ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'giftId': giftId,
      'type': type,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  GiftInventoryItem copyWith({
    String? giftId,
    String? type,
    int? quantity,
    DateTime? lastUpdated,
  }) {
    return GiftInventoryItem(
      giftId: giftId ?? this.giftId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserGiftInventory {
  final String userId;
  final List<GiftInventoryItem> inventory;
  final DateTime lastUpdated;

  UserGiftInventory({
    required this.userId,
    required this.inventory,
    required this.lastUpdated,
  });

  factory UserGiftInventory.fromJson(Map<String, dynamic> json) {
    return UserGiftInventory(
      userId: json['userId'] ?? json['user_id'] ?? '',
      inventory: (json['inventory'] as List<dynamic>?)
              ?.map((item) => GiftInventoryItem.fromJson(item))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'inventory': inventory.map((item) => item.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Helper method to get total quantity of a specific gift
  int getGiftQuantity(String giftId) {
    final item = inventory.firstWhere(
      (item) => item.giftId == giftId,
      orElse: () => GiftInventoryItem(
        giftId: giftId,
        type: 'free',
        quantity: 0,
        lastUpdated: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  // Helper method to check if user has a specific gift
  bool hasGift(String giftId) {
    return getGiftQuantity(giftId) > 0;
  }

  // Helper method to get all gifts of a specific type
  List<GiftInventoryItem> getGiftsByType(String type) {
    return inventory.where((item) => item.type == type).toList();
  }
} 