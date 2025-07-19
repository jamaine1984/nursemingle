class SubscriptionModel {
  final String id;
  final String userId;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  
  // Daily usage tracking
  int dailyLikesUsed = 0;
  int dailyMessagesUsed = 0;
  int dailySuperLikesUsed = 0;
  DateTime lastResetDate = DateTime.now();

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  bool get isActive => DateTime.now().isBefore(endDate);
  
  // Plan limits based on subscription type
  int get dailyLikesLimit {
    switch (type) {
      case 'Free':
        return 20;
      case 'Starter':
        return 50; // Updated from unlimited
      case 'Gold':
        return 50; // Updated from unlimited, but can watch ads for more
      default:
        return 20;
    }
  }
  
  int get dailyMessagesLimit {
    switch (type) {
      case 'Free':
        return 10;
      case 'Starter':
        return -1; // Unlimited
      case 'Gold':
        return -1; // Unlimited
      default:
        return 10;
    }
  }
  
  int get dailySuperLikesLimit {
    switch (type) {
      case 'Free':
        return 0;
      case 'Starter':
        return 0;
      case 'Gold':
        return 5; // Updated from 10
      default:
        return 0;
    }
  }
  
  // Remaining counts
  int get likesLeft {
    if (dailyLikesLimit == -1) return -1; // Unlimited
    return dailyLikesLimit - dailyLikesUsed;
  }
  
  int get messagesLeft {
    if (dailyMessagesLimit == -1) return -1; // Unlimited
    return dailyMessagesLimit - dailyMessagesUsed;
  }
  
  int get superLikesLeft {
    if (dailySuperLikesLimit == -1) return -1; // Unlimited
    return dailySuperLikesLimit - dailySuperLikesUsed;
  }
  
  // Check if daily limits are reached
  bool get canLike => likesLeft > 0 || likesLeft == -1;
  bool get canMessage => messagesLeft > 0 || messagesLeft == -1;
  bool get canSuperLike => superLikesLeft > 0 || superLikesLeft == -1;
  
  // Feature access
  bool get canGoLive => type != 'Free';
  bool get canAccessCalls => type != 'Free';
  bool get canSendPremiumGifts => type != 'Free';
  
  // Call limits (in minutes per month)
  int get monthlyPhoneCallLimit {
    switch (type) {
      case 'Free':
        return 0;
      case 'Starter':
        return 100;
      case 'Gold':
        return -1; // Unlimited
      default:
        return 0;
    }
  }
  
  int get monthlyVideoCallLimit {
    switch (type) {
      case 'Free':
        return 0;
      case 'Starter':
        return 100;
      case 'Gold':
        return -1; // Unlimited
      default:
        return 0;
    }
  }
  
  // Live streaming limits (hours per month)
  int get monthlyLiveStreamLimit {
    switch (type) {
      case 'Free':
        return 0;
      case 'Starter':
        return 20;
      case 'Gold':
        return -1; // Unlimited
      default:
        return 0;
    }
  }
  
  // Reset daily limits at midnight
  void resetDailyLimits() {
    final now = DateTime.now();
    if (now.day != lastResetDate.day || now.month != lastResetDate.month || now.year != lastResetDate.year) {
      dailyLikesUsed = 0;
      dailyMessagesUsed = 0;
      dailySuperLikesUsed = 0;
      lastResetDate = now;
    }
  }
  
  // Use actions
  bool useLike() {
    if (!canLike) return false;
    if (likesLeft != -1) {
      dailyLikesUsed++;
    }
    return true;
  }
  
  bool useMessage() {
    if (!canMessage) return false;
    if (messagesLeft != -1) {
      dailyMessagesUsed++;
    }
    return true;
  }
  
  bool useSuperLike() {
    if (!canSuperLike) return false;
    if (superLikesLeft != -1) {
      dailySuperLikesUsed++;
    }
    return true;
  }
  
  // Add extra likes/messages/super likes from ads
  void addExtraLikes(int count) {
    if (dailyLikesLimit != -1) {
      dailyLikesUsed = (dailyLikesUsed - count).clamp(0, dailyLikesLimit);
    }
  }
  
  void addExtraMessages(int count) {
    if (dailyMessagesLimit != -1) {
      dailyMessagesUsed = (dailyMessagesUsed - count).clamp(0, dailyMessagesLimit);
    }
  }
  
  void addExtraSuperLikes(int count) {
    if (dailySuperLikesLimit != -1) {
      dailySuperLikesUsed = (dailySuperLikesUsed - count).clamp(0, dailySuperLikesLimit);
    }
  }
} 
