import 'package:donation_platform/data/models/user/user_verification.dart';

class AppUser {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final bool isVerified;
  final bool isActive;
  final String userType; // "donor", "organization", "admin"
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  
  // User verification details
  final UserVerification verification;

  AppUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.isVerified,
    required this.isActive,
    required this.userType,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.verification,
  });
  
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      isVerified: json['is_verified'],
      isActive: json['is_active'],
      userType: json['user_type'],
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLoginAt: json['last_login_at'] != null 
        ? DateTime.parse(json['last_login_at']) 
        : null,
      verification: json['verification'] != null 
        ? UserVerification.fromJson(json['verification'])
        : UserVerification(
            id: '',
            userId: json['id'],
            cnicVerified: false,
            phoneVerified: false,
            isBlacklisted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'is_verified': isVerified,
      'is_active': isActive,
      'user_type': userType,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'verification': verification.toJson(),
    };
  }
  
  // Create a copy of the user with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    bool? isVerified,
    bool? isActive,
    String? userType,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserVerification? verification,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      verification: verification ?? this.verification,
    );
  }

  // Check if this user is a donor
  bool get isDonor => userType == 'donor';
  
  // Check if this user is an organization
  bool get isOrganization => userType == 'organization';
  
  // Check if this user is an admin
  bool get isAdmin => userType == 'admin';
}