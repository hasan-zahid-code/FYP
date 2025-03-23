import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/providers/donation_providers.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:donation_platform/ui/donor/widgets/donation_list_item.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final donationsAsync = ref.watch(donorDonationsProvider(user?.id ?? ''));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      body: donationsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load donation history',
          onRetry: () => ref.refresh(donorDonationsProvider(user?.id ?? '')),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return EmptyStateDisplay(
              message: 'You haven\'t made any donations yet',
              icon: Icons.history,
              actionLabel: 'Discover Organizations',
              onAction: () {
                // Navigate to discover tab
                // For now, just go back since we're using bottom navigation
              },
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DonationListItem(
                  donation: donation,
                  onTap: () {
                    // Navigate to donation details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}