import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';
import 'package:donation_platform/data/models/user/user_report.dart';
import 'package:donation_platform/core/utils/exceptions.dart';

class AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get platform statistics
  Future<Map<String, dynamic>> getPlatformStatistics() async {
    try {
      // Use the materialized view for dashboard stats for better performance
      final response =
          await _supabase.from('mv_admin_dashboard_stats').select().single();

      return response;
    } catch (e) {
      throw DatabaseException('Failed to get platform statistics: $e');
    }
  }

  // Get pending organization verifications
  Future<List<OrganizationVerification>> getPendingVerifications() async {
    try {
      final response = await _supabase
          .from('organization_verifications')
          .select('*, organization_profiles!inner(organization_name)')
          .in_('verification_status', ['pending', 'in_review']).order(
              'submitted_at',
              ascending: false);

      return response.map<OrganizationVerification>((data) {
        // Merge organization name into verification data
        final verificationData = {
          ...data,
          'contact_person_name': data['organization_profiles']
              ['organization_name'],
        };

        return OrganizationVerification.fromJson(verificationData);
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get pending verifications: $e');
    }
  }

  // Get pending user reports
  Future<List<UserReport>> getPendingReports() async {
    try {
      final response = await _supabase.from('user_reports').select('''
            *,
            reporter:reporter_id(full_name, email),
            reported:reported_id(full_name, email)
          ''').in_('status', [
        'pending',
        'investigating'
      ]).order('created_at', ascending: false);

      return response.map<UserReport>((data) {
        return UserReport(
          id: data['id'],
          reporterId: data['reporter_id'],
          reportedId: data['reported_id'],
          reportType: data['report_type'],
          reportReason: data['report_reason'],
          reportEvidence: data['report_evidence'],
          status: data['status'],
          adminNotes: data['admin_notes'],
          resolvedBy: data['resolved_by'],
          resolvedAt: data['resolved_at'] != null
              ? DateTime.parse(data['resolved_at'])
              : null,
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get pending reports: $e');
    }
  }

  // Get all organizations
  Future<List<Map<String, dynamic>>> getAllOrganizations() async {
    try {
      // Use the view for optimized query
      final response = await _supabase
          .from('vw_organizations')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DatabaseException('Failed to get organizations: $e');
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, user_verifications(*)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DatabaseException('Failed to get users: $e');
    }
  }

  // Approve organization
  Future<void> approveOrganization(
    String organizationId,
    String adminId,
    String? notes,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Start a transaction
      await _supabase.rpc('begin_transaction');

      try {
        // Update organization verification
        await _supabase.from('organization_verifications').update({
          'verification_status': 'approved',
          'verification_stage': 'completed',
          'verification_notes': notes,
          'verified_by': adminId,
          'verified_at': now,
          'updated_at': now,
        }).eq('organization_id', organizationId);

        // Update organization profile
        await _supabase.from('organization_profiles').update({
          'verification_status': 'approved',
          'updated_at': now,
        }).eq('user_id', organizationId);

        // Create notification for organization
        await _supabase.from('notifications').insert({
          'user_id': organizationId,
          'title': 'Organization Verified',
          'message':
              'Congratulations! Your organization has been verified and approved.',
          'notification_type': 'organization_verification',
          'related_entity_type': 'organization',
          'related_entity_id': organizationId,
          'created_at': now,
        });

        // Log admin action
        await _supabase.from('admin_actions').insert({
          'admin_id': adminId,
          'action_type': 'approve_organization',
          'entity_type': 'organization',
          'entity_id': organizationId,
          'details': {
            'notes': notes,
            'action': 'approve',
          },
          'created_at': now,
        });

        // Commit transaction
        await _supabase.rpc('commit_transaction');
      } catch (e) {
        // Rollback transaction on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw DatabaseException('Failed to approve organization: $e');
    }
  }

  // Reject organization
  Future<void> rejectOrganization(
    String organizationId,
    String adminId,
    String reason,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Start a transaction
      await _supabase.rpc('begin_transaction');

      try {
        // Update organization verification
        await _supabase.from('organization_verifications').update({
          'verification_status': 'rejected',
          'verification_stage': 'rejected',
          'verification_notes': 'Rejected: $reason',
          'rejection_reason': reason,
          'verified_by': adminId,
          'verified_at': now,
          'updated_at': now,
        }).eq('organization_id', organizationId);

        // Update organization profile
        await _supabase.from('organization_profiles').update({
          'verification_status': 'rejected',
          'updated_at': now,
        }).eq('user_id', organizationId);

        // Create notification for organization
        await _supabase.from('notifications').insert({
          'user_id': organizationId,
          'title': 'Verification Rejected',
          'message':
              'Your organization verification has been rejected. Reason: $reason',
          'notification_type': 'organization_verification',
          'related_entity_type': 'organization',
          'related_entity_id': organizationId,
          'created_at': now,
        });

        // Log admin action
        await _supabase.from('admin_actions').insert({
          'admin_id': adminId,
          'action_type': 'reject_organization',
          'entity_type': 'organization',
          'entity_id': organizationId,
          'details': {
            'reason': reason,
            'action': 'reject',
          },
          'created_at': now,
        });

        // Commit transaction
        await _supabase.rpc('commit_transaction');
      } catch (e) {
        // Rollback transaction on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw DatabaseException('Failed to reject organization: $e');
    }
  }

  // Blacklist user
  Future<void> blacklistUser(
    String userId,
    String reason,
    String adminId,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Start a transaction
      await _supabase.rpc('begin_transaction');

      try {
        // Update user verification
        await _supabase.from('user_verifications').update({
          'is_blacklisted': true,
          'blacklisted_reason': reason,
          'blacklisted_at': now,
          'blacklisted_by': adminId,
          'updated_at': now,
        }).eq('user_id', userId);

        // Create notification for user
        await _supabase.from('notifications').insert({
          'user_id': userId,
          'title': 'Account Suspended',
          'message': 'Your account has been suspended. Reason: $reason',
          'notification_type': 'account_suspension',
          'related_entity_type': 'user',
          'related_entity_id': userId,
          'created_at': now,
        });

        // Log admin action
        await _supabase.from('admin_actions').insert({
          'admin_id': adminId,
          'action_type': 'blacklist_user',
          'entity_type': 'user',
          'entity_id': userId,
          'details': {
            'reason': reason,
            'action': 'blacklist',
          },
          'created_at': now,
        });

        // Commit transaction
        await _supabase.rpc('commit_transaction');
      } catch (e) {
        // Rollback transaction on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw DatabaseException('Failed to blacklist user: $e');
    }
  }

  // Handle report
  Future<void> updateReportStatus(
    String reportId,
    String status, // 'investigating', 'resolved', 'rejected'
    String adminId,
    String? notes,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Update report status
      await _supabase.from('user_reports').update({
        'status': status,
        'admin_notes': notes,
        'resolved_by': status == 'investigating' ? null : adminId,
        'resolved_at': status == 'investigating' ? null : now,
        'updated_at': now,
      }).eq('id', reportId);

      // Log admin action
      await _supabase.from('admin_actions').insert({
        'admin_id': adminId,
        'action_type': 'update_report_status',
        'entity_type': 'user_report',
        'entity_id': reportId,
        'details': {
          'status': status,
          'notes': notes,
          'action': 'update_status',
        },
        'created_at': now,
      });

      // Get report details to notify users
      final report = await _supabase
          .from('user_reports')
          .select('reporter_id, reported_id')
          .eq('id', reportId)
          .single();

      // Create notification for reporter
      await _supabase.from('notifications').insert({
        'user_id': report['reporter_id'],
        'title': 'Report Status Updated',
        'message': 'Your report has been ${status.toLowerCase()}.',
        'notification_type': 'report_update',
        'related_entity_type': 'user_report',
        'related_entity_id': reportId,
        'created_at': now,
      });
    } catch (e) {
      throw DatabaseException('Failed to update report status: $e');
    }
  }

  // Get donation statistics by category
  Future<List<Map<String, dynamic>>> getDonationStatisticsByCategory() async {
    try {
      final response = await _supabase.rpc(
        'get_donation_statistics_by_category',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DatabaseException('Failed to get donation statistics: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final response = await _supabase.rpc(
        'get_user_statistics',
      );

      return response;
    } catch (e) {
      throw DatabaseException('Failed to get user statistics: $e');
    }
  }
}
