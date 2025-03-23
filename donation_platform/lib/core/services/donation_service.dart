import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:donation_platform/data/models/donation/donation_update.dart';
import 'package:donation_platform/core/services/payment_service.dart';

class DonationException implements Exception {
  final String message;
  DonationException(this.message);
  
  @override
  String toString() => 'DonationException: $message';
}

class DonationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PaymentService _paymentService = PaymentService();
  
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
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Verify organization is approved
      final organization = await _supabase
          .from('organization_profiles')
          .select('verification_status')
          .eq('user_id', organizationId)
          .single();
      
      if (organization['verification_status'] != 'approved') {
        throw DonationException('Cannot donate to an unapproved organization');
      }
      
      // Process payment
      final paymentResult = await _paymentService.processPayment(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        donorId: donorId,
        description: 'Donation to organization'
      );
      
      if (!paymentResult['success']) {
        throw DonationException('Payment failed: ${paymentResult['message']}');
      }
      
      // Get monetary donation category ID
      final donationCategory = await _supabase
          .from('donation_categories')
          .select('id')
          .eq('name', 'Money')
          .single();
      
      // Create donation record
      final donationData = {
        'donor_id': donorId,
        'organization_id': organizationId,
        'campaign_id': campaignId,
        'donation_category_id': donationCategory['id'],
        'amount': amount,
        'currency': currency,
        'is_anonymous': isAnonymous,
        'status': 'pending', // Will be updated after confirmation
        'payment_method': paymentMethod,
        'payment_id': paymentResult['payment_id'],
        'transaction_reference': paymentResult['transaction_reference'],
        'donation_notes': description,
        'is_recurring': isRecurring,
        'recurring_frequency': recurringFrequency,
        'ip_address': null, // In a real app, capture user's IP
        'device_info': null, // In a real app, capture device info
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('donations')
          .insert(donationData)
          .select()
          .single();
      
      // Create payment transaction record
      await _supabase.from('payment_transactions').insert({
        'donation_id': response['id'],
        'transaction_id': paymentResult['transaction_id'],
        'amount': amount,
        'currency': currency,
        'payment_method': paymentMethod,
        'payment_gateway': paymentResult['payment_gateway'],
        'status': paymentResult['status'],
        'gateway_response': paymentResult['gateway_response'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Set up recurring donation if applicable
      if (isRecurring && recurringFrequency != null) {
        await _supabase.from('recurring_donations').insert({
          'donor_id': donorId,
          'organization_id': organizationId,
          'campaign_id': campaignId,
          'amount': amount,
          'currency': currency,
          'frequency': recurringFrequency,
          'start_date': DateTime.now().toIso8601String(),
          'is_active': true,
          'next_donation_date': _calculateNextDonationDate(recurringFrequency),
          'payment_method': paymentMethod,
          'payment_details': paymentResult['payment_details'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
      // Create notification for organization
      await _supabase.from('notifications').insert({
        'user_id': organizationId,
        'title': 'New Donation Received',
        'message': 'You have received a new donation of $amount $currency',
        'notification_type': 'donation',
        'related_entity_type': 'donation',
        'related_entity_id': response['id'],
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return Donation.fromJson(response);
    } catch (e) {
      if (e is DonationException) {
        rethrow;
      }
      throw DonationException('Failed to create monetary donation: $e');
    }
  }
  
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
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Verify organization is approved
      final organization = await _supabase
          .from('organization_profiles')
          .select('verification_status')
          .eq('user_id', organizationId)
          .single();
      
      if (organization['verification_status'] != 'approved') {
        throw DonationException('Cannot donate to an unapproved organization');
      }
      
      // Create donation record
      final donationData = {
        'donor_id': donorId,
        'organization_id': organizationId,
        'campaign_id': campaignId,
        'donation_category_id': donationCategoryId,
        'donation_items': items,
        'quantity': quantity,
        'estimated_value': estimatedValue,
        'is_anonymous': isAnonymous,
        'status': 'pending', // Will be updated after confirmation
        'donation_notes': description,
        'pickup_required': pickupRequired,
        'pickup_address': pickupAddress,
        'pickup_date': pickupDate?.toIso8601String(),
        'pickup_status': pickupRequired ? 'scheduled' : null,
        'is_recurring': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from('donations')
          .insert(donationData)
          .select()
          .single();
      
      // Create notification for organization
      await _supabase.from('notifications').insert({
        'user_id': organizationId,
        'title': 'New Item Donation',
        'message': 'You have received a new item donation',
        'notification_type': 'donation',
        'related_entity_type': 'donation',
        'related_entity_id': response['id'],
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return Donation.fromJson(response);
    } catch (e) {
      if (e is DonationException) {
        rethrow;
      }
      throw DonationException('Failed to create item donation: $e');
    }
  }
  
  // Get donations by donor
  Future<List<Donation>> getDonationsByDonor(String donorId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('*, organization_profiles(*), campaigns(*)')
          .eq('donor_id', donorId)
          .order('created_at', ascending: false);
      
      return response.map<Donation>(
        (json) => Donation.fromJson(json)
      ).toList();
    } catch (e) {
      throw DonationException('Failed to get donations by donor: $e');
    }
  }
  
  // Get donations by organization
  Future<List<Donation>> getDonationsByOrganization(String organizationId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('*, donor_profiles(*)')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);
      
      return response.map<Donation>(
        (json) => Donation.fromJson(json)
      ).toList();
    } catch (e) {
      throw DonationException('Failed to get donations by organization: $e');
    }
  }
  
  // Get donation by ID
  Future<Donation> getDonationById(String donationId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('*, organization_profiles(*), donor_profiles(*), campaigns(*), donation_tracking(*), donation_updates(*)')
          .eq('id', donationId)
          .single();
      
      return Donation.fromJson(response);
    } catch (e) {
      throw DonationException('Failed to get donation: $e');
    }
  }
  
  // Update donation status
  Future<bool> updateDonationStatus(String donationId, String status) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Get donation to check organization
      final donation = await _supabase
          .from('donations')
          .select('organization_id, donor_id')
          .eq('id', donationId)
          .single();
      
      // Verify user is the organization or an admin
      final isOrganization = donation['organization_id'] == user.id;
      final isAdmin = await _isUserAdmin(user.id);
      
      if (!isOrganization && !isAdmin) {
        throw DonationException('Not authorized to update donation status');
      }
      
      // Update donation status
      await _supabase
          .from('donations')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', donationId);
      
      // Create donation tracking entry
      await _supabase.from('donation_tracking').insert({
        'donation_id': donationId,
        'status': status == 'completed' ? 'received' : status,
        'updated_by': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Create notification for donor
      await _supabase.from('notifications').insert({
        'user_id': donation['donor_id'],
        'title': 'Donation Status Update',
        'message': 'Your donation status has been updated to $status',
        'notification_type': 'donation_status',
        'related_entity_type': 'donation',
        'related_entity_id': donationId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is DonationException) {
        rethrow;
      }
      throw DonationException('Failed to update donation status: $e');
    }
  }
  
  // Add tracking update to donation
  Future<bool> addDonationUpdate(DonationUpdate update) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Get donation to check organization
      final donation = await _supabase
          .from('donations')
          .select('organization_id, donor_id')
          .eq('id', update.donationId)
          .single();
      
      // Verify user is the organization
      if (donation['organization_id'] != user.id) {
        throw DonationException('Not authorized to add donation update');
      }
      
      // Insert donation update
      await _supabase.from('donation_updates').insert({
        'donation_id': update.donationId,
        'title': update.title,
        'description': update.description,
        'media_urls': update.mediaUrls,
        'created_by': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Create notification for donor
      await _supabase.from('notifications').insert({
        'user_id': donation['donor_id'],
        'title': 'Donation Update',
        'message': 'Your donation has a new update: ${update.title}',
        'notification_type': 'donation_update',
        'related_entity_type': 'donation',
        'related_entity_id': update.donationId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is DonationException) {
        rethrow;
      }
      throw DonationException('Failed to add donation update: $e');
    }
  }
  
  // Helper method to check if user is admin
  Future<bool> _isUserAdmin(String userId) async {
    try {
      final adminRoles = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', userId)
          .select();
          
      return adminRoles.any((role) async => 
        role['role_id'] == (await _supabase
            .from('roles')
            .select('id')
            .eq('name', 'admin')
            .single())['id']
      );
    } catch (e) {
      return false;
    }
  }
  
  // Helper method to calculate next donation date for recurring donations
  String _calculateNextDonationDate(String frequency) {
    final now = DateTime.now();
    
    switch (frequency.toLowerCase()) {
      case 'weekly':
        return now.add(const Duration(days: 7)).toIso8601String();
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day).toIso8601String();
      case 'quarterly':
        return DateTime(now.year, now.month + 3, now.day).toIso8601String();
      case 'annually':
        return DateTime(now.year + 1, now.month, now.day).toIso8601String();
      default:
        return DateTime(now.year, now.month + 1, now.day).toIso8601String();
    }
  }
}