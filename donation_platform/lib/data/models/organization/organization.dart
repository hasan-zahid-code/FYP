import 'package:donation_platform/data/models/common/category.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';

class Organization {
  final String userId;
  final String organizationName;
  final String? description;
  final String? missionStatement;
  final String? vision;
  final int? foundingYear;
  final String organizationType;
  final String? registrationNumber;
  final String? taxId;
  final String? websiteUrl;
  final Map<String, String>? socialMedia;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isAddressVerified;
  final String verificationStatus; // "pending", "in_review", "approved", "rejected"
  final bool featured;
  final String? logoUrl;
  final String? bannerUrl;
  final String contactEmail;
  final String contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Organization verification details
  final OrganizationVerification? verification;
  
  // Categories
  final List<Category> categories;
  
  // Distance (if returned from the nearby organizations query)
  final double? distanceKm;
  
  Organization({
    required this.userId,
    required this.organizationName,
    this.description,
    this.missionStatement,
    this.vision,
    this.foundingYear,
    required this.organizationType,
    this.registrationNumber,
    this.taxId,
    this.websiteUrl,
    this.socialMedia,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isAddressVerified,
    required this.verificationStatus,
    required this.featured,
    this.logoUrl,
    this.bannerUrl,
    required this.contactEmail,
    required this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
    this.verification,
    required this.categories,
    this.distanceKm,
  });
  
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      userId: json['user_id'],
      organizationName: json['organization_name'],
      description: json['description'],
      missionStatement: json['mission_statement'],
      vision: json['vision'],
      foundingYear: json['founding_year'],
      organizationType: json['organization_type'],
      registrationNumber: json['registration_number'],
      taxId: json['tax_id'],
      websiteUrl: json['website_url'],
      socialMedia: json['social_media'] != null 
        ? Map<String, String>.from(json['social_media'])
        : null,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      isAddressVerified: json['is_address_verified'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      featured: json['featured'] ?? false,
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      verification: json['verification'] != null 
        ? OrganizationVerification.fromJson(json['verification'])
        : null,
      categories: json['categories'] != null
        ? (json['categories'] as List).map((c) => Category.fromJson(c)).toList()
        : [],
      distanceKm: json['distance_km'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'organization_name': organizationName,
      'description': description,
      'mission_statement': missionStatement,
      'vision': vision,
      'founding_year': foundingYear,
      'organization_type': organizationType,
      'registration_number': registrationNumber,
      'tax_id': taxId,
      'website_url': websiteUrl,
      'social_media': socialMedia,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_address_verified': isAddressVerified,
      'verification_status': verificationStatus,
      'featured': featured,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'verification': verification?.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'distance_km': distanceKm,
    };
  }
  
  // Create a copy of the organization with updated fields
  Organization copyWith({
    String? userId,
    String? organizationName,
    String? description,
    String? missionStatement,
    String? vision,
    int? foundingYear,
    String? organizationType,
    String? registrationNumber,
    String? taxId,
    String? websiteUrl,
    Map<String, String>? socialMedia,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isAddressVerified,
    String? verificationStatus,
    bool? featured,
    String? logoUrl,
    String? bannerUrl,
    String? contactEmail,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrganizationVerification? verification,
    List<Category>? categories,
    double? distanceKm,
  }) {
    return Organization(
      userId: userId ?? this.userId,
      organizationName: organizationName ?? this.organizationName,
      description: description ?? this.description,
      missionStatement: missionStatement ?? this.missionStatement,
      vision: vision ?? this.vision,
      foundingYear: foundingYear ?? this.foundingYear,
      organizationType: organizationType ?? this.organizationType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMedia: socialMedia ?? this.socialMedia,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAddressVerified: isAddressVerified ?? this.isAddressVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      featured: featured ?? this.featured,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verification: verification ?? this.verification,
      categories: categories ?? this.categories,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
  
  // Format categories as comma-separated list
  String get categoriesText {
    if (categories.isEmpty) {
      return 'General';
    }
    return categories.map((c) => c.name).join(', ');
  }
  
  // Get address as a formatted string
  String get formattedAddress {
    final parts = [
      address,
      city,
      state,
      country,
      postalCode,
    ].where((part) => part.isNotEmpty).toList();
    
    return parts.join(', ');
  }
  
  // Get distance text
  String get distanceText {
    if (distanceKm == null) {
      return '';
    }
    
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)} m';
    }
    
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}