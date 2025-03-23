import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppThemes.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: user?.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          user!.profileImageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryColor,
                                fontSize: 24,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        user?.fullName.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryColor,
                          fontSize: 24,
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.fullName ?? 'Admin User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'admin@example.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
            isSelected: true,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.business,
            title: 'Organizations',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/organizations');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Users',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/users');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.report_problem,
            title: 'Reports',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/reports');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.block,
            title: 'Blacklist',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/blacklist');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/settings');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppThemes.primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppThemes.primaryColor : null,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
    );
  }
}