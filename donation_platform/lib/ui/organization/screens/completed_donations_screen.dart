import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/providers/donation_providers.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:donation_platform/data/models/donation/donation_update.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class CompletedDonationsScreen extends ConsumerStatefulWidget {
  const CompletedDonationsScreen({super.key});

  @override
  ConsumerState<CompletedDonationsScreen> createState() =>
      _CompletedDonationsScreenState();
}

class _CompletedDonationsScreenState
    extends ConsumerState<CompletedDonationsScreen> {
  final _searchController = TextEditingController();
  final _dateRangeController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? _selectedCategory;
  bool _isMonetaryOnly = false;
  bool _isItemsOnly = false;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
  }

  void _setDefaultDateRange() {
    final today = DateTime.now();
    final oneMonthAgo = today.subtract(const Duration(days: 30));
    _selectedDateRange = DateTimeRange(start: oneMonthAgo, end: today);
    _updateDateRangeText();
  }

  void _updateDateRangeText() {
    if (_selectedDateRange != null) {
      _dateRangeController.text =
          '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - '
          '${DateFormat('MMM d, y').format(_selectedDateRange!.end)}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final donationsAsync =
        ref.watch(organizationDonationsProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Donations'),
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
            // Search bar
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

            // Date range filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () => _selectDateRange(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateRangeController,
                    decoration: InputDecoration(
                      hintText: 'Select date range',
                      prefixIcon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            ),

            // Applied filters
            if (_selectedCategory != null || _isMonetaryOnly || _isItemsOnly)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedCategory != null)
                        _buildFilterTag('Category: $_selectedCategory', () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        }),
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
                  // Filter by status (completed only)
                  final completedDonations =
                      donations.where((d) => d.status == 'completed').toList();

                  // Filter by date range
                  List<Donation> filteredDonations = completedDonations;
                  if (_selectedDateRange != null) {
                    filteredDonations = completedDonations
                        .where((d) =>
                            d.createdAt.isAfter(_selectedDateRange!.start) &&
                            d.createdAt.isBefore(_selectedDateRange!.end
                                .add(const Duration(days: 1))))
                        .toList();
                  }

                  // Filter by donation type
                  if (_isMonetaryOnly) {
                    filteredDonations = filteredDonations
                        .where((d) => d.amount != null)
                        .toList();
                  } else if (_isItemsOnly) {
                    filteredDonations = filteredDonations
                        .where((d) => d.amount == null)
                        .toList();
                  }

                  // Filter by category if selected
                  if (_selectedCategory != null) {
                    filteredDonations = filteredDonations
                        .where((d) => d.donationCategoryId == _selectedCategory)
                        .toList();
                  }

                  // Filter by search query if present
                  final searchQuery =
                      _searchController.text.toLowerCase().trim();
                  if (searchQuery.isNotEmpty) {
                    filteredDonations = filteredDonations
                        .where((d) =>
                            d.id.toLowerCase().contains(searchQuery) ||
                            (d.donationNotes
                                    ?.toLowerCase()
                                    .contains(searchQuery) ??
                                false) ||
                            (d.amount?.toString().contains(searchQuery) ??
                                false))
                        .toList();
                  }

                  if (filteredDonations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No completed donations found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDonations.length,
                    itemBuilder: (context, index) {
                      final donation = filteredDonations[index];
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

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemes.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemes.primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemes.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 14,
                color: AppThemes.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemes.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _updateDateRangeText();
      });
    }
  }

  Widget _buildDonationCard(BuildContext context, Donation donation) {
    final isMonetary = donation.amount != null;
    final formattedDate = DateFormat('MMM d, yyyy').format(donation.createdAt);
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
                  Column(
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

                  // Completed badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppThemes.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppThemes.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: AppThemes.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

              const SizedBox(height: 16),

              // Add update button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    _showAddUpdateDialog(context, donation);
                  },
                  label: 'Add Update',
                  icon: Icons.update,
                ),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Completed Donations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Date range selector
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _selectDateRange(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppThemes.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dateRangeController.text.isNotEmpty
                                  ? _dateRangeController.text
                                  : 'Select date range',
                              style: TextStyle(
                                color: _dateRangeController.text.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Donation type
                  Text(
                    'Donation Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: CheckboxListTile(
                          title: const Text('Monetary'),
                          value: _isMonetaryOnly,
                          onChanged: (value) {
                            setState(() {
                              _isMonetaryOnly = value ?? false;
                              if (_isMonetaryOnly) {
                                _isItemsOnly = false;
                              }
                            });
                          },
                          activeColor: AppThemes.primaryColor,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: CheckboxListTile(
                          title: const Text('Items'),
                          value: _isItemsOnly,
                          onChanged: (value) {
                            setState(() {
                              _isItemsOnly = value ?? false;
                              if (_isItemsOnly) {
                                _isMonetaryOnly = false;
                              }
                            });
                          },
                          activeColor: AppThemes.primaryColor,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Refresh the list with filters
                        this.setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppThemes.primaryColor,
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          title: const Text('Completed Donation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', donation.id),
                _buildDetailRow('Type', isMonetary ? 'Monetary' : 'Items'),
                _buildDetailRow('Status', 'Completed'),
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
                        'Pickup Status', donation.pickupStatus ?? 'Completed'),
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
                _showAddUpdateDialog(context, donation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
              ),
              child: const Text('Add Update'),
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

  void _showAddUpdateDialog(BuildContext context, Donation donation) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Donation Update'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add an update about how this donation was utilized. This will be visible to the donor.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Update Title',
                    hintText: 'e.g., "Your donation helped 10 families"',
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Update Description',
                    hintText:
                        'Describe how the donation was used and its impact...',
                  ),
                  maxLines: 5,
                  maxLength: 500,
                ),
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
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _submitDonationUpdate(
                  context,
                  donation,
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
              ),
              child: const Text('Submit Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitDonationUpdate(
    BuildContext context,
    Donation donation,
    String title,
    String description,
  ) async {
    try {
      // Create a donation update object
      final user = ref.read(authStateProvider).user;
      if (user == null) {
        throw Exception('User not found');
      }

      final update = DonationUpdate(
        id: '', // Will be generated by the repository
        donationId: donation.id,
        title: title,
        description: description,
        mediaUrls: null, // No media for now
        createdBy: user.id,
        createdAt: DateTime.now(),
      );

      // Call the donation repository to add the update
      final notifier = ref.read(donationNotifierProvider.notifier);
      final success = await notifier.addDonationUpdate(update);

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update added successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the donations list
          ref.refresh(organizationDonationsProvider(user.id));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add update'),
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
