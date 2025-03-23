import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/data/repositories/admin_repository.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';
import 'package:donation_platform/data/models/user/user_report.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// Platform statistics
class PlatformStats {
  final int totalUsers;
  final int totalOrganizations;
  final int totalDonations;
  final double totalAmount;
  final int pendingVerifications;
  final int userReports;
  final int activeCampaigns;
  final int newUsersLast30Days;
  
  PlatformStats({
    required this.totalUsers,
    required this.totalOrganizations,
    required this.totalDonations,
    required this.totalAmount,
    required this.pendingVerifications,
    required this.userReports,
    required this.activeCampaigns,
    required this.newUsersLast30Days,
  });
  
  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalUsers: json['total_users'] ?? 0,
      totalOrganizations: json['total_organizations'] ?? 0,
      totalDonations: json['total_donations'] ?? 0,
      totalAmount: json['total_amount'] ?? 0.0,
      pendingVerifications: json['pending_verifications'] ?? 0,
      userReports: json['user_reports'] ?? 0,
      activeCampaigns: json['active_campaigns'] ?? 0,
      newUsersLast30Days: json['new_users_last_30_days'] ?? 0,
    );
  }
}

final platformStatsProvider = FutureProvider<PlatformStats>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final stats = await repository.getPlatformStatistics();
  return PlatformStats.fromJson(stats);
});

// Pending organization verifications
class PendingVerification {
  final String id;
  final String organizationId;
  final String organizationName;
  final DateTime submittedAt;
  final String verificationStage;
  
  PendingVerification({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.submittedAt,
    required this.verificationStage,
  });
}

final pendingVerificationsProvider = FutureProvider<List<PendingVerification>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final verifications = await repository.getPendingVerifications();
  
  return verifications.map((verification) => PendingVerification(
    id: verification.id,
    organizationId: verification.organizationId,
    organizationName: verification.contactPersonName, // Using contact person name as placeholder
    submittedAt: verification.submittedAt,
    verificationStage: verification.verificationStage ?? 'pending',
  )).toList();
});

// Pending user reports
final pendingReportsProvider = FutureProvider<List<UserReport>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getPendingReports();
});

// Organizations list
final organizationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getAllOrganizations();
});

// Users list
final usersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getAllUsers();
});

// Admin state for managing approvals and actions
class AdminState {
  final bool isLoading;
  final String? errorMessage;
  
  AdminState({
    this.isLoading = false,
    this.errorMessage,
  });
  
  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Admin notifier for actions
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;
  
  AdminNotifier(this._repository) : super(AdminState());
  
  // Approve organization
  Future<bool> approveOrganization(String organizationId, String adminId, String? notes) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.approveOrganization(organizationId, adminId, notes);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to approve organization: ${e.toString()}',
      );
      return false;
    }
  }
  
  // Reject organization
  Future<bool> rejectOrganization(String organizationId, String adminId, String reason) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.rejectOrganization(organizationId, adminId, reason);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reject organization: ${e.toString()}',
      );
      return false;
    }
  }
  
  // Blacklist a user
  Future<bool> blacklistUser(String userId, String reason, String adminId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.blacklistUser(userId, reason, adminId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to blacklist user: ${e.toString()}',
      );
      return false;
    }
  }
  
  // Handle user report
  Future<bool> handleReport(String reportId, String status, String adminId, String? notes) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.updateReportStatus(reportId, status, adminId, notes);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to handle report: ${e.toString()}',
      );
      return false;
    }
  }
}

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminNotifier(repository);
});