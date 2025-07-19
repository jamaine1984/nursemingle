class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? bio;
  final String? nursingSpecialty;
  final String? workLocation;
  final String? profileImageUrl;
  final List<String>? profileImages;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final int? age;
  final String? state;
  final String? jobTitle;
  final List<String>? badges;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int? giftPoints;
  final String? subscriptionPlan;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.nursingSpecialty,
    this.workLocation,
    this.profileImageUrl,
    this.profileImages,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.age,
    this.state,
    this.jobTitle,
    this.badges,
    this.city,
    this.latitude,
    this.longitude,
    this.giftPoints,
    this.subscriptionPlan,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
      bio: json['bio']?.toString(),
      nursingSpecialty: json['nursingSpecialty']?.toString(),
      workLocation: json['workLocation']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      profileImages: json['profileImages'] != null 
          ? List<String>.from(json['profileImages'])
          : null,
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.tryParse(json['lastSeen'])
          : null,
      age: json['age']?.toInt(),
      state: json['state']?.toString(),
      jobTitle: json['jobTitle']?.toString(),
      badges: json['badges'] != null 
          ? List<String>.from(json['badges'])
          : null,
      city: json['city']?.toString(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      giftPoints: json['giftPoints']?.toInt(),
      subscriptionPlan: json['subscriptionPlan']?.toString(),
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bio': bio,
      'nursingSpecialty': nursingSpecialty,
      'workLocation': workLocation,
      'profileImageUrl': profileImageUrl,
      'profileImages': profileImages,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'age': age,
      'state': state,
      'jobTitle': jobTitle,
      'badges': badges,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'giftPoints': giftPoints,
      'subscriptionPlan': subscriptionPlan,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? bio,
    String? nursingSpecialty,
    String? workLocation,
    String? profileImageUrl,
    List<String>? profileImages,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    int? age,
    String? state,
    String? jobTitle,
    List<String>? badges,
    String? city,
    double? latitude,
    double? longitude,
    int? giftPoints,
    String? subscriptionPlan,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      nursingSpecialty: nursingSpecialty ?? this.nursingSpecialty,
      workLocation: workLocation ?? this.workLocation,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImages: profileImages ?? this.profileImages,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      age: age ?? this.age,
      state: state ?? this.state,
      jobTitle: jobTitle ?? this.jobTitle,
      badges: badges ?? this.badges,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      giftPoints: giftPoints ?? this.giftPoints,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get displayName => fullName.trim().isNotEmpty ? fullName : email;
  
  bool get isPremiumUser => subscriptionPlan != null && subscriptionPlan != 'free';
}

// UserProfile alias for compatibility
typedef UserProfile = User;
typedef UserModel = User; 
