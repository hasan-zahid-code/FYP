import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/config/constants.dart';

class VerificationStatusCard extends StatelessWidget {
  final String status;
  final VoidCallback? onAction;
  
  const VerificationStatusCard({
    super.key,
    required this.status,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = status == AppConstants.verificationStageApproved;
    final isPending = status == AppConstants.verificationStagePending;
    final isInReview = status == AppConstants.verificationStageReview;
    final isRejected = status == AppConstants.verificationStageRejected;
    
    final Color cardColor = isVerified
        ? AppThemes.successColor.withOpacity(0.1)
        : isRejected
            ? AppThemes.errorColor.withOpacity(0.1)
            : AppThemes.warningColor.withOpacity(0.1);
            
    final Color textColor = isVerified
        ? AppThemes.successColor
        : isRejected
            ? AppThemes.errorColor
            : AppThemes.warningColor;
    
    final IconData statusIcon = isVerified
        ? Icons.verified
        : isRejected
            ? Icons.error_outline
            : isInReview
                ? Icons.pending_actions
                : Icons.warning_amber_rounded;
    
    final String statusText = isVerified
        ? 'Verified Organization'
        : isRejected
            ? 'Verification Rejected'
            : isInReview
                ? 'Verification in Review'
                : 'Verification Required';
                
    final String descriptionText = isVerified
        ? 'Your organization is verified and can receive donations.'
        : isRejected
            ? 'Your verification was rejected. Please review and resubmit.'
            : isInReview
                ? 'Your verification is under review. We\'ll notify you once it\'s approved.'
                : 'Complete verification to start receiving donations.';
                
    final String actionText = isVerified
        ? 'View Certificate'
        : isRejected
            ? 'Update Information'
            : isInReview
                ? 'View Status'
                : 'Complete Verification';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: textColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                statusIcon,
                color: textColor,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status text and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descriptionText,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action button
            if (onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}