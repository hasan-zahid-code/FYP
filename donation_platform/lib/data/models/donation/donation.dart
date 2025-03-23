import 'package:donation_platform/data/models/donation/donation_tracking.dart';
import 'package:flutter/material.dart';

class Donation {
  final String id;
  final String donorId;
  final String organizationId;
  final String? campaignId;
  final String donationCategoryId;
  final double? amount; // Null for non-monetary donations
  final String? currency; // Null for non-monetary donations
  final Map<String, dynamic>? donationItems; // Details for non-monetary donations
  final int? quantity; // For non-monetary donations
  final double? estimatedValue; // For non-monetary donations
  final bool isAnonymous;
  final String status; // "pending", "processing", "completed", "failed", "rejected"
  final String? paymentMethod; // Null for non-monetary donations
  final String? paymentId;
  final String? transactionReference;
  final String? donationNotes;
  final bool? pickupRequired; // For physical item donations
  final String? pickupAddress; // For physical item donations
  final DateTime? pickupDate; // For physical item donations
  final String? pickupStatus; // "scheduled", "completed", "cancelled"
  final bool? giftAidEligible;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? receiptUrl;
  final String? ipAddress;
  final Map<String, dynamic>? deviceInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Tracking information
  final DonationTracking? tracking;
  
  Donation({
    required this.id,
    required this.donorId,
    required this.organizationId,
    this.campaignId,
    required this.donationCategoryId,
    this.amount,
    this.currency,
    this.donationItems,
    this.quantity,
    this.estimatedValue,
    required this.isAnonymous,
    required this.status,
    this.paymentMethod,
    this.paymentId,
    this.transactionReference,
    this.donationNotes,
    this.pickupRequired,
    this.pickupAddress,
    this.pickupDate,
    this.pickupStatus,
    this.giftAidEligible,
    required this.isRecurring,
    this.recurringFrequency,
    this.receiptUrl,
    this.ipAddress,
    this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
    this.tracking,
  });
  
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      donorId: json['donor_id'],
      organizationId: json['organization_id'],
      campaignId: json['campaign_id'],
      donationCategoryId: json['donation_category_id'],
      amount: json['amount'],
      currency: json['currency'],
      donationItems: json['donation_items'],
      quantity: json['quantity'],
      estimatedValue: json['estimated_value'],
      isAnonymous: json['is_anonymous'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentId: json['payment_id'],
      transactionReference: json['transaction_reference'],
      donationNotes: json['donation_notes'],
      pickupRequired: json['pickup_required'],
      pickupAddress: json['pickup_address'],
      pickupDate: json['pickup_date'] != null ? DateTime.parse(json['pickup_date']) : null,
      pickupStatus: json['pickup_status'],
      giftAidEligible: json['gift_aid_eligible'],
      isRecurring: json['is_recurring'],
      recurringFrequency: json['recurring_frequency'],
      receiptUrl: json['receipt_url'],
      ipAddress: json['ip_address'],
      deviceInfo: json['device_info'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tracking: json['tracking'] != null ? DonationTracking.fromJson(json['tracking']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'organization_id': organizationId,
      'campaign_id': campaignId,
      'donation_category_id': donationCategoryId,
      'amount': amount,
      'currency': currency,
      'donation_items': donationItems,
      'quantity': quantity,
      'estimated_value': estimatedValue,
      'is_anonymous': isAnonymous,
      'status': status,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'transaction_reference': transactionReference,
      'donation_notes': donationNotes,
      'pickup_required': pickupRequired,
      'pickup_address': pickupAddress,
      'pickup_date': pickupDate?.toIso8601String(),
      'pickup_status': pickupStatus,
      'gift_aid_eligible': giftAidEligible,
      'is_recurring': isRecurring,
      'recurring_frequency': recurringFrequency,
      'receipt_url': receiptUrl,
      'ip_address': ipAddress,
      'device_info': deviceInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tracking': tracking?.toJson(),
    };
  }
  
  // Create a copy of the donation with updated fields
  Donation copyWith({
    String? id,
    String? donorId,
    String? organizationId,
    String? campaignId,
    String? donationCategoryId,
    double? amount,
    String? currency,
    Map<String, dynamic>? donationItems,
    int? quantity,
    double? estimatedValue,
    bool? isAnonymous,
    String? status,
    String? paymentMethod,
    String? paymentId,
    String? transactionReference,
    String? donationNotes,
    bool? pickupRequired,
    String? pickupAddress,
    DateTime? pickupDate,
    String? pickupStatus,
    bool? giftAidEligible,
    bool? isRecurring,
    String? recurringFrequency,
    String? receiptUrl,
    String? ipAddress,
    Map<String, dynamic>? deviceInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DonationTracking? tracking,
  }) {
    return Donation(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      organizationId: organizationId ?? this.organizationId,
      campaignId: campaignId ?? this.campaignId,
      donationCategoryId: donationCategoryId ?? this.donationCategoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      donationItems: donationItems ?? this.donationItems,
      quantity: quantity ?? this.quantity,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      transactionReference: transactionReference ?? this.transactionReference,
      donationNotes: donationNotes ?? this.donationNotes,
      pickupRequired: pickupRequired ?? this.pickupRequired,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupStatus: pickupStatus ?? this.pickupStatus,
      giftAidEligible: giftAidEligible ?? this.giftAidEligible,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tracking: tracking ?? this.tracking,
    );
  }
  
  // Check if donation is monetary
  bool get isMonetary => amount != null && amount! > 0;
  
  // Get formatted amount with currency
  String get formattedAmount {
    if (!isMonetary) {
      return 'Non-monetary';
    }
    return '${currency ?? 'USD'} ${amount?.toStringAsFixed(2) ?? '0.00'}';
  }
  
  // Format status for display
  String get formattedStatus {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
  
  // Get color for status
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF43A047); // Green
      case 'pending':
        return const Color(0xFFFFB74D); // Orange
      case 'processing':
        return const Color(0xFF42A5F5); // Blue
      case 'failed':
        return const Color(0xFFE53935); // Red
      case 'rejected':
        return const Color(0xFFE53935); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }
}