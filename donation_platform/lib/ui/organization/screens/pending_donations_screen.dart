import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/providers/donation_providers.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:donation_platform/ui/common/widgets/buttons/secondary_button.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class PendingDonationsScreen extends ConsumerStatefulWidget {
  const PendingDonationsScreen({super.key});

  @override
  ConsumerState<PendingDonationsScreen> createState() =>
      _PendingDonationsScreenState();
}

class _PendingDonationsScreenState
    extends ConsumerState<PendingDonationsScreen> {
  final _searchController = TextEditingController();
  String _filterStatus = 'pending'; // Default to pending

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final donationsAsync =
        ref.watch(organizationDonationsProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Donations'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search donations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Status filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('Pending', 'pending'),
                    _buildFilterChip('Processing', 'processing'),
                    _buildFilterChip('Failed', 'failed'),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Donations list
            Expanded(
              child: donationsAsync.when(
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stackTrace) => ErrorDisplay(
                  message: 'Failed to load donations',
                  onRetry: () => ref
                      .refresh(organizationDonationsProvider(user?.id ?? '')),
                ),
                data: (donations) {
                  // Filter donations by status
                  final filteredDonations = donations
                      .where((d) => d.status == _filterStatus)
                      .toList();

                  // Filter by search query if present
                  final searchQuery =
                      _searchController.text.toLowerCase().trim();
                  final displayedDonations = searchQuery.isEmpty
                      ? filteredDonations
                      : filteredDonations
                          .where((d) =>
                              d.id.toLowerCase().contains(searchQuery) ||
                              (d.donationNotes
                                      ?.toLowerCase()
                                      .contains(searchQuery) ??
                                  false) ||
                              (d.amount?.toString().contains(searchQuery) ??
                                  false))
                          .toList();

                  if (displayedDonations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No $_filterStatus donations found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedDonations.length,
                    itemBuilder: (context, index) {
                      final donation = displayedDonations[index];
                      return _buildDonationCard(context, donation);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppThemes.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? AppThemes.primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppThemes.primaryColor : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, Donation donation) {
    final isMonetary = donation.amount != null;
    final formattedDate = timeago.format(donation.createdAt);
    final currencyFormat = NumberFormat.currency(
      symbol: donation.currency ?? 'USD',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showDonationDetailsDialog(context, donation);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Donation ID and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${donation.id.substring(0, 8)}...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: donation.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      donation.formattedStatus,
                      style: TextStyle(
                        color: donation.getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Donation details
              Row(
                children: [
                  // Icon for donation type
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isMonetary
                              ? AppThemes.successColor
                              : AppThemes.accentColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isMonetary ? Icons.attach_money : Icons.inventory_2,
                      color: isMonetary
                          ? AppThemes.successColor
                          : AppThemes.accentColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Donation info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMonetary ? 'Monetary Donation' : 'Item Donation',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isMonetary
                              ? currencyFormat.format(donation.amount)
                              : '${donation.quantity} items',
                          style: TextStyle(
                            color: isMonetary
                                ? AppThemes.successColor
                                : AppThemes.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Anonymous badge if applicable
                  if (donation.isAnonymous)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Anonymous',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),

              // Notes if available
              if (donation.donationNotes != null &&
                  donation.donationNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Notes: ${donation.donationNotes}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    onPressed: () {
                      _showDonationDetailsDialog(context, donation);
                    },
                    label: 'Details',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    onPressed: () {
                      _showActionDialog(context, donation);
                    },
                    label: donation.status == 'pending' ? 'Process' : 'Update',
                    icon: donation.status == 'pending'
                        ? Icons.check_circle
                        : Icons.update,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Donations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterOptionChip(context, 'All', ''),
                  _buildFilterOptionChip(context, 'Pending', 'pending'),
                  _buildFilterOptionChip(context, 'Processing', 'processing'),
                  _buildFilterOptionChip(context, 'Failed', 'failed'),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Donation Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildCustomFilterChip(
                      context, 'Monetary', Icons.attach_money, true),
                  _buildCustomFilterChip(
                      context, 'Items', Icons.inventory_2, true),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppThemes.primaryColor,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOptionChip(
      BuildContext context, String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          Navigator.pop(context);
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppThemes.primaryColor.withOpacity(0.2),
      checkmarkColor: AppThemes.primaryColor,
    );
  }

  Widget _buildCustomFilterChip(
      BuildContext context, String label, IconData icon, bool selected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? AppThemes.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (value) {
        // Add filter logic here
      },
      backgroundColor: Colors.white,
      selectedColor: AppThemes.primaryColor.withOpacity(0.2),
      checkmarkColor: AppThemes.primaryColor,
    );
  }

  void _showDonationDetailsDialog(BuildContext context, Donation donation) {
    final isMonetary = donation.amount != null;
    final currencyFormat = NumberFormat.currency(
      symbol: donation.currency ?? 'USD',
      decimalDigits: 2,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Donation Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', donation.id),
                _buildDetailRow('Type', isMonetary ? 'Monetary' : 'Items'),
                _buildDetailRow('Status', donation.formattedStatus),
                _buildDetailRow(
                    'Created',
                    DateFormat('MMM dd, yyyy HH:mm')
                        .format(donation.createdAt)),
                _buildDetailRow(
                    'Anonymous', donation.isAnonymous ? 'Yes' : 'No'),
                if (isMonetary) ...[
                  _buildDetailRow(
                      'Amount', currencyFormat.format(donation.amount)),
                  _buildDetailRow(
                      'Payment Method', donation.paymentMethod ?? 'N/A'),
                  _buildDetailRow('Transaction Ref',
                      donation.transactionReference ?? 'N/A'),
                  _buildDetailRow(
                      'Recurring', donation.isRecurring ? 'Yes' : 'No'),
                  if (donation.isRecurring &&
                      donation.recurringFrequency != null)
                    _buildDetailRow('Frequency', donation.recurringFrequency!),
                ] else ...[
                  _buildDetailRow('Quantity', '${donation.quantity}'),
                  _buildDetailRow(
                      'Estimated Value',
                      donation.estimatedValue != null
                          ? currencyFormat.format(donation.estimatedValue)
                          : 'N/A'),
                  _buildDetailRow('Pickup Required',
                      donation.pickupRequired == true ? 'Yes' : 'No'),
                  if (donation.pickupRequired == true) ...[
                    _buildDetailRow(
                        'Pickup Address', donation.pickupAddress ?? 'N/A'),
                    if (donation.pickupDate != null)
                      _buildDetailRow(
                          'Pickup Date',
                          DateFormat('MMM dd, yyyy')
                              .format(donation.pickupDate!)),
                    _buildDetailRow(
                        'Pickup Status', donation.pickupStatus ?? 'Scheduled'),
                  ],
                ],
                if (donation.donationNotes != null &&
                    donation.donationNotes!.isNotEmpty)
                  _buildDetailRow('Notes', donation.donationNotes!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showActionDialog(context, donation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
              ),
              child: Text(donation.status == 'pending' ? 'Process' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, Donation donation) {
    final isMonetary = donation.amount != null;
    final isPending = donation.status == 'pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isPending ? 'Process Donation' : 'Update Donation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPending
                      ? 'Are you ready to process this ${isMonetary ? 'monetary' : 'item'} donation?'
                      : 'Update the status of this donation:',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (isPending) ...[
                  _buildActionButton(
                    context,
                    'Accept & Process',
                    Icons.check_circle,
                    AppThemes.successColor,
                    () => _updateDonationStatus(donation, 'processing'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Schedule Pickup',
                    Icons.local_shipping,
                    AppThemes.primaryColor,
                    () {
                      Navigator.pop(context);
                      // Show pickup scheduling dialog
                    },
                    visible: !isMonetary,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Reject Donation',
                    Icons.cancel,
                    AppThemes.errorColor,
                    () => _updateDonationStatus(donation, 'rejected'),
                  ),
                ] else if (donation.status == 'processing') ...[
                  _buildActionButton(
                    context,
                    'Mark as Completed',
                    Icons.task_alt,
                    AppThemes.successColor,
                    () => _updateDonationStatus(donation, 'completed'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Report Issue',
                    Icons.report_problem,
                    AppThemes.warningColor,
                    () {
                      Navigator.pop(context);
                      // Show report issue dialog
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool visible = true,
  }) {
    if (!visible) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Future<void> _updateDonationStatus(Donation donation, String status) async {
    try {
      final success = await ref
          .read(donationNotifierProvider.notifier)
          .updateDonationStatus(
            donation.id,
            status,
          );

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          // Refresh the list
          ref.refresh(organizationDonationsProvider(donation.organizationId));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Donation updated to $status successfully'),
              backgroundColor: AppThemes.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update donation status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
