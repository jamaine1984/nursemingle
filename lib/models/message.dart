class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String conversationId;
  final String content;
  final String type; // 'text', 'image', 'gift', 'video', 'audio'
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final Map<String, dynamic>? metadata;
  final String? imageUrl;
  final String? giftId;
  final String? replyToId;

  // Computed properties for compatibility
  String get senderName => metadata?['sender_name'] ?? 'Unknown';

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.conversationId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.metadata,
    this.imageUrl,
    this.giftId,
    this.replyToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      isDelivered: json['is_delivered'] ?? false,
      metadata: json['metadata'],
      imageUrl: json['image_url'],
      giftId: json['gift_id'],
      replyToId: json['reply_to_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'conversation_id': conversationId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'is_delivered': isDelivered,
      'metadata': metadata,
      'image_url': imageUrl,
      'gift_id': giftId,
      'reply_to_id': replyToId,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? conversationId,
    String? content,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isDelivered,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    String? giftId,
    String? replyToId,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      giftId: giftId ?? this.giftId,
      replyToId: replyToId ?? this.replyToId,
    );
  }
} 
