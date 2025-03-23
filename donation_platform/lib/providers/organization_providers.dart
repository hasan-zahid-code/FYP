import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/data/models/organization/organization.dart';
import 'package:donation_platform/data/repositories/organization_repository.dart';
import 'package:donation_platform/data/models/common/category.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

// Provider for categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.getAllCategories();
});

// Provider for fetching nearby organizations
final nearbyOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.getNearbyOrganizations();
});

// Provider for fetching a specific organization
final organizationProvider = FutureProvider.family<Organization?, String>((ref, organizationId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.getOrganizationById(organizationId);
});

// Provider for featured organizations
final featuredOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.getFeaturedOrganizations();
});

// Provider for organizations by category
final organizationsByCategoryProvider = FutureProvider.family<List<Organization>, String>((ref, categoryId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.getOrganizationsByCategory(categoryId);
});

// Provider for searching organizations
final searchOrganizationsProvider = FutureProvider.family<List<Organization>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(organizationRepositoryProvider);
  return await repository.searchOrganizations(query);
});

// Organization state class for managing organization verification
class OrganizationState {
  final bool isLoading;
  final String? errorMessage;
  
  OrganizationState({
    this.isLoading = false,
    this.errorMessage,
  });
  
  OrganizationState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrganizationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Notifier for organization verification
class OrganizationVerificationNotifier extends StateNotifier<OrganizationState> {
  final OrganizationRepository _repository;
  
  OrganizationVerificationNotifier(this._repository) : super(OrganizationState());
  
  Future<bool> submitVerification(Map<String, dynamic> verificationData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.submitVerification(verificationData);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit verification: ${e.toString()}',
      );
      return false;
    }
  }
}

final organizationVerificationProvider = StateNotifierProvider<OrganizationVerificationNotifier, OrganizationState>((ref) {
  final repository = ref.watch(organizationRepositoryProvider);
  return OrganizationVerificationNotifier(repository);
});