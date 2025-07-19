class Gift {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? icon; // Add icon property
  final int price; // in coins/credits
  final String category; // 'free', 'premium', 'special'
  final bool isAvailable;
  final bool isReceived;
  final String? senderId;
  final String? recipientId;
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final Map<String, dynamic>? metadata;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.icon,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.isReceived = false,
    this.senderId,
    this.recipientId,
    this.sentAt,
    this.receivedAt,
    this.metadata,
  });
  
  // Helper getter to check if gift is free
  bool get isFree => category == 'free';
  bool get isPremium => category == 'premium';

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      icon: json['icon'],
      price: json['price'] ?? 0,
      category: json['category'] ?? 'free',
      isAvailable: json['is_available'] ?? true,
      isReceived: json['is_received'] ?? false,
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'icon': icon,
      'price': price,
      'category': category,
      'is_available': isAvailable,
      'is_received': isReceived,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'sent_at': sentAt?.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    int? price,
    String? category,
    bool? isAvailable,
    bool? isReceived,
    String? senderId,
    String? recipientId,
    DateTime? sentAt,
    DateTime? receivedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      isReceived: isReceived ?? this.isReceived,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      sentAt: sentAt ?? this.sentAt,
      receivedAt: receivedAt ?? this.receivedAt,
      metadata: metadata ?? this.metadata,
    );
  }
} 
