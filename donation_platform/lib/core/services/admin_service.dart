import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';
import 'package:donation_platform/data/models/user/user_report.dart';

class AdminException implements Exception {
  final String message;
  AdminException(this.message);
  
  @override
  String toString() => 'AdminException: $message';
}

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Blacklist a donor
  Future<bool> blacklistDonor(String donorId, String reason, String adminId) async {
    try {
      // Get current admin user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin not logged in');
      }
      
      // Verify admin has correct permissions
      final adminRoles = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', user.id)
          .select();
          
      final isAdmin = adminRoles.any((role) => 
        role['role_id'] == (await _supabase
            .from('roles')
            .select('id')
            .eq('name', 'admin')
            .single())['id']
      );
      
      if (!isAdmin) {
        throw AdminException('Insufficient permissions to blacklist users');
      }
      
      // Update user verification to blacklisted
      await _supabase
          .from('user_verifications')
          .update({
            'is_blacklisted': true,
            'blacklisted_reason': reason,
            'blacklisted_at': DateTime.now().toIso8601String(),
            'blacklisted_by': adminId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', donorId);
      
      // Deactivate user account
      await _supabase
          .from('users')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', donorId);
      
      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': adminId,
        'action_type': 'blacklist_donor',
        'entity_type': 'user',
        'entity_id': donorId,
        'details': {
          'reason': reason,
        },
        'ip_address': null, // In a real app, capture admin's IP
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is AdminException) {
        rethrow;
      }
      throw AdminException('Failed to blacklist donor: $e');
    }
  }
  
  // Approve organization
  Future<bool> approveOrganization(String organizationId, String adminId, String? notes) async {
    try {
      // Get current admin user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin not logged in');
      }
      
      // Verify admin has correct permissions
      final adminRoles = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', user.id)
          .select();
          
      final isAdmin = adminRoles.any((role) => 
        role['role_id'] == (await _supabase
            .from('roles')
            .select('id')
            .eq('name', 'admin')
            .single())['id']
      );
      
      if (!isAdmin) {
        throw AdminException('Insufficient permissions to approve organizations');
      }
      
      // Update organization verification status
      await _supabase
          .from('organization_verifications')
          .update({
            'verification_status': 'approved',
            'verification_stage': 'completed',
            'verification_notes': notes,
            'verified_by': adminId,
            'verified_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('organization_id', organizationId);
      
      // Update organization profile status
      await _supabase
          .from('organization_profiles')
          .update({
            'verification_status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', organizationId);
      
      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': adminId,
        'action_type': 'approve_organization',
        'entity_type': 'organization',
        'entity_id': organizationId,
        'details': {
          'notes': notes,
        },
        'ip_address': null, // In a real app, capture admin's IP
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Send notification to organization
      await _supabase.from('notifications').insert({
        'user_id': organizationId,
        'title': 'Organization Approved',
        'message': 'Congratulations! Your organization has been verified and approved.',
        'notification_type': 'organization_verification',
        'related_entity_type': 'organization',
        'related_entity_id': organizationId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is AdminException) {
        rethrow;
      }
      throw AdminException('Failed to approve organization: $e');
    }
  }
  
  // Reject organization
  Future<bool> rejectOrganization(String organizationId, String adminId, String reason) async {
    try {
      // Get current admin user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin not logged in');
      }
      
      // Verify admin has correct permissions
      final adminRoles = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', user.id)
          .select();
          
      final isAdmin = adminRoles.any((role) => 
        role['role_id'] == (await _supabase
            .from('roles')
            .select('id')
            .eq('name', 'admin')
            .single())['id']
      );
      
      if (!isAdmin) {
        throw AdminException('Insufficient permissions to reject organizations');
      }
      
      // Update organization verification status
      await _supabase
          .from('organization_verifications')
          .update({
            'verification_status': 'rejected',
            'rejection_reason': reason,
            'verified_by': adminId,
            'verified_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('organization_id', organizationId);
      
      // Update organization profile status
      await _supabase
          .from('organization_profiles')
          .update({
            'verification_status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', organizationId);
      
      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': adminId,
        'action_type': 'reject_organization',
        'entity_type': 'organization',
        'entity_id': organizationId,
        'details': {
          'reason': reason,
        },
        'ip_address': null, // In a real app, capture admin's IP
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Send notification to organization
      await _supabase.from('notifications').insert({
        'user_id': organizationId,
        'title': 'Organization Verification Rejected',
        'message': 'Your organization verification was rejected. Reason: $reason',
        'notification_type': 'organization_verification',
        'related_entity_type': 'organization',
        'related_entity_id': organizationId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is AdminException) {
        rethrow;
      }
      throw AdminException('Failed to reject organization: $e');
    }
  }
  
  // Get pending organization verifications
  Future<List<OrganizationVerification>> getPendingOrganizationVerifications() async {
    try {
      final response = await _supabase
          .from('organization_verifications')
          .select('*, organization_profiles!inner(*)')
          .eq('verification_status', 'pending')
          .order('submitted_at', ascending: false);
      
      return response.map<OrganizationVerification>(
        (json) => OrganizationVerification.fromJson(json)
      ).toList();
    } catch (e) {
      throw AdminException('Failed to get pending organization verifications: $e');
    }
  }
  
  // Get user reports
  Future<List<UserReport>> getPendingUserReports() async {
    try {
      final response = await _supabase
          .from('user_reports')
          .select('*')
          .in_('status', ['pending', 'investigating'])
          .order('created_at', ascending: false);
      
      return response.map<UserReport>(
        (json) => UserReport.fromJson(json)
      ).toList();
    } catch (e) {
      throw AdminException('Failed to get pending user reports: $e');
    }
  }
  
  // Update report status (admin only)
  Future<bool> updateReportStatus(String reportId, String status, String adminId, String? notes) async {
    try {
      // Get current admin user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin not logged in');
      }
      
      // Verify admin has correct permissions
      final adminRoles = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', user.id)
          .select();
          
      final isAdmin = adminRoles.any((role) => 
        role['role_id'] == (await _supabase
            .from('roles')
            .select('id')
            .eq('name', 'admin')
            .single())['id']
      );
      
      if (!isAdmin) {
        throw AdminException('Insufficient permissions to update reports');
      }
      
      // Update report status
      await _supabase
          .from('user_reports')
          .update({
            'status': status,
            'admin_notes': notes,
            'resolved_by': adminId,
            'resolved_at': status == 'resolved' || status == 'rejected' 
              ? DateTime.now().toIso8601String() 
              : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);
      
      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': adminId,
        'action_type': 'update_report_status',
        'entity_type': 'user_report',
        'entity_id': reportId,
        'details': {
          'status': status,
          'notes': notes,
        },
        'ip_address': null, // In a real app, capture admin's IP
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      if (e is AdminException) {
        rethrow;
      }
      throw AdminException('Failed to update report status: $e');
    }
  }
  
  // Get platform statistics
  Future<Map<String, dynamic>> getPlatformStatistics() async {
    try {
      // Get stats from materialized view
      final stats = await _supabase
          .from('mv_admin_dashboard_stats')
          .select()
          .single();
      
      return stats;
    } catch (e) {
      throw AdminException('Failed to get platform statistics: $e');
    }
  }
  
  // Get donation statistics by category
  Future<List<Map<String, dynamic>>> getDonationStatisticsByCategory() async {
    try {
      final response = await _supabase.rpc(
        'get_donation_stats_by_category',
        params: {
          'start_date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
          'end_date': DateTime.now().toIso8601String(),
        },
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AdminException('Failed to get donation statistics by category: $e');
    }
  }
  
  // Feature or unfeature an organization
  Future<bool> toggleOrganizationFeatured(String organizationId, bool featured) async {
    try {
      // Get current admin user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin not logged in');
      }
      
      // Update organization profile
      await _supabase
          .from('organization_profiles')
          .update({
            'featured': featured,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', organizationId);
      
      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': user.id,
        'action_type': featured ? 'feature_organization' : 'unfeature_organization',
        'entity_type': 'organization',
        'entity_id': organizationId,
        'details': {
          'featured': featured,
        },
        'ip_address': null, // In a real app, capture admin's IP
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      throw AdminException('Failed to toggle organization featured status: $e');
    }
  }
}