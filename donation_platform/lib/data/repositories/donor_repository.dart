import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/donor/donor_profile.dart';
import 'package:donation_platform/core/utils/exceptions.dart';
import 'package:uuid/uuid.dart';

class DonorRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get donor profile by user ID
  Future<DonorProfile?> getDonorProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('donor_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return DonorProfile.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to get donor profile: $e');
    }
  }
  
  // Create donor profile
  Future<DonorProfile> createDonorProfile(DonorProfile profile) async {
    try {
      await _supabase
          .from('donor_profiles')
          .insert({
            'user_id': profile.userId,
            'date_of_birth': profile.dateOfBirth?.toIso8601String(),
            'gender': profile.gender,
            'address': profile.address,
            'city': profile.city,
            'state': profile.state,
            'country': profile.country,
            'postal_code': profile.postalCode,
            'preferred_categories': profile.preferredCategories,
            'is_anonymous_by_default': profile.isAnonymousByDefault,
            'notification_preferences': profile.notificationPreferences,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      return profile;
    } catch (e) {
      throw DatabaseException('Failed to create donor profile: $e');
    }
  }
  
  // Update donor profile
  Future<DonorProfile> updateDonorProfile(DonorProfile profile) async {
    try {
      await _supabase
          .from('donor_profiles')
          .update({
            'date_of_birth': profile.dateOfBirth?.toIso8601String(),
            'gender': profile.gender,
            'address': profile.address,
            'city': profile.city,
            'state': profile.state,
            'country': profile.country,
            'postal_code': profile.postalCode,
            'preferred_categories': profile.preferredCategories,
            'is_anonymous_by_default': profile.isAnonymousByDefault,
            'notification_preferences': profile.notificationPreferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', profile.userId);
      
      return profile;
    } catch (e) {
      throw DatabaseException('Failed to update donor profile: $e');
    }
  }
  
  // Update notification preferences
  Future<bool> updateNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _supabase
          .from('donor_profiles')
          .update({
            'notification_preferences': preferences,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      return true;
    } catch (e) {
      throw DatabaseException('Failed to update notification preferences: $e');
    }
  }
  
  // Update anonymous preference
  Future<bool> updateAnonymousPreference(String userId, bool isAnonymous) async {
    try {
      await _supabase
          .from('donor_profiles')
          .update({
            'is_anonymous_by_default': isAnonymous,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      return true;
    } catch (e) {
      throw DatabaseException('Failed to update anonymous preference: $e');
    }
  }
  
  // Get donor preferred categories
  Future<List<String>> getDonorPreferredCategories(String userId) async {
    try {
      final response = await _supabase
          .from('donor_profiles')
          .select('preferred_categories')
          .eq('user_id', userId)
          .single();
      
      if (response['preferred_categories'] == null) {
        return [];
      }
      
      return List<String>.from(response['preferred_categories']);
    } catch (e) {
      throw DatabaseException('Failed to get preferred categories: $e');
    }
  }
  
  // Update donor preferred categories
  Future<bool> updateDonorPreferredCategories(
    String userId,
    List<String> categories,
  ) async {
    try {
      await _supabase
          .from('donor_profiles')
          .update({
            'preferred_categories': categories,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      return true;
    } catch (e) {
      throw DatabaseException('Failed to update preferred categories: $e');
    }
  }
  
  // Get donor statistics
  Future<Map<String, dynamic>> getDonorStatistics(String userId) async {
    try {
      // Get donor activity from the view
      final response = await _supabase
          .from('vw_donor_activity')
          .select()
          .eq('donor_id', userId)
          .single();
      
      return {
        'total_donations': response['total_donations'] ?? 0,
        'total_amount_donated': response['total_amount_donated'] ?? 0.0,
        'organizations_supported': response['organizations_supported'] ?? 0,
        'activity_status': response['activity_status'] ?? 'inactive',
        'recurring_donations_count': response['recurring_donations_count'] ?? 0,
      };
    } catch (e) {
      throw DatabaseException('Failed to get donor statistics: $e');
    }
  }
  
  // Rate organization
  Future<bool> rateOrganization(
    String donorId,
    String organizationId,
    int rating,
    String? title,
    String? review,
    bool isAnonymous,
  ) async {
    try {
      // Generate unique ID
      final uuid = const Uuid().v4();
      
      await _supabase
          .from('organization_reviews')
          .insert({
            'id': uuid,
            'organization_id': organizationId,
            'donor_id': donorId,
            'rating': rating,
            'title': title,
            'review': review,
            'is_anonymous': isAnonymous,
            'is_approved': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      return true;
    } catch (e) {
      throw DatabaseException('Failed to rate organization: $e');
    }
  }
}