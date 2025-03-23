import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/data/models/donor/donor_profile.dart';
import 'package:donation_platform/data/repositories/donor_repository.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return DonorRepository();
});

// Provider for fetching donor profile
final donorProfileProvider = FutureProvider.family<DonorProfile?, String>((ref, userId) async {
  if (userId.isEmpty) {
    return null;
  }
  
  final repository = ref.watch(donorRepositoryProvider);
  return await repository.getDonorProfileById(userId);
});

// Donor state for updating profile
class DonorProfileState {
  final bool isLoading;
  final String? errorMessage;
  
  DonorProfileState({
    this.isLoading = false,
    this.errorMessage,
  });
  
  DonorProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return DonorProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Notifier for updating donor profile
class DonorProfileNotifier extends StateNotifier<DonorProfileState> {
  final DonorRepository _repository;
  
  DonorProfileNotifier(this._repository) : super(DonorProfileState());
  
  Future<bool> updateDonorProfile(DonorProfile profile) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.updateDonorProfile(profile);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      );
      return false;
    }
  }
  
  Future<bool> updateNotificationPreferences(
    String userId, 
    Map<String, dynamic> preferences,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.updateNotificationPreferences(userId, preferences);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update notification preferences: ${e.toString()}',
      );
      return false;
    }
  }
  
  Future<bool> updateAnonymousPreference(String userId, bool isAnonymous) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.updateAnonymousPreference(userId, isAnonymous);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update anonymous preference: ${e.toString()}',
      );
      return false;
    }
  }
}

final donorProfileNotifierProvider = StateNotifierProvider<DonorProfileNotifier, DonorProfileState>((ref) {
  final repository = ref.watch(donorRepositoryProvider);
  return DonorProfileNotifier(repository);
});

// Provider for donor statistics
final donorStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  if (userId.isEmpty) {
    return {};
  }
  
  final repository = ref.watch(donorRepositoryProvider);
  return await repository.getDonorStatistics(userId);
});

// Provider for donor's preferred categories
final donorPreferredCategoriesProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  if (userId.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(donorRepositoryProvider);
  return await repository.getDonorPreferredCategories(userId);
});