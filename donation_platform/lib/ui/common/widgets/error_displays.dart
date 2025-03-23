import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:donation_platform/ui/common/widgets/buttons/secondary_button.dart';

/// A generic error display with retry button
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData? icon;
  
  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppThemes.errorColor.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              PrimaryButton(
                onPressed: onRetry!,
                label: retryLabel ?? 'Try Again',
                icon: Icons.refresh,
              ),
          ],
        ),
      ),
    );
  }
}

/// An error display for empty states
class EmptyStateDisplay extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  
  const EmptyStateDisplay({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SecondaryButton(
                onPressed: onAction!,
                label: actionLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget to display network connection errors
class NetworkErrorDisplay extends StatelessWidget {
  final VoidCallback onRetry;
  
  const NetworkErrorDisplay({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      message: 'No internet connection. Please check your network settings and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryLabel: 'Refresh',
    );
  }
}

/// A widget to display permission denied errors
class PermissionDeniedDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const PermissionDeniedDisplay({
    super.key,
    this.message = 'You don\'t have permission to access this feature.',
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      message: message,
      icon: Icons.lock_outline,
      onRetry: onAction,
      retryLabel: actionLabel,
    );
  }
}

/// A widget to display an under construction message
class UnderConstructionDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const UnderConstructionDisplay({
    super.key,
    this.message = 'This feature is under construction and will be available soon.',
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppThemes.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SecondaryButton(
                onPressed: onAction!,
                label: actionLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}