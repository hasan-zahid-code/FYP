import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:donation_platform/ui/common/widgets/buttons/secondary_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:donation_platform/data/models/user/user.dart';
import 'package:donation_platform/data/models/donor/donor_profile.dart';
import 'package:donation_platform/providers/donor_providers.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:go_router/go_router.dart';

class DonorProfileScreen extends ConsumerWidget {
  const DonorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final donorProfileAsync = ref.watch(donorProfileProvider(user?.id ?? ''));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: donorProfileAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 16),
              SecondaryButton(
                onPressed: () => ref.refresh(donorProfileProvider(user?.id ?? '')),
                label: 'Retry',
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
        data: (donorProfile) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      // Profile image
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
                        child: user.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: user.profileImageUrl!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Text(
                                  user.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              user.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryColor,
                              ),
                            ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Verification status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isVerified
                            ? AppThemes.successColor.withOpacity(0.1)
                            : AppThemes.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isVerified ? Icons.verified : Icons.pending,
                              size: 14,
                              color: user.isVerified
                                ? AppThemes.successColor
                                : AppThemes.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isVerified ? 'Verified' : 'Verification Pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.isVerified
                                  ? AppThemes.successColor
                                  : AppThemes.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Edit profile button
                      SecondaryButton(
                        onPressed: () {
                          // Navigate to edit profile
                        },
                        label: 'Edit Profile',
                        icon: Icons.edit,
                        width: 200,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Profile sections
                _buildProfileSection(
                  context,
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow(context, 'Phone', user.phone),
                    if (donorProfile?.dateOfBirth != null)
                      _buildInfoRow(
                        context,
                        'Date of Birth',
                        '${donorProfile!.dateOfBirth!.day}/${donorProfile.dateOfBirth!.month}/${donorProfile.dateOfBirth!.year}',
                      ),
                    if (donorProfile?.gender != null)
                      _buildInfoRow(context, 'Gender', donorProfile!.gender!),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildProfileSection(
                  context,
                  title: 'Address',
                  icon: Icons.location_on_outlined,
                  children: [
                    if (donorProfile?.address != null)
                      _buildInfoRow(context, 'Address', donorProfile!.address!),
                    if (donorProfile?.city != null)
                      _buildInfoRow(context, 'City', donorProfile!.city!),
                    if (donorProfile?.state != null)
                      _buildInfoRow(context, 'State', donorProfile!.state!),
                    if (donorProfile?.country != null)
                      _buildInfoRow(context, 'Country', donorProfile!.country!),
                    if (donorProfile?.postalCode != null)
                      _buildInfoRow(context, 'Postal Code', donorProfile!.postalCode!),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildProfileSection(
                  context,
                  title: 'Preferences',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildToggleRow(
                      context,
                      'Anonymous Donations',
                      donorProfile?.isAnonymousByDefault ?? false,
                      (value) {
                        // Update anonymous preference
                      },
                    ),
                    _buildToggleRow(
                      context,
                      'Notification Emails',
                      donorProfile?.notificationPreferences?['email'] ?? true,
                      (value) {
                        // Update notification preference
                      },
                    ),
                    _buildToggleRow(
                      context,
                      'SMS Notifications',
                      donorProfile?.notificationPreferences?['sms'] ?? true,
                      (value) {
                        // Update notification preference
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Logout button
                Center(
                  child: PrimaryButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    label: 'Logout',
                    icon: Icons.logout,
                    width: 200,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppThemes.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (children.isNotEmpty) const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggleRow(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppThemes.primaryColor,
          ),
        ],
      ),
    );
  }
}