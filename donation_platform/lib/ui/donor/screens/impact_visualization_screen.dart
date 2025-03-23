import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/providers/donation_providers.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:donation_platform/ui/donor/widgets/impact_summary_card.dart';
import 'package:donation_platform/ui/donor/widgets/donation_category_chart.dart';
import 'package:donation_platform/ui/donor/widgets/donation_timeline_chart.dart';

class ImpactVisualizationScreen extends ConsumerWidget {
  const ImpactVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final donationsAsync = ref.watch(donorDonationsProvider(user?.id ?? ''));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Impact'),
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
          message: 'Failed to load donation data',
          onRetry: () => ref.refresh(donorDonationsProvider(user?.id ?? '')),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return const EmptyStateDisplay(
              message: 'You haven\'t made any donations yet. Your impact will be visualized here once you start donating.',
              icon: Icons.insights,
            );
          }
          
          // Calculate total donation amount
          final totalMonetaryAmount = donations
              .where((d) => d.amount != null)
              .fold(0.0, (sum, d) => sum + (d.amount ?? 0));
          
          // Count total item donations
          final totalItemDonations = donations
              .where((d) => d.amount == null)
              .length;
          
          // Count total organizations helped
          final organizationsHelped = donations
              .map((d) => d.organizationId)
              .toSet()
              .length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Impact summary cards
                Row(
                  children: [
                    Expanded(
                      child: ImpactSummaryCard(
                        title: 'Total Donated',
                        value: '\$${totalMonetaryAmount.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: AppThemes.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ImpactSummaryCard(
                        title: 'Organizations',
                        value: organizationsHelped.toString(),
                        icon: Icons.business,
                        color: AppThemes.secondaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ImpactSummaryCard(
                        title: 'Items Donated',
                        value: totalItemDonations.toString(),
                        icon: Icons.inventory_2,
                        color: AppThemes.accentColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ImpactSummaryCard(
                        title: 'Total Donations',
                        value: donations.length.toString(),
                        icon: Icons.volunteer_activism,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Donations by category
                Text(
                  'Donations by Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 250,
                  child: DonationCategoryChart(donations: donations),
                ),
                
                const SizedBox(height: 32),
                
                // Donation timeline
                Text(
                  'Donation Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 250,
                  child: DonationTimelineChart(donations: donations),
                ),
                
                const SizedBox(height: 16),
                
                // Placeholder for impact stories
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impact Stories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        const Text(
                          'Impact stories from organizations you\'ve donated to will appear here.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Coming soon badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}