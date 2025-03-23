import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/ui/donor/widgets/donor_bottom_nav.dart';
import 'package:donation_platform/ui/donor/screens/discover_organizations_screen.dart';
import 'package:donation_platform/ui/donor/screens/donation_history_screen.dart';
import 'package:donation_platform/ui/donor/screens/donor_profile_screen.dart';
import 'package:donation_platform/ui/donor/screens/impact_visualization_screen.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const DiscoverOrganizationsScreen(),
    const DonationHistoryScreen(),
    const ImpactVisualizationScreen(),
    const DonorProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: DonorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}