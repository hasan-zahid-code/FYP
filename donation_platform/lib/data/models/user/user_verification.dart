class UserVerification {
  final String id;
  final String userId;
  final String? cnic; // National ID number
  final bool cnicVerified;
  final DateTime? cnicVerifiedAt;
  final Map<String, dynamic>? cnicVerificationResponse;
  final bool phoneVerified;
  final DateTime? phoneVerifiedAt;
  final bool isBlacklisted;
  final String? blacklistedReason;
  final DateTime? blacklistedAt;
  final String? blacklistedBy; // Admin ID
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserVerification({
    required this.id,
    required this.userId,
    this.cnic,
    required this.cnicVerified,
    this.cnicVerifiedAt,
    this.cnicVerificationResponse,
    required this.phoneVerified,
    this.phoneVerifiedAt,
    required this.isBlacklisted,
    this.blacklistedReason,
    this.blacklistedAt,
    this.blacklistedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserVerification.fromJson(Map<String, dynamic> json) {
    return UserVerification(
      id: json['id'],
      userId: json['user_id'],
      cnic: json['cnic'],
      cnicVerified: json['cnic_verified'] ?? false,
      cnicVerifiedAt: json['cnic_verified_at'] != null 
        ? DateTime.parse(json['cnic_verified_at']) 
        : null,
      cnicVerificationResponse: json['cnic_verification_response'],
      phoneVerified: json['phone_verified'] ?? false,
      phoneVerifiedAt: json['phone_verified_at'] != null 
        ? DateTime.parse(json['phone_verified_at']) 
        : null,
      isBlacklisted: json['is_blacklisted'] ?? false,
      blacklistedReason: json['blacklisted_reason'],
      blacklistedAt: json['blacklisted_at'] != null 
        ? DateTime.parse(json['blacklisted_at']) 
        : null,
      blacklistedBy: json['blacklisted_by'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cnic': cnic,
      'cnic_verified': cnicVerified,
      'cnic_verified_at': cnicVerifiedAt?.toIso8601String(),
      'cnic_verification_response': cnicVerificationResponse,
      'phone_verified': phoneVerified,
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'is_blacklisted': isBlacklisted,
      'blacklisted_reason': blacklistedReason,
      'blacklisted_at': blacklistedAt?.toIso8601String(),
      'blacklisted_by': blacklistedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create a copy of the verification with updated fields
  UserVerification copyWith({
    String? id,
    String? userId,
    String? cnic,
    bool? cnicVerified,
    DateTime? cnicVerifiedAt,
    Map<String, dynamic>? cnicVerificationResponse,
    bool? phoneVerified,
    DateTime? phoneVerifiedAt,
    bool? isBlacklisted,
    String? blacklistedReason,
    DateTime? blacklistedAt,
    String? blacklistedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cnic: cnic ?? this.cnic,
      cnicVerified: cnicVerified ?? this.cnicVerified,
      cnicVerifiedAt: cnicVerifiedAt ?? this.cnicVerifiedAt,
      cnicVerificationResponse: cnicVerificationResponse ?? this.cnicVerificationResponse,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistedReason: blacklistedReason ?? this.blacklistedReason,
      blacklistedAt: blacklistedAt ?? this.blacklistedAt,
      blacklistedBy: blacklistedBy ?? this.blacklistedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}