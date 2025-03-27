import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/admin_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';

class PendingVerificationsCard extends ConsumerWidget {
  const PendingVerificationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingVerificationsAsync = ref.watch(pendingVerificationsProvider);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppThemes.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Verifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.go('/admin/organizations/pending');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            pendingVerificationsAsync.when(
              loading: () => const Center(
                child: LoadingSpinner(size: 30),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load verifications',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
              data: (verifications) {
                if (verifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No pending verifications',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      verifications.length > 3 ? 3 : verifications.length,
                  itemBuilder: (context, index) {
                    final verification = verifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            AppThemes.primaryColor.withOpacity(0.1),
                        child: Text(
                          verification.organizationName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppThemes.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        verification.organizationName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Submitted: ${_formatDate(verification.submittedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.go(
                              '/admin/organizations/verification/${verification.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Review'),
                      ),
                      onTap: () {
                        context.go(
                            '/admin/organizations/verification/${verification.id}');
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
