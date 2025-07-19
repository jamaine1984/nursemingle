class LiveStream {
  final String id;
  final String streamerId;
  final String streamerName;
  final String streamerAvatar;
  final String title;
  final String description;
  final String thumbnail;
  final int viewers;
  final bool isActive;
  final DateTime startTime;
  final DateTime? endTime;
  final String? roomName;
  final String? roomToken;
  final Map<String, dynamic>? liveKitConfig;
  final List<String> tags;
  final String category;
  final Map<String, dynamic>? metadata;

  LiveStream({
    required this.id,
    required this.streamerId,
    required this.streamerName,
    required this.streamerAvatar,
    required this.title,
    required this.description,
    required this.thumbnail,
    this.viewers = 0,
    this.isActive = true,
    required this.startTime,
    this.endTime,
    this.roomName,
    this.roomToken,
    this.liveKitConfig,
    this.tags = const [],
    this.category = 'general',
    this.metadata,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'] ?? '',
      streamerId: json['streamer_id'] ?? '',
      streamerName: json['streamer_name'] ?? '',
      streamerAvatar: json['streamer_avatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      viewers: json['viewers'] ?? 0,
      isActive: json['is_active'] ?? true,
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      roomName: json['room_name'],
      roomToken: json['room_token'],
      liveKitConfig: json['livekit_config'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      category: json['category'] ?? 'general',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streamer_id': streamerId,
      'streamer_name': streamerName,
      'streamer_avatar': streamerAvatar,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'viewers': viewers,
      'is_active': isActive,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'room_name': roomName,
      'room_token': roomToken,
      'livekit_config': liveKitConfig,
      'tags': tags,
      'category': category,
      'metadata': metadata,
    };
  }

  LiveStream copyWith({
    String? id,
    String? streamerId,
    String? streamerName,
    String? streamerAvatar,
    String? title,
    String? description,
    String? thumbnail,
    int? viewers,
    bool? isActive,
    DateTime? startTime,
    DateTime? endTime,
    String? roomName,
    String? roomToken,
    Map<String, dynamic>? liveKitConfig,
    List<String>? tags,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return LiveStream(
      id: id ?? this.id,
      streamerId: streamerId ?? this.streamerId,
      streamerName: streamerName ?? this.streamerName,
      streamerAvatar: streamerAvatar ?? this.streamerAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      viewers: viewers ?? this.viewers,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomName: roomName ?? this.roomName,
      roomToken: roomToken ?? this.roomToken,
      liveKitConfig: liveKitConfig ?? this.liveKitConfig,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else {
      return DateTime.now().difference(startTime);
    }
  }

  String get formattedDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get viewersText {
    if (viewers < 1000) {
      return viewers.toString();
    } else if (viewers < 1000000) {
      return '${(viewers / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(viewers / 1000000).toStringAsFixed(1)}M';
    }
  }
} 
