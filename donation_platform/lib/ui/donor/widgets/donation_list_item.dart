import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DonationListItem extends StatelessWidget {
  final Donation donation;
  final VoidCallback? onTap;
  
  const DonationListItem({
    super.key,
    required this.donation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMonetary = donation.amount != null;
    final currencyFormat = NumberFormat.currency(
      symbol: donation.currency ?? 'USD',
      decimalDigits: 2,
    );
    
    final statusColor = _getStatusColor(donation.status);
    final statusText = _getStatusText(donation.status);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Organization and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization logo/icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.business,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Organization name and donation date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donated to Organization', // Replace with actual organization name
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          timeago.format(donation.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Divider(color: Colors.grey.shade200),
              
              const SizedBox(height: 16),
              
              // Donation details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Donation type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMonetary ? 'Money' : 'Items',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // Amount/Value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMonetary 
                            ? currencyFormat.format(donation.amount)
                            : donation.quantity?.toString() ?? 'N/A',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Show recurring badge if applicable
              if (donation.isRecurring) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemes.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: AppThemes.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Recurring ${donation.recurringFrequency ?? 'Monthly'}',
                        style: TextStyle(
                          color: AppThemes.secondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // If donation has notes, show them
              if (donation.donationNotes != null && donation.donationNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donation.donationNotes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppThemes.successColor;
      case 'pending':
        return AppThemes.warningColor;
      case 'processing':
        return AppThemes.warningColor;
      case 'failed':
        return AppThemes.errorColor;
      case 'rejected':
        return AppThemes.errorColor;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    // Capitalize the first letter
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
}