import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:donation_platform/data/repositories/donation_repository.dart';
import 'package:donation_platform/data/models/donation/donation_category.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository();
});

// Provider for donation categories
final donationCategoriesProvider = FutureProvider<List<DonationCategory>>((ref) async {
  final repository = ref.watch(donationRepositoryProvider);
  return await repository.getDonationCategories();
});

// Provider for donor's donations
final donorDonationsProvider = FutureProvider.family<List<Donation>, String>((ref, donorId) async {
  if (donorId.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(donationRepositoryProvider);
  return await repository.getDonationsByDonor(donorId);
});

// Provider for organization's donations
final organizationDonationsProvider = FutureProvider.family<List<Donation>, String>((ref, organizationId) async {
  if (organizationId.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(donationRepositoryProvider);
  return await repository.getDonationsByOrganization(organizationId);
});

// Provider for getting a specific donation
final donationProvider = FutureProvider.family<Donation?, String>((ref, donationId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return await repository.getDonationById(donationId);
});

// Donation state for creating donations
class DonationState {
  final bool isLoading;
  final String? errorMessage;
  final Donation? lastCreatedDonation;
  
  DonationState({
    this.isLoading = false,
    this.errorMessage,
    this.lastCreatedDonation,
  });
  
  DonationState copyWith({
    bool? isLoading,
    String? errorMessage,
    Donation? lastCreatedDonation,
  }) {
    return DonationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastCreatedDonation: lastCreatedDonation ?? this.lastCreatedDonation,
    );
  }
}

// Notifier for creating donations
class DonationNotifier extends StateNotifier<DonationState> {
  final DonationRepository _repository;
  
  DonationNotifier(this._repository) : super(DonationState());
  
  // Create monetary donation
  Future<bool> createMonetaryDonation({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final donation = await _repository.createMonetaryDonation(
        donorId: donorId,
        organizationId: organizationId,
        campaignId: campaignId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        isAnonymous: isAnonymous,
        description: description,
        isRecurring: isRecurring,
        recurringFrequency: recurringFrequency,
      );
      
      state = state.copyWith(
        isLoading: false,
        lastCreatedDonation: donation,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create donation: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  // Create non-monetary donation (items)
  Future<bool> createItemDonation({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final donation = await _repository.createItemDonation(
        donorId: donorId,
        organizationId: organizationId,
        campaignId: campaignId,
        donationCategoryId: donationCategoryId,
        items: items,
        quantity: quantity,
        estimatedValue: estimatedValue,
        isAnonymous: isAnonymous,
        description: description,
        pickupRequired: pickupRequired,
        pickupAddress: pickupAddress,
        pickupDate: pickupDate,
      );
      
      state = state.copyWith(
        isLoading: false,
        lastCreatedDonation: donation,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create donation: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  // Clear last created donation
  void clearLastCreatedDonation() {
    state = state.copyWith(
      lastCreatedDonation: null,
      errorMessage: null,
    );
  }
}

final donationNotifierProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  final repository = ref.watch(donationRepositoryProvider);
  return DonationNotifier(repository);
});