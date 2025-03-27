import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:donation_platform/ui/common/widgets/buttons/secondary_button.dart';
import 'package:donation_platform/providers/verification_providers.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _otpController = TextEditingController();
  int _resendCounter = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Send OTP when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendCounter = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCounter > 0) {
          _resendCounter--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _sendOTP() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found')),
      );
      return;
    }

    final result = await ref
        .read(verificationNotifierProvider.notifier)
        .sendPhoneVerificationOTP(user.phone);

    if (result && mounted) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your phone number')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP')),
      );
      return;
    }

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found')),
      );
      return;
    }

    final result =
        await ref.read(verificationNotifierProvider.notifier).verifyPhoneOTP(
              user.phone,
              _otpController.text,
            );

    if (result && mounted) {
      // Mark user as verified and navigate based on user type
      await ref.read(authStateProvider.notifier).checkCurrentUser();
      final user = ref.read(authStateProvider).user;

      if (user != null) {
        if (context.mounted) {
          switch (user.userType) {
            case 'donor':
              context.go('/donor');
              break;
            case 'organization':
              context.go('/organization');
              break;
            case 'admin':
              context.go('/admin');
              break;
            default:
              context.go('/login');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(verificationNotifierProvider);
    final user = ref.watch(authStateProvider).user;
    final errorMessage = verificationState.errorMessage;

    // Format phone number for display (show last 4 digits)
    final String phoneDisplay = user != null
        ? '${user.phone.substring(0, user.phone.length - 4).replaceAll(RegExp(r'.'), '*')}${user.phone.substring(user.phone.length - 4)}'
        : 'your phone';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 70,
                    color: AppThemes.primaryColor,
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Phone Verification',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'We have sent a verification code to $phoneDisplay',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Error message (if any)
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppThemes.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppThemes.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: AppThemes.errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // OTP input
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 6,
                      pinAnimationType: PinAnimationType.fade,
                      onCompleted: (pin) {
                        // Auto-verify when all digits are entered
                        _verifyOTP();
                      },
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: AppThemes.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Verify button
                  PrimaryButton(
                    onPressed: _verifyOTP,
                    label: 'Verify',
                    isLoading: verificationState.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Resend OTP button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: _resendCounter == 0 ? _sendOTP : null,
                        child: Text(
                          _resendCounter > 0
                              ? 'Resend in $_resendCounter s'
                              : 'Resend',
                          style: TextStyle(
                            color: _resendCounter == 0
                                ? AppThemes.primaryColor
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Back to login button
                  SecondaryButton(
                    onPressed: () => context.go('/login'),
                    label: 'Back to Login',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
