import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/admin_providers.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';

class PlatformStatsCard extends ConsumerWidget {
  const PlatformStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformStatsAsync = ref.watch(platformStatsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insights,
                  color: AppThemes.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Platform Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            platformStatsAsync.when(
              loading: () => const Center(
                child: LoadingSpinner(size: 30),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load statistics',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
              data: (stats) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.people,
                            label: 'Total Users',
                            value: stats.totalUsers.toString(),
                            color: AppThemes.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.business,
                            label: 'Organizations',
                            value: stats.totalOrganizations.toString(),
                            color: AppThemes.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.volunteer_activism,
                            label: 'Donations',
                            value: stats.totalDonations.toString(),
                            color: AppThemes.accentColor,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.attach_money,
                            label: 'Total Amount',
                            value: '\$${stats.totalAmount.toStringAsFixed(2)}',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.verified,
                            label: 'Pending Verifications',
                            value: stats.pendingVerifications.toString(),
                            color: Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Icons.campaign,
                            label: 'Active Campaigns',
                            value: stats.activeCampaigns.toString(),
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
