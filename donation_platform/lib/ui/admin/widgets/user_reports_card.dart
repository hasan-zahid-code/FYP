import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/admin_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';

class UserReportsCard extends ConsumerWidget {
  const UserReportsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReportsAsync = ref.watch(pendingReportsProvider);

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
                      Icons.report_outlined,
                      color: AppThemes.errorColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'User Reports',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.go('/admin/reports');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            pendingReportsAsync.when(
              loading: () => const Center(
                child: LoadingSpinner(size: 30),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load reports',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No pending reports',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length > 3 ? 3 : reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getReportTypeColor(report.reportType)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getReportTypeIcon(report.reportType),
                          color: _getReportTypeColor(report.reportType),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getReportTypeLabel(report.reportType),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Reported ${_formatDate(report.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.go('/admin/reports/${report.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Review'),
                      ),
                      onTap: () {
                        context.go('/admin/reports/${report.id}');
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

  String _getReportTypeLabel(String reportType) {
    switch (reportType) {
      case 'spam':
        return 'Spam Report';
      case 'fraud':
        return 'Fraud Report';
      case 'inappropriate':
        return 'Inappropriate Content';
      case 'other':
        return 'Other Report';
      default:
        return 'Report';
    }
  }

  IconData _getReportTypeIcon(String reportType) {
    switch (reportType) {
      case 'spam':
        return Icons.mark_chat_unread;
      case 'fraud':
        return Icons.money_off;
      case 'inappropriate':
        return Icons.no_adult_content;
      case 'other':
        return Icons.flag;
      default:
        return Icons.report_problem;
    }
  }

  Color _getReportTypeColor(String reportType) {
    switch (reportType) {
      case 'spam':
        return Colors.orange;
      case 'fraud':
        return Colors.red;
      case 'inappropriate':
        return Colors.purple;
      case 'other':
        return Colors.blue;
      default:
        return AppThemes.errorColor;
    }
  }
}
