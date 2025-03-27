import 'package:donation_platform/data/models/donation/donation_update.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:donation_platform/data/models/donation/donation_category.dart';
import 'package:donation_platform/core/utils/exceptions.dart';
import 'package:uuid/uuid.dart';

class DonationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get donation categories
  Future<List<DonationCategory>> getDonationCategories() async {
    try {
      final response = await _supabase
          .from('donation_categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((data) => DonationCategory.fromJson(data))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get donation categories: $e');
    }
  }

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
      // Get donation category ID for monetary donations
      final categoryResponse = await _supabase
          .from('donation_categories')
          .select('id')
          .eq('name', 'Money')
          .single();

      final donationCategoryId = categoryResponse['id'];

      // Generate unique ID
      final uuid = const Uuid().v4();

      // Create donation
      final donationData = {
        'id': uuid,
        'donor_id': donorId,
        'organization_id': organizationId,
        'campaign_id': campaignId,
        'donation_category_id': donationCategoryId,
        'amount': amount,
        'currency': currency,
        'is_anonymous': isAnonymous,
        'status': 'pending',
        'payment_method': paymentMethod,
        'donation_notes': description,
        'is_recurring': isRecurring,
        'recurring_frequency': recurringFrequency,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('donations').insert(donationData);

      // Return the created donation
      return await getDonationById(uuid);
    } catch (e) {
      throw DatabaseException('Failed to create donation: $e');
    }
  }

  // Create non-monetary donation (food, clothes, etc.)
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
      // Generate unique ID
      final uuid = const Uuid().v4();

      // Create donation
      final donationData = {
        'id': uuid,
        'donor_id': donorId,
        'organization_id': organizationId,
        'campaign_id': campaignId,
        'donation_category_id': donationCategoryId,
        'donation_items': items,
        'quantity': quantity,
        'estimated_value': estimatedValue,
        'is_anonymous': isAnonymous,
        'status': 'pending',
        'donation_notes': description,
        'pickup_required': pickupRequired,
        'pickup_address': pickupAddress,
        'pickup_date': pickupDate?.toIso8601String(),
        'pickup_status': pickupRequired ? 'scheduled' : null,
        'is_recurring': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('donations').insert(donationData);

      // Return the created donation
      return await getDonationById(uuid);
    } catch (e) {
      throw DatabaseException('Failed to create donation: $e');
    }
  }

  // Get donations by donor
  Future<List<Donation>> getDonationsByDonor(String donorId) async {
    try {
      final response = await _supabase.from('donations').select('''
            *,
            donation_tracking:donation_tracking(*)
          ''').eq('donor_id', donorId).order('created_at', ascending: false);

      return _processDonations(response);
    } catch (e) {
      throw DatabaseException('Failed to get donations: $e');
    }
  }

  // Get donations by organization
  Future<List<Donation>> getDonationsByOrganization(
      String organizationId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donation_tracking:donation_tracking(*)
          ''')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      return _processDonations(response);
    } catch (e) {
      throw DatabaseException('Failed to get donations: $e');
    }
  }

  // Get donations by campaign
  Future<List<Donation>> getDonationsByCampaign(String campaignId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donation_tracking:donation_tracking(*)
          ''')
          .eq('campaign_id', campaignId)
          .order('created_at', ascending: false);

      return _processDonations(response);
    } catch (e) {
      throw DatabaseException('Failed to get donations: $e');
    }
  }

  // Get donation by ID
  Future<Donation> getDonationById(String donationId) async {
    try {
      final response = await _supabase.from('donations').select('''
            *,
            donation_tracking:donation_tracking(*)
          ''').eq('id', donationId).single();

      // Transform to include tracking and updates if available
      return Donation.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to get donation: $e');
    }
  }

  // Update donation status
  Future<bool> updateDonationStatus(String donationId, String status) async {
    try {
      await _supabase.from('donations').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', donationId);

      return true;
    } catch (e) {
      throw DatabaseException('Failed to update donation status: $e');
    }
  }

  // Add tracking update to donation
  Future<bool> addDonationUpdate(DonationUpdate update) async {
    try {
      // Check if tracking exists
      final trackingResponse = await _supabase
          .from('donation_tracking')
          .select('id')
          .eq('donation_id', update.donationId)
          .maybeSingle();

      String trackingId;

      if (trackingResponse == null) {
        // Create tracking record
        final uuid = const Uuid().v4();

        await _supabase.from('donation_tracking').insert({
          'id': uuid,
          'donation_id': update.donationId,
          'status': 'received',
          'updated_by': update.createdBy,
          'created_at': DateTime.now().toIso8601String(),
        });

        trackingId = uuid;
      } else {
        trackingId = trackingResponse['id'];
      }

      // Create update
      final uuid = const Uuid().v4();
      await _supabase.from('donation_updates').insert({
        'id': uuid,
        'donation_id': update.donationId,
        'title': update.title,
        'description': update.description,
        'media_urls': update.mediaUrls,
        'created_by': update.createdBy,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw DatabaseException('Failed to add donation update: $e');
    }
  }

  // Get donation statistics for a donor
  Future<Map<String, dynamic>> getDonorDonationStatistics(
      String donorId) async {
    try {
      // Get total monetary donations
      final monetaryResponse = await _supabase
          .rpc('get_donor_monetary_stats', params: {'donor_user_id': donorId});

      // Get donation counts by category
      final categoryResponse = await _supabase
          .rpc('get_donor_category_stats', params: {'donor_user_id': donorId});

      return {
        'monetary_stats': monetaryResponse,
        'category_stats': categoryResponse,
      };
    } catch (e) {
      throw DatabaseException('Failed to get donation statistics: $e');
    }
  }

  // Helper method to process donations response
  List<Donation> _processDonations(List<dynamic> response) {
    return response.map((data) {
      // Process tracking data if available
      if (data['donation_tracking'] != null &&
          data['donation_tracking'].isNotEmpty) {
        data['tracking'] = data['donation_tracking'][0];
      }
      return Donation.fromJson(data);
    }).toList();
  }
}
