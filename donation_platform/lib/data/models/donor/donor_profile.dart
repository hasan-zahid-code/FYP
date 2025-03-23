class DonorProfile {
  final String userId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final List<String>? preferredCategories;
  final bool isAnonymousByDefault;
  final Map<String, dynamic>? notificationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  DonorProfile({
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.preferredCategories,
    required this.isAnonymousByDefault,
    this.notificationPreferences,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory DonorProfile.fromJson(Map<String, dynamic> json) {
    return DonorProfile(
      userId: json['user_id'],
      dateOfBirth: json['date_of_birth'] != null 
        ? DateTime.parse(json['date_of_birth']) 
        : null,
      gender: json['gender'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      preferredCategories: json['preferred_categories'] != null
        ? List<String>.from(json['preferred_categories'])
        : null,
      isAnonymousByDefault: json['is_anonymous_by_default'] ?? false,
      notificationPreferences: json['notification_preferences'] ?? {
        'email': true,
        'sms': true,
        'push': true,
      },
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'preferred_categories': preferredCategories,
      'is_anonymous_by_default': isAnonymousByDefault,
      'notification_preferences': notificationPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create a copy of the donor profile with updated fields
  DonorProfile copyWith({
    String? userId,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    List<String>? preferredCategories,
    bool? isAnonymousByDefault,
    Map<String, dynamic>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonorProfile(
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      isAnonymousByDefault: isAnonymousByDefault ?? this.isAnonymousByDefault,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Check if profile has a complete address
  bool get hasCompleteAddress {
    return address != null && city != null && state != null && country != null && postalCode != null;
  }
  
  // Get formatted full address
  String get formattedAddress {
    if (!hasCompleteAddress) {
      return 'No address provided';
    }
    
    return '$address, $city, $state, $country $postalCode';
  }
}