class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? displayName;
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final String? bio;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? profession;
  final String? nursingSpecialty;
  final String? jobTitle;
  final String? workLocation;
  final List<String>? profileImages;
  final String? profileImageUrl;
  final List<String>? interests;
  final List<String>? preferences;
  final List<String>? socialMediaLinks;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final String subscriptionPlan; // 'free', 'starter', 'gold'
  final DateTime? subscriptionExpiry;
  final List<String>? badges;
  final int? distance;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.phoneNumber,
    this.age,
    this.gender,
    this.bio,
    this.location,
    this.city,
    this.state,
    this.country,
    this.profession,
    this.nursingSpecialty,
    this.jobTitle,
    this.workLocation,
    this.profileImages,
    this.profileImageUrl,
    this.interests,
    this.preferences,
    this.socialMediaLinks,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.subscriptionPlan = 'free',
    this.subscriptionExpiry,
    this.badges,
    this.distance,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get name => displayName ?? fullName;
  String get profilePictureUrl => profileImageUrl ?? (profileImages?.isNotEmpty == true ? profileImages!.first : '');
  
  bool get isGoldSubscriber => subscriptionPlan == 'gold' && 
    (subscriptionExpiry?.isAfter(DateTime.now()) ?? false);
  
  bool get isStarterSubscriber => subscriptionPlan == 'starter' && 
    (subscriptionExpiry?.isAfter(DateTime.now()) ?? false);
  
  bool get isFreeUser => subscriptionPlan == 'free' || 
    (subscriptionExpiry?.isBefore(DateTime.now()) ?? true);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      gender: json['gender']?.toString(),
      bio: json['bio']?.toString(),
      location: json['location']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      profession: json['profession']?.toString(),
      nursingSpecialty: json['nursing_specialty']?.toString(),
      jobTitle: json['job_title']?.toString(),
      workLocation: json['work_location']?.toString(),
      profileImages: json['profile_images'] != null 
        ? List<String>.from(json['profile_images'].map((e) => e.toString()))
        : null,
      profileImageUrl: json['profile_image_url']?.toString(),
      interests: json['interests'] != null 
        ? List<String>.from(json['interests'].map((e) => e.toString()))
        : null,
      preferences: json['preferences'] != null 
        ? List<String>.from(json['preferences'].map((e) => e.toString()))
        : null,
      socialMediaLinks: json['social_media_links'] != null 
        ? List<String>.from(json['social_media_links'].map((e) => e.toString()))
        : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
      isOnline: json['is_online'] == true || json['is_online'] == 'true',
      lastSeen: json['last_seen'] != null 
        ? DateTime.tryParse(json['last_seen'].toString())
        : null,
      subscriptionPlan: json['subscription_plan']?.toString() ?? 'free',
      subscriptionExpiry: json['subscription_expiry'] != null 
        ? DateTime.tryParse(json['subscription_expiry'].toString())
        : null,
      badges: json['badges'] != null 
        ? List<String>.from(json['badges'].map((e) => e.toString()))
        : null,
      distance: json['distance'] != null ? int.tryParse(json['distance'].toString()) : null,
      settings: json['settings'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'age': age,
      'gender': gender,
      'bio': bio,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'profession': profession,
      'nursing_specialty': nursingSpecialty,
      'job_title': jobTitle,
      'work_location': workLocation,
      'profile_images': profileImages,
      'profile_image_url': profileImageUrl,
      'interests': interests,
      'preferences': preferences,
      'social_media_links': socialMediaLinks,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'subscription_plan': subscriptionPlan,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'badges': badges,
      'distance': distance,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? phoneNumber,
    int? age,
    String? gender,
    String? bio,
    String? location,
    String? city,
    String? state,
    String? country,
    String? profession,
    String? nursingSpecialty,
    String? jobTitle,
    String? workLocation,
    List<String>? profileImages,
    String? profileImageUrl,
    List<String>? interests,
    List<String>? preferences,
    List<String>? socialMediaLinks,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    String? subscriptionPlan,
    DateTime? subscriptionExpiry,
    List<String>? badges,
    int? distance,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      profession: profession ?? this.profession,
      nursingSpecialty: nursingSpecialty ?? this.nursingSpecialty,
      jobTitle: jobTitle ?? this.jobTitle,
      workLocation: workLocation ?? this.workLocation,
      profileImages: profileImages ?? this.profileImages,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      badges: badges ?? this.badges,
      distance: distance ?? this.distance,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Compatibility aliases
typedef UserProfile = User;
typedef UserModel = User; 
