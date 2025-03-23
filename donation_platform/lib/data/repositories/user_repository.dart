import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/user/user.dart';
import 'package:donation_platform/core/utils/exceptions.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      // Get user data first
      final userData =
          await _supabase.from('users').select().eq('id', userId).single();

      // Then get verification data separately
      final verificationData = await _supabase
          .from('user_verifications')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (verificationData == null) {
        // If verification record doesn't exist, create it
        final newVerification = {
          'user_id': userId,
          'cnic_verified': false,
          'phone_verified': false,
          'is_blacklisted': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('user_verifications').insert(newVerification);

        // Use the new verification data
        final transformedResponse = {
          ...userData,
          'verification': newVerification,
        };

        return AppUser.fromJson(Map<String, dynamic>.from(transformedResponse));
      }

      // Combine user and verification data
      final transformedResponse = {
        ...userData,
        'verification': verificationData,
      };

      return AppUser.fromJson(Map<String, dynamic>.from(transformedResponse));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows returned
        return null;
      }
      throw DatabaseException('Failed to get user: ${e.message}');
    } catch (e) {
      throw DatabaseException('Failed to get user: $e');
    }
  }

  // Create new user
  Future<void> createUser(AppUser user, {required String passwordHash}) async {
    try {
      // Insert user data
      await _supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'password_hash': passwordHash, // Now we're adding the password hash
        'phone': user.phone,
        'full_name': user.fullName,
        'user_type': user.userType,
        'is_verified': user.isVerified,
        'is_active': user.isActive,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      });

      // Insert user verification data
      await _supabase.from('user_verifications').insert({
        'user_id': user.id,
        'cnic_verified': user.verification.cnicVerified,
        'phone_verified': user.verification.phoneVerified,
        'is_blacklisted': user.verification.isBlacklisted,
        'created_at': user.verification.createdAt.toIso8601String(),
        'updated_at': user.verification.updatedAt.toIso8601String(),
      });
    } catch (e) {
      throw DatabaseException('Failed to create user: $e');
    }
  }

  // Update user data
  Future<void> updateUser(AppUser user) async {
    try {
      // Update user data
      await _supabase.from('users').update({
        'email': user.email,
        'phone': user.phone,
        'full_name': user.fullName,
        'is_verified': user.isVerified,
        'is_active': user.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }

  // Update user password
  Future<void> updateUserPassword(String userId, String passwordHash) async {
    try {
      await _supabase.from('users').update({
        'password_hash': passwordHash,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw DatabaseException('Failed to update user password: $e');
    }
  }

  // Update user last login
  Future<void> updateUserLastLogin(String userId) async {
    try {
      await _supabase.from('users').update({
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw DatabaseException('Failed to update last login: $e');
    }
  }

  // Mark user as verified (after phone/email verification)
  Future<AppUser?> markUserAsVerified(String userId) async {
    try {
      await _supabase.from('users').update({
        'is_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return await getUserById(userId);
    } catch (e) {
      throw DatabaseException('Failed to verify user: $e');
    }
  }

  // Update user profile image
  Future<String?> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _supabase.from('users').update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return imageUrl;
    } catch (e) {
      throw DatabaseException('Failed to update profile image: $e');
    }
  }

  // Get all users (admin only)
  Future<List<AppUser>> getAllUsers({
    int limit = 20,
    int offset = 0,
    String? userType,
    bool? isVerified,
    bool? isActive,
  }) async {
    try {
      List<String> filters = [];
      if (userType != null) {
        filters.add('user_type.eq.$userType');
      }
      if (isVerified != null) {
        filters.add('is_verified.eq.$isVerified');
      }
      if (isActive != null) {
        filters.add('is_active.eq.$isActive');
      }

// Apply all operations in a single chain
      final response = await _supabase
          .from('users')
          .select('*, user_verifications(*)')
          .or(filters.join(','))
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Transform response to include verification data
      return (response as List).map((userData) {
        return AppUser.fromJson({
          ...userData,
          'verification': userData['user_verifications'],
        });
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get users: $e');
    }
  }

  // Search users
  Future<List<AppUser>> searchUsers(String searchTerm,
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, user_verifications(*)')
          .or('full_name.ilike.%$searchTerm%,email.ilike.%$searchTerm%,phone.ilike.%$searchTerm%')
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return (response as List).map((userData) {
        return AppUser.fromJson({
          ...userData,
          'verification': userData['user_verifications'],
        });
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to search users: $e');
    }
  }

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      throw DatabaseException('Failed to deactivate user: $e');
    }
  }

  // Reactivate user
  Future<bool> reactivateUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      throw DatabaseException('Failed to reactivate user: $e');
    }
  }

  // Blacklist user (admin only)
  Future<bool> blacklistUser(
      String userId, String reason, String adminId) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Update verification record
      await _supabase.from('user_verifications').update({
        'is_blacklisted': true,
        'blacklisted_reason': reason,
        'blacklisted_at': now,
        'blacklisted_by': adminId,
        'updated_at': now,
      }).eq('user_id', userId);

      return true;
    } catch (e) {
      throw DatabaseException('Failed to blacklist user: $e');
    }
  }

  // Remove user from blacklist (admin only)
  Future<bool> removeFromBlacklist(String userId) async {
    try {
      await _supabase.from('user_verifications').update({
        'is_blacklisted': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      return true;
    } catch (e) {
      throw DatabaseException('Failed to remove user from blacklist: $e');
    }
  }
}
