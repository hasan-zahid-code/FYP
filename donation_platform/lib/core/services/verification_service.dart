import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:donation_platform/core/utils/exceptions.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';
// import 'package:donation_platform/data/models/organization/board_member.dart';
// import 'package:donation_platform/core/services/api_service.dart';

// Custom exceptions
class VerificationException implements Exception {
  final String message;
  VerificationException(this.message);

  @override
  String toString() => 'VerificationException: $message';
}

class DataBaseException implements Exception {
  final String message;
  DataBaseException(this.message);

  @override
  String toString() => 'DataBaseException: $message';
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

// Class for organization verification request
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

class VerificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  // final ApiService _apiService = ApiService();

  // Phone verification with OTP
  Future<bool> sendPhoneVerificationOTP(String phone) async {
    try {
      // Generate random 6-digit OTP
      final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString();

      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // Save OTP to database
      await _supabase.from('otps').insert({
        'user_id': user.id,
        'phone': phone,
        'otp_code': otp,
        'purpose': 'phone_verification',
        'expires_at':
            DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        'is_used': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // In a real app, you would integrate with SMS service to send OTP
      // For demo purposes, we'll pretend we sent it
      print('OTP sent to $phone: $otp'); // For demo purposes only

      return true;
    } catch (e) {
      throw VerificationException('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyPhoneOTP(String phone, String otp) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // Check OTP
      final response = await _supabase
          .from('otps')
          .select()
          .eq('user_id', user.id)
          .eq('phone', phone)
          .eq('otp_code', otp)
          .eq('purpose', 'phone_verification')
          .eq('is_used', false)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response == null) {
        throw VerificationException('Invalid or expired OTP');
      }

      // Mark OTP as used
      await _supabase
          .from('otps')
          .update({'is_used': true}).eq('id', response['id']);

      // Update user verification
      await _supabase.from('user_verifications').update({
        'phone_verified': true,
        'phone_verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      // Update user verified status
      await _supabase.from('users').update({
        'is_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return true;
    } catch (e) {
      if (e is VerificationException) {
        rethrow;
      }
      throw VerificationException('Failed to verify OTP: $e');
    }
  }

  // CNIC (National ID) verification
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // In a real app, this would call an external verification API
      // For demo purposes, we'll simulate a successful verification

      // Update user verification
      await _supabase.from('user_verifications').update({
        'cnic': cnic,
        'cnic_verified': true,
        'cnic_verified_at': DateTime.now().toIso8601String(),
        'cnic_verification_response': {
          'verified': true,
          'status': 'success',
          'message': 'CNIC verification successful',
        },
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      return true;
    } catch (e) {
      throw VerificationException('Failed to verify CNIC: $e');
    }
  }

  // Get CNIC verification status
  Future<Map<String, dynamic>> getCNICVerificationStatus(String userId) async {
    try {
      final response = await _supabase
          .from('user_verifications')
          .select(
              'cnic, cnic_verified, cnic_verified_at, cnic_verification_response')
          .eq('user_id', userId)
          .single();

      return {
        'cnic': response['cnic'],
        'verified': response['cnic_verified'],
        'verified_at': response['cnic_verified_at'],
        'response': response['cnic_verification_response'],
      };
    } catch (e) {
      throw DataBaseException('Failed to get CNIC verification status: $e');
    }
  }

  // Submit organization verification
  Future<bool> submitOrganizationVerification(
      OrganizationVerificationRequest request) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if organization already has a verification record
      final existingVerification = await _supabase
          .from('organization_verifications')
          .select('id')
          .eq('organization_id', request.organizationId)
          .maybeSingle();

      // Upload documents to storage
      final Map<String, String> documentUrls = {};
      for (final entry in request.documents.entries) {
        final documentType = entry.key;
        final file = entry.value;

        // Upload file to storage
        final filename =
            '${request.organizationId}/${documentType}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
        final fileBytes = await file.readAsBytes();
        await _supabase.storage
            .from('verification_documents')
            .uploadBinary(filename, fileBytes);

        // Get file URL
        final fileUrl = _supabase.storage
            .from('verification_documents')
            .getPublicUrl(filename);

        documentUrls[documentType] = fileUrl;
      }

      // Prepare verification data
      final verificationData = {
        'organization_id': request.organizationId,
        'registration_certificate_url':
            documentUrls['registration_certificate'],
        'tax_certificate_url': documentUrls['tax_certificate'],
        'bank_statement_url': documentUrls['bank_statement'],
        'board_resolution_url': documentUrls['board_resolution'],
        'board_members':
            request.boardMembers.map((member) => member.toJson()).toList(),
        'contact_person_name': request.contactPerson.name,
        'contact_person_position': request.contactPerson.position,
        'contact_person_email': request.contactPerson.email,
        'contact_person_phone': request.contactPerson.phone,
        'contact_person_cnic': request.contactPerson.cnic,
        'bank_name': request.bankDetails.bankName,
        'account_title': request.bankDetails.accountTitle,
        'account_number': request.bankDetails.accountNumber,
        'branch_code': request.bankDetails.branchCode,
        'swift_code': request.bankDetails.swiftCode,
        'is_bank_verified': false,
        'submitted_at': DateTime.now().toIso8601String(),
        'verification_status': 'pending',
        'verification_stage': 'documents',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingVerification != null) {
        // Update existing verification
        await _supabase
            .from('organization_verifications')
            .update(verificationData)
            .eq('id', existingVerification['id']);
      } else {
        // Create new verification
        await _supabase
            .from('organization_verifications')
            .insert(verificationData);
      }

      // Update organization profile verification status
      await _supabase.from('organization_profiles').update({
        'verification_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', request.organizationId);

      return true;
    } catch (e) {
      throw VerificationException('Failed to submit verification: $e');
    }
  }

  // Get organization verification status
  Future<OrganizationVerification> getOrganizationVerificationStatus(
      String organizationId) async {
    try {
      final response = await _supabase
          .from('organization_verifications')
          .select()
          .eq('organization_id', organizationId)
          .single();

      return OrganizationVerification.fromJson(response);
    } catch (e) {
      throw DataBaseException(
          'Failed to get organization verification status: $e');
    }
  }
}
