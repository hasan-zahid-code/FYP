// =======================================================
// UPDATED CORE MODELS
// =======================================================
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// User Model - Base class for all users
class User {
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

  User({
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
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      verification: UserVerification.fromJson(json['verification']),
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
}

// User Verification Model (Updated with blacklisting)
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
      cnicVerified: json['cnic_verified'],
      cnicVerifiedAt: json['cnic_verified_at'] != null 
        ? DateTime.parse(json['cnic_verified_at']) 
        : null,
      cnicVerificationResponse: json['cnic_verification_response'],
      phoneVerified: json['phone_verified'],
      phoneVerifiedAt: json['phone_verified_at'] != null 
        ? DateTime.parse(json['phone_verified_at']) 
        : null,
      isBlacklisted: json['is_blacklisted'],
      blacklistedReason: json['blacklisted_reason'],
      blacklistedAt: json['blacklisted_at'] != null 
        ? DateTime.parse(json['blacklisted_at']) 
        : null,
      blacklistedBy: json['blacklisted_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
}

// Donor Profile Model
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
      isAnonymousByDefault: json['is_anonymous_by_default'],
      notificationPreferences: json['notification_preferences'],
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
}

// Organization Model (Updated)
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
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isAddressVerified: json['is_address_verified'],
      verificationStatus: json['verification_status'],
      featured: json['featured'],
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
    };
  }
}

// Category Model
class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Donation Category Model (Food, Clothes, Money, Other)
class DonationCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  DonationCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory DonationCategory.fromJson(Map<String, dynamic> json) {
    return DonationCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Organization Verification Model (Updated - Admin approval required)
class OrganizationVerification {
  final String id;
  final String organizationId;
  
  // Registration Documents
  final String? registrationCertificateUrl;
  final String? taxCertificateUrl;
  final String? annualReportUrl;
  final String? governingDocumentUrl;
  
  // Financial Documents
  final String? bankStatementUrl;
  final String? financialReportUrl;
  
  // Board and Leadership
  final String? boardResolutionUrl;
  final List<BoardMember>? boardMembers;
  
  // Contact Person Details
  final String contactPersonName;
  final String contactPersonPosition;
  final String contactPersonEmail;
  final String contactPersonPhone;
  final String? contactPersonCnic;
  
  // Bank Details
  final String bankName;
  final String accountTitle;
  final String accountNumber;
  final String? branchCode;
  final String? swiftCode;
  final bool isBankVerified;
  
  // References
  final List<String>? referenceLetters;
  
  // Verification Process
  final DateTime submittedAt;
  final String verificationStatus; // "pending", "in_review", "approved", "rejected"
  final String? verificationStage;
  final String? verificationNotes;
  final String? verifiedBy; // Admin ID
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime updatedAt;
  
  OrganizationVerification({
    required this.id,
    required this.organizationId,
    this.registrationCertificateUrl,
    this.taxCertificateUrl,
    this.annualReportUrl,
    this.governingDocumentUrl,
    this.bankStatementUrl,
    this.financialReportUrl,
    this.boardResolutionUrl,
    this.boardMembers,
    required this.contactPersonName,
    required this.contactPersonPosition,
    required this.contactPersonEmail,
    required this.contactPersonPhone,
    this.contactPersonCnic,
    required this.bankName,
    required this.accountTitle,
    required this.accountNumber,
    this.branchCode,
    this.swiftCode,
    required this.isBankVerified,
    this.referenceLetters,
    required this.submittedAt,
    required this.verificationStatus,
    this.verificationStage,
    this.verificationNotes,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    required this.updatedAt,
  });
  
