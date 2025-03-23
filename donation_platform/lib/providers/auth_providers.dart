import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/core/auth/auth_service.dart';
import 'package:donation_platform/data/models/user/user.dart';
import 'package:donation_platform/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthService(userRepository);
});

// Auth state class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AppUser? user;
  final String? userType;
  final bool isOnboarded;
  final String? errorMessage;
  
  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.userType,
    this.isOnboarded = false,
    this.errorMessage,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AppUser? user,
    String? userType,
    bool? isOnboarded,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      userType: userType ?? this.userType,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      errorMessage: errorMessage,
    );
  }
}

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  
  AuthStateNotifier(this._authService, this._ref) : super(AuthState()) {
    checkCurrentUser();
  }
  
  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Check if user has gone through onboarding
      final prefs = await SharedPreferences.getInstance();
      final isOnboarded = prefs.getBool('isOnboarded') ?? false;
      
      // Attempt to restore session
      final sessionRestored = await _authService.restoreSession();
      
      if (sessionRestored) {
        final user = await _authService.getCurrentUser();
        final userType = await _authService.getUserType();
        
        if (user != null && userType != null) {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
            userType: userType,
            isOnboarded: isOnboarded,
          );
          return;
        }
      }
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        userType: null,
        isOnboarded: isOnboarded,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        userType: null,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _authService.loginUser(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        userType: user.userType,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        userType: userType,
      );
      
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        userType: userType,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _authService.logoutUser();
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        userType: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _authService.resetPassword(email);
      
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    
    state = state.copyWith(isOnboarded: true);
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService, ref);
});