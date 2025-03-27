import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 100,
                color: AppThemes.errorColor.withOpacity(0.8),
              ),

              const SizedBox(height: 32),

              // Error title
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error message
              Text(
                error?.toString() ?? 'The requested page could not be found.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Back home button
              PrimaryButton(
                onPressed: () => context.go('/'),
                label: 'Go Back Home',
                icon: Icons.home,
                width: 200,
              ),

              const SizedBox(height: 16),

              // Try again button
              if (error != null)
                TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('Try Again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