  factory OrganizationVerification.fromJson(Map<String, dynamic> json) {
    return OrganizationVerification(
      id: json['id'],
      organizationId: json['organization_id'],
      registrationCertificateUrl: json['registration_certificate_url'],
      taxCertificateUrl: json['tax_certificate_url'],
      annualReportUrl: json['annual_report_url'],
      governingDocumentUrl: json['governing_document_url'],
      bankStatementUrl: json['bank_statement_url'],
      financialReportUrl: json['financial_report_url'],
      boardResolutionUrl: json['board_resolution_url'],
      boardMembers: json['board_members'] != null
        ? (json['board_members'] as List).map((b) => BoardMember.fromJson(b)).toList()
        : null,
      contactPersonName: json['contact_person_name'],
      contactPersonPosition: json['contact_person_position'],
      contactPersonEmail: json['contact_person_email'],
      contactPersonPhone: json['contact_person_phone'],
      contactPersonCnic: json['contact_person_cnic'],
      bankName: json['bank_name'],
      accountTitle: json['account_title'],
      accountNumber: json['account_number'],
      branchCode: json['branch_code'],
      swiftCode: json['swift_code'],
      isBankVerified: json['is_bank_verified'],
      referenceLetters: json['reference_letters'] != null
        ? List<String>.from(json['reference_letters'])
        : null,
      submittedAt: DateTime.parse(json['submitted_at']),
      verificationStatus: json['verification_status'],
      verificationStage: json['verification_stage'],
      verificationNotes: json['verification_notes'],
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'] != null 
        ? DateTime.parse(json['verified_at']) 
        : null,
      rejectionReason: json['rejection_reason'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'registration_certificate_url': registrationCertificateUrl,
      'tax_certificate_url': taxCertificateUrl,
      'annual_report_url': annualReportUrl,
      'governing_document_url': governingDocumentUrl,
      'bank_statement_url': bankStatementUrl,
      'financial_report_url': financialReportUrl,
      'board_resolution_url': boardResolutionUrl,
      'board_members': boardMembers?.map((b) => b.toJson()).toList(),
      'contact_person_name': contactPersonName,
      'contact_person_position': contactPersonPosition,
      'contact_person_email': contactPersonEmail,
      'contact_person_phone': contactPersonPhone,
      'contact_person_cnic': contactPersonCnic,
      'bank_name': bankName,
      'account_title': accountTitle,
      'account_number': accountNumber,
      'branch_code': branchCode,
      'swift_code': swiftCode,
      'is_bank_verified': isBankVerified,
      'reference_letters': referenceLetters,
      'submitted_at': submittedAt.toIso8601String(),
      'verification_status': verificationStatus,
      'verification_stage': verificationStage,
      'verification_notes': verificationNotes,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Board Member Model
class BoardMember {
  final String name;
  final String position;
  final String? cnic;
  
  BoardMember({
    required this.name,
    required this.position,
    this.cnic,
  });
  
  factory BoardMember.fromJson(Map<String, dynamic> json) {
    return BoardMember(
      name: json['name'],
      position: json['position'],
      cnic: json['cnic'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'cnic': cnic,
    };
  }
}

// Campaign Model
class Campaign {
  final String id;
  final String organizationId;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isFeatured;
  final String campaignType;
  final String? coverImageUrl;
  final List<String>? galleryImages;
  final String? videoUrl;
  final String? categoryId;
  final List<String>? tags;
  final String? locationDescription;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Campaign({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isFeatured,
    required this.campaignType,
    this.coverImageUrl,
    this.galleryImages,
    this.videoUrl,
    this.categoryId,
    this.tags,
    this.locationDescription,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      organizationId: json['organization_id'],
      title: json['title'],
      description: json['description'],
      goalAmount: json['goal_amount'],
      raisedAmount: json['raised_amount'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'],
      isFeatured: json['is_featured'],
      campaignType: json['campaign_type'],
      coverImageUrl: json['cover_image_url'],
      galleryImages: json['gallery_images'] != null ? List<String>.from(json['gallery_images']) : null,
      videoUrl: json['video_url'],
      categoryId: json['category_id'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      locationDescription: json['location_description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'goal_amount': goalAmount,
      'raised_amount': raisedAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'is_featured': isFeatured,
      'campaign_type': campaignType,
      'cover_image_url': coverImageUrl,
      'gallery_images': galleryImages,
      'video_url': videoUrl,
      'category_id': categoryId,
      'tags': tags,
      'location_description': locationDescription,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Donation Model (Updated with donation categories and physical items)
class Donation {
  final String id;
  final String donorId;
  final String organizationId;
  final String? campaignId;
  final String donationCategoryId;
  final double? amount; // Null for non-monetary donations
  final String? currency; // Null for non-monetary donations
  final Map<String, dynamic>? donationItems; // Details for non-monetary donations
  final int? quantity; // For non-monetary donations
  final double? estimatedValue; // For non-monetary donations
  final bool isAnonymous;
  final String status; // "pending", "processing", "completed", "failed", "rejected"
  final String? paymentMethod; // Null for non-monetary donations
  final String? paymentId;
  final String? transactionReference;
  final String? donationNotes;
  final bool? pickupRequired; // For physical item donations
  final String? pickupAddress; // For physical item donations
  final DateTime? pickupDate; // For physical item donations
  final String? pickupStatus; // "scheduled", "completed", "cancelled"
  final bool? giftAidEligible;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? receiptUrl;
  final String? ipAddress;
  final Map<String, dynamic>? deviceInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Tracking information
  final DonationTracking? tracking;
  
  Donation({
    required this.id,
    required this.donorId,
    required this.organizationId,
    this.campaignId,
    required this.donationCategoryId,
    this.amount,
    this.currency,
    this.donationItems,
    this.quantity,
    this.estimatedValue,
    required this.isAnonymous,
    required this.status,
    this.paymentMethod,
    this.paymentId,
    this.transactionReference,
    this.donationNotes,
    this.pickupRequired,
    this.pickupAddress,
    this.pickupDate,
    this.pickupStatus,
    this.giftAidEligible,
    required this.isRecurring,
    this.recurringFrequency,
    this.receiptUrl,
    this.ipAddress,
    this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
    this.tracking,
  });
  
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      donorId: json['donor_id'],
      organizationId: json['organization_id'],
      campaignId: json['campaign_id'],
      donationCategoryId: json['donation_category_id'],
      amount: json['amount'],
      currency: json['currency'],
      donationItems: json['donation_items'],
      quantity: json['quantity'],
      estimatedValue: json['estimated_value'],
      isAnonymous: json['is_anonymous'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentId: json['payment_id'],
      transactionReference: json['transaction_reference'],
      donationNotes: json['donation_notes'],
      pickupRequired: json['pickup_required'],
      pickupAddress: json['pickup_address'],
      pickupDate: json['pickup_date'] != null ? DateTime.parse(json['pickup_date']) : null,
      pickupStatus: json['pickup_status'],
      giftAidEligible: json['gift_aid_eligible'],
      isRecurring: json['is_recurring'],
      recurringFrequency: json['recurring_frequency'],
      receiptUrl: json['receipt_url'],
      ipAddress: json['ip_address'],
      deviceInfo: json['device_info'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tracking: json['tracking'] != null ? DonationTracking.fromJson(json['tracking']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'organization_id': organizationId,
      'campaign_id': campaignId,
      'donation_category_id': donationCategoryId,
      'amount': amount,
      'currency': currency,
      'donation_items': donationItems,
      'quantity': quantity,
      'estimated_value': estimatedValue,
      'is_anonymous': isAnonymous,
      'status': status,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'transaction_reference': transactionReference,
      'donation_notes': donationNotes,
      'pickup_required': pickupRequired,
      'pickup_address': pickupAddress,
      'pickup_date': pickupDate?.toIso8601String(),
      'pickup_status': pickupStatus,
      'gift_aid_eligible': giftAidEligible,
      'is_recurring': isRecurring,
      'recurring_frequency': recurringFrequency,
      'receipt_url': receiptUrl,
      'ip_address': ipAddress,
      'device_info': deviceInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tracking': tracking?.toJson(),
    };
  }
}

// Donation Tracking Model
class DonationTracking {
  final String id;
  final String donationId;
  final String status; // "received", "processing", "utilized", "completed"
  final String? feedback;
  final String updatedBy;
  final DateTime createdAt;
  final List<DonationUpdate>? updates;
  
  DonationTracking({
    required this.id,
    required this.donationId,
    required this.status,
    this.feedback,
    required this.updatedBy,
    required this.createdAt,
    this.updates,
  });
  
  factory DonationTracking.fromJson(Map<String, dynamic> json) {
    return DonationTracking(
      id: json['id'],
      donationId: json['donation_id'],
      status: json['status'],
      feedback: json['feedback'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updates: json['updates'] != null 
        ? (json['updates'] as List).map((u) => DonationUpdate.fromJson(u)).toList()
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'status': status,
      'feedback': feedback,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updates': updates?.map((u) => u.toJson()).toList(),
    };
  }
}

// Donation Update Model
class DonationUpdate {
  final String id;
  final String donationId;
  final String title;
  final String description;
  final List<String>? mediaUrls; // Images or videos showing impact
  final String createdBy;
  final DateTime createdAt;
  
  DonationUpdate({
    required this.id,
    required this.donationId,
    required this.title,
    required this.description,
    this.mediaUrls,
    required this.createdBy,
    required this.createdAt,
  });
  
  factory DonationUpdate.fromJson(Map<String, dynamic> json) {
    return DonationUpdate(
      id: json['id'],
      donationId: json['donation_id'],
      title: json['title'],
      description: json['description'],
      mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls']) : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'title': title,
      'description': description,
      'media_urls': mediaUrls,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Payment Transaction Model
class PaymentTransaction {
  final String id;
  final String donationId;
  final String transactionId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String paymentGateway;
  final String status;
  final Map<String, dynamic>? gatewayResponse;
  final String? errorMessage;
  final String? refundStatus;
  final double? refundAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  PaymentTransaction({
    required this.id,
    required this.donationId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.status,
    this.gatewayResponse,
    this.errorMessage,
    this.refundStatus,
    this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      donationId: json['donation_id'],
      transactionId: json['transaction_id'],
      amount: json['amount'],
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      paymentGateway: json['payment_gateway'],
      status: json['status'],
      gatewayResponse: json['gateway_response'],
      errorMessage: json['error_message'],
      refundStatus: json['refund_status'],
      refundAmount: json['refund_amount'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_gateway': paymentGateway,
      'status': status,
      'gateway_response': gatewayResponse,
      'error_message': errorMessage,
      'refund_status': refundStatus,
      'refund_amount': refundAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Recurring Donation Model
class RecurringDonation {
  final String id;
  final String donorId;
  final String organizationId;
  final String? campaignId;
  final double amount;
  final String currency;
  final String frequency; // monthly, quarterly, annually
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime nextDonationDate;
  final String paymentMethod;
  final Map<String, dynamic> paymentDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  RecurringDonation({
    required this.id,
    required this.donorId,
    required this.organizationId,
    this.campaignId,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.nextDonationDate,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory RecurringDonation.fromJson(Map<String, dynamic> json) {
    return RecurringDonation(
      id: json['id'],
      donorId: json['donor_id'],
      organizationId: json['organization_id'],
      campaignId: json['campaign_id'],
      amount: json['amount'],
      currency: json['currency'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'],
      nextDonationDate: DateTime.parse(json['next_donation_date']),
      paymentMethod: json['payment_method'],
      paymentDetails: json['payment_details'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'organization_id': organizationId,
      'campaign_id': campaignId,
      'amount': amount,
      'currency': currency,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'next_donation_date': nextDonationDate.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_details': paymentDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// User Report Model
class UserReport {
  final String id;
  final String reporterId;
  final String reportedId;
  final String reportType; // 'spam', 'fraud', 'inappropriate', 'other'
  final String reportReason;
  final Map<String, dynamic>? reportEvidence;
  final String status; // 'pending', 'investigating', 'resolved', 'rejected'
  final String? adminNotes;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reportType,
    required this.reportReason,
    this.reportEvidence,
    required this.status,
    this.adminNotes,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'],
      reporterId: json['reporter_id'],
      reportedId: json['reported_id'],
      reportType: json['report_type'],
      reportReason: json['report_reason'],
      reportEvidence: json['report_evidence'],
      status: json['status'],
      adminNotes: json['admin_notes'],
      resolvedBy: json['resolved_by'],
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_id': reportedId,
      'report_type': reportType,
      'report_reason': reportReason,
      'report_evidence': reportEvidence,
      'status': status,
      'admin_notes': adminNotes,
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Notification Model
class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String notificationType;
  final String? relatedEntityType; // donation, organization, etc.
  final String? relatedEntityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  
  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });
  
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      relatedEntityType: json['related_entity_type'],
      relatedEntityId: json['related_entity_id'],
      isRead: json['is_read'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// GeoPoint for location
class GeoPoint {
  final double latitude;
  final double longitude;
  
  GeoPoint({
    required this.latitude,
    required this.longitude,
  });
  
  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// Organization Review Model
class OrganizationReview {
  final String id;
  final String organizationId;
  final String donorId;
  final int rating; // 1-5
  final String? title;
  final String? review;
  final bool isAnonymous;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  OrganizationReview({
    required this.id,
    required this.organizationId,
    required this.donorId,
    required this.rating,
    this.title,
    this.review,
    required this.isAnonymous,
    required this.isApproved,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory OrganizationReview.fromJson(Map<String, dynamic> json) {
    return OrganizationReview(
      id: json['id'],
      organizationId: json['organization_id'],
      donorId: json['donor_id'],
      rating: json['rating'],
      title: json['title'],
      review: json['review'],
      isAnonymous: json['is_anonymous'],
      isApproved: json['is_approved'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'donor_id': donorId,
      'rating': rating,
      'title': title,
      'review': review,
      'is_anonymous': isAnonymous,
      'is_approved': isApproved,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// =======================================================
// AUTHENTICATION AND VERIFICATION SERVICES
// =======================================================

abstract class AuthService {
  Future<User> registerUser(String email, String password, String fullName, String phone, String userType);
  Future<User> loginUser(String email, String password);
  Future<void> logoutUser();
  Future<User?> getCurrentUser();
  Future<bool> resetPassword(String email);
  Future<bool> updatePassword(String currentPassword, String newPassword);
  Future<bool> isUserBlacklisted(String userId);
}

abstract class VerificationService {
  // Phone verification with OTP
  Future<bool> sendPhoneVerificationOTP(String phone);
  Future<bool> verifyPhoneOTP(String phone, String otp);
  
  // CNIC (National ID) verification
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth);
  Future<Map<String, dynamic>> getCNICVerificationStatus(String userId);
  
  // Organization verification
  Future<bool> submitOrganizationVerification(OrganizationVerificationRequest request);
  Future<OrganizationVerification> getOrganizationVerificationStatus(String organizationId);
}

// Organization Verification Request
class OrganizationVerificationRequest {
  final String organizationId;
  final String registrationNumber;
  final String taxId;
  final Map<String, File> documents; // Document type -> File
  final ContactPerson contactPerson;
  final List<BoardMember> boardMembers;
  final String? website;
  final Map<String, String>? socialMediaProfiles;
  final BankDetails bankDetails;
  
  OrganizationVerificationRequest({
    required this.organizationId,
    required this.registrationNumber,
    required this.taxId,
    required this.documents,
    required this.contactPerson,
    required this.boardMembers,
    this.website,
    this.socialMediaProfiles,
    required this.bankDetails,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'registration_number': registrationNumber,
      'tax_id': taxId,
      'contact_person': contactPerson.toJson(),
      'board_members': boardMembers.map((b) => b.toJson()).toList(),
      'website': website,
      'social_media_profiles': socialMediaProfiles,
      'bank_details': bankDetails.toJson(),
    };
  }
}

// Contact Person
class ContactPerson {
  final String name;
  final String position;
  final String email;
  final String phone;
  final String? cnic;
  
  ContactPerson({
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    this.cnic,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'email': email,
      'phone': phone,
      'cnic': cnic,
    };
  }
}

// Bank Details
class BankDetails {
  final String accountTitle;
  final String accountNumber;
  final String bankName;
  final String? branchCode;
  final String? swiftCode;
  
  BankDetails({
    required this.accountTitle,
    required this.accountNumber,
    required this.bankName,
    this.branchCode,
    this.swiftCode,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'account_title': accountTitle,
      'account_number': accountNumber,
      'bank_name': bankName,
      'branch_code': branchCode,
      'swift_code': swiftCode,
    };
  }
}

// =======================================================
// DONATION SERVICES
// =======================================================

abstract class DonationService {
  // Create monetary donation
  Future<Donation> createMonetaryDonation({
    required String donorId,
    required String organizationId,
    String? campaignId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required bool isAnonymous,
    String? description,
    bool isRecurring = false,
    String? recurringFrequency,
  });
  
  // Create non-monetary donation (food, clothes, books, etc.)
  Future<Donation> createItemDonation({
    required String donorId,
    required String organizationId,
    String? campaignId,
    required String donationCategoryId,
    required Map<String, dynamic> items,
    required int quantity,
    double? estimatedValue,
    required bool isAnonymous,
    String? description,
    bool pickupRequired = false,
    String? pickupAddress,
    DateTime? pickupDate,
  });
  
  // Get donations by donor
  Future<List<Donation>> getDonationsByDonor(String donorId);
  
  // Get donations by organization
  Future<List<Donation>> getDonationsByOrganization(String organizationId);
  
  // Get donation by ID
  Future<Donation> getDonationById(String donationId);
  
  // Update donation status
  Future<bool> updateDonationStatus(String donationId, String status);
  
  // Add tracking update to donation
  Future<bool> addDonationUpdate(DonationUpdate update);
}

// =======================================================
// REPORTING SERVICES
// =======================================================

abstract class ReportingService {
  // Report a user or organization
  Future<String> reportUser({
    required String reporterId,
    required String reportedId,
    required String reportType,
    required String reason,
    Map<String, dynamic>? evidence,
  });
  
  // Get reports filed by a user
  Future<List<UserReport>> getReportsFiledByUser(String userId);
  
  // Get reports against a user
  Future<List<UserReport>> getReportsAgainstUser(String userId);
  
  // Get report by ID
  Future<UserReport> getReportById(String reportId);
  
  // Update report status (admin only)
  Future<bool> updateReportStatus(String reportId, String status, String adminId, String? notes);
}

// =======================================================
// ADMIN SERVICES
// =======================================================

abstract class AdminService {
  // Blacklist a donor
  Future<bool> blacklistDonor(String donorId, String reason, String adminId);
  
  // Approve organization
  Future<bool> approveOrganization(String organizationId, String adminId, String? notes);
  
  // Reject organization
  Future<bool> rejectOrganization(String organizationId, String adminId, String reason);
  
  // Get pending organization verifications
  Future<List<OrganizationVerification>> getPendingOrganizationVerifications();
  
  // Get user reports
  Future<List<UserReport>> getPendingUserReports();
  
  // Get platform statistics
  Future<Map<String, dynamic>> getPlatformStatistics();
  
  // Get donation statistics by category
  Future<List<Map<String, dynamic>>> getDonationStatisticsByCategory();
}

// =======================================================
// EXAMPLE IMPLEMENTATIONS OF KEY SERVICES
// =======================================================

// CNIC Verification Service Implementation 
class CNICVerificationServiceImpl implements VerificationService {
  final ApiService _apiService;
  
  CNICVerificationServiceImpl(this._apiService);
  
  @override
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth) async {
    // 1. Format validation
    if (!isValidCNICFormat(cnic)) {
      return false;
    }
    
    // 2. Call to NADRA API or similar national ID verification service
    try {
      final response = await _apiService.post('/verify/cnic', {
        'cnic': cnic,
        'name': name,
        'dob': dateOfBirth,
      });
      
      return response['verified'] == true;
    } catch (e) {
      print('CNIC verification failed: $e');
      return false;
    }
  }
  
  bool isValidCNICFormat(String cnic) {
    // Pakistani CNIC format: 12345-1234567-1
    final RegExp cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1});
    return cnicRegex.hasMatch(cnic);
  }
  
  @override
  Future<bool> sendPhoneVerificationOTP(String phone) {
    // Implementation details
    throw UnimplementedError();
  }
  
  @override
  Future<bool> verifyPhoneOTP(String phone, String otp) {
    // Implementation details
    throw UnimplementedError();
  }
  
  @override
  Future<Map<String, dynamic>> getCNICVerificationStatus(String userId) {
    // Implementation details
    throw UnimplementedError();
  }
  
  @override
  Future<bool> submitOrganizationVerification(OrganizationVerificationRequest request) {
    // Implementation details
    throw UnimplementedError();
  }
  
  @override
  Future<OrganizationVerification> getOrganizationVerificationStatus(String organizationId) {
    // Implementation details
    throw UnimplementedError();
  }
}