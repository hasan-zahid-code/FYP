import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:donation_platform/ui/common/screens/splash_screen.dart';
import 'package:donation_platform/ui/common/screens/error_screen.dart';
import 'package:donation_platform/ui/common/screens/onboarding_screen.dart';
import 'package:donation_platform/ui/auth/screens/login_screen.dart';
import 'package:donation_platform/ui/auth/screens/register_screen.dart';
import 'package:donation_platform/ui/auth/screens/verification_screen.dart';
import 'package:donation_platform/ui/donor/screens/donor_home_screen.dart';
import 'package:donation_platform/ui/organization/screens/organization_dashboard_screen.dart';
import 'package:donation_platform/ui/admin/screens/admin_dashboard_screen.dart';
import 'package:donation_platform/providers/auth_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _donorNavigatorKey = GlobalKey<NavigatorState>();
final _organizationNavigatorKey = GlobalKey<NavigatorState>();
final _adminNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoute {
  splash,
  onboarding,
  login,
  register,
  verification,
  donorHome,
  organizationDashboard,
  adminDashboard,
  // Other routes will be defined here
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      // Check if the splash screen should be shown
      if (state.matchedLocation == '/') {
        return '/splash';
      }

      // Check if user is authenticated
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.isOnboarded;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verification';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // If not onboarded, redirect to onboarding
      if (!isOnboarded &&
          !isOnboardingRoute &&
          state.matchedLocation != '/splash') {
        return '/onboarding';
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated &&
          !isAuthRoute &&
          state.matchedLocation != '/splash' &&
          !isOnboardingRoute) {
        return '/login';
      }

      // If authenticated, redirect to appropriate home based on user type
      if (isAuthenticated && isAuthRoute) {
        switch (authState.userType) {
          case 'donor':
            return '/donor';
          case 'organization':
            return '/organization';
          case 'admin':
            return '/admin';
          default:
            return '/login';
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: '/verification',
        name: AppRoute.verification.name,
        builder: (BuildContext context, GoRouterState state) =>
            const VerificationScreen(),
      ),

      // // Donor Routes
      ShellRoute(
        navigatorKey: _donorNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            child,
        routes: [
          GoRoute(
            path: '/donor',
            name: AppRoute.donorHome.name,
            builder: (BuildContext context, GoRouterState state) =>
                const DonorHomeScreen(),
            routes: const [
              // Donor sub-routes will be defined here
            ],
          ),
        ],
      ),

      // Organization Routes
      ShellRoute(
        navigatorKey: _organizationNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            child,
        routes: [
          GoRoute(
            path: '/organization',
            name: AppRoute.organizationDashboard.name,
            builder: (BuildContext context, GoRouterState state) =>
                const OrganizationDashboardScreen(),
            routes: const [
              // Organization sub-routes will be defined here
            ],
          ),
        ],
      ),

      // Admin Routes
      ShellRoute(
        navigatorKey: _adminNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            child,
        routes: [
          GoRoute(
            path: '/admin',
            name: AppRoute.adminDashboard.name,
            builder: (BuildContext context, GoRouterState state) =>
                const AdminDashboardScreen(),
            routes: const [
              // Admin sub-routes will be defined here
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        ErrorScreen(error: state.error),
  );
});
