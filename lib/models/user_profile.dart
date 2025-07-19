class UserProfile {
  final String id;
  final String name;
  final int age;
  final String city;
  final String country;
  final String bio;
  final List<String> interests;
  final List<String> images;
  final String? introVideoUrl;
  final String? prompt;
  final List<String> languages;
  final double distance; // in km
  final bool isOnline;
  List<String> followers;
  List<String> following;
  bool isFollowedByCurrentUser;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.country,
    required this.bio,
    required this.interests,
    required this.images,
    this.introVideoUrl,
    this.prompt,
    this.languages = const [],
    this.distance = 0.0,
    this.isOnline = false,
    this.followers = const [],
    this.following = const [],
    this.isFollowedByCurrentUser = false,
  });

  UserProfile.empty()
      : id = '',
        name = '',
        age = 0,
        city = '',
        country = '',
        bio = '',
        interests = const [],
        images = const [],
        introVideoUrl = null,
        prompt = null,
        languages = const [],
        distance = 0.0,
        isOnline = false,
        followers = const [],
        following = const [],
        isFollowedByCurrentUser = false;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      bio: json['bio'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      introVideoUrl: json['introVideoUrl'],
      prompt: json['prompt'],
      languages: List<String>.from(json['languages'] ?? []),
      distance: (json['distance'] ?? 0.0).toDouble(),
      isOnline: json['isOnline'] ?? false,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      isFollowedByCurrentUser: json['isFollowedByCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'city': city,
      'country': country,
      'bio': bio,
      'interests': interests,
      'images': images,
      'introVideoUrl': introVideoUrl,
      'prompt': prompt,
      'languages': languages,
      'distance': distance,
      'isOnline': isOnline,
      'followers': followers,
      'following': following,
      'isFollowedByCurrentUser': isFollowedByCurrentUser,
    };
  }
} 
