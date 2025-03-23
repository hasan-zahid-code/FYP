import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/core/services/verification_service.dart';

// Verification service provider
final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService();
});

// Verification state
class VerificationState {
  final bool isLoading;
  final String? errorMessage;
  
  VerificationState({
    this.isLoading = false,
    this.errorMessage,
  });
  
  VerificationState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return VerificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Verification notifier
class VerificationNotifier extends StateNotifier<VerificationState> {
  final VerificationService _service;
  
  VerificationNotifier(this._service) : super(VerificationState());
  
  // Send phone verification OTP
  Future<bool> sendPhoneVerificationOTP(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _service.sendPhoneVerificationOTP(phone);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
      return false;
    }
  }
  
  // Verify phone OTP
  Future<bool> verifyPhoneOTP(String phone, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _service.verifyPhoneOTP(phone, otp);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to verify OTP: ${e.toString()}',
      );
      return false;
    }
  }
  
  // Verify CNIC (National ID)
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _service.verifyCNIC(cnic, name, dateOfBirth);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to verify CNIC: ${e.toString()}',
      );
      return false;
    }
  }
}

final verificationNotifierProvider = StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  final service = ref.watch(verificationServiceProvider);
  return VerificationNotifier(service);
});