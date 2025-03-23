// lib/ui/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: const Center(
        child: Text('Admin Dashboard - Coming Soon'),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:donation_platform/config/themes.dart';
// import 'package:donation_platform/providers/auth_providers.dart';
// import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
// import 'package:go_router/go_router.dart';
// import 'package:donation_platform/ui/admin/widgets/admin_drawer.dart';
// import 'package:donation_platform/ui/admin/widgets/pending_verifications_card.dart';
// import 'package:donation_platform/ui/admin/widgets/user_reports_card.dart';
// import 'package:donation_platform/ui/admin/widgets/platform_stats_card.dart';

// class AdminDashboardScreen extends ConsumerWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authStateProvider).user;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
//           fontWeight: FontWeight.bold,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               // Navigate to notifications
//             },
//           ),
//         ],
//       ),
//       drawer: const AdminDrawer(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Welcome message
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
//                     child: user?.profileImageUrl != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(24),
//                           child: Image.network(
//                             user!.profileImageUrl!,
//                             width: 48,
//                             height: 48,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Text(
//                                 user.fullName.substring(0, 1).toUpperCase(),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppThemes.primaryColor,
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       : Text(
//                           user?.fullName.substring(0, 1).toUpperCase() ?? 'A',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: AppThemes.primaryColor,
//                           ),
//                         ),
//                   ),
                  
//                   const SizedBox(width: 16),
                  
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Welcome back, ${user?.fullName.split(' ')[0] ?? 'Admin'}',
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Here\'s what\'s happening today',
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 32),
              
//               // Platform statistics
//               const PlatformStatsCard(),
              
//               const SizedBox(height: 24),
              
//               // Pending verifications
//               const PendingVerificationsCard(),
              
//               const SizedBox(height: 24),
              
//               // User reports
//               const UserReportsCard(),
              
//               const SizedBox(height: 24),
              
//               // Quick actions
//               Text(
//                 'Quick Actions',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Quick action buttons
//               GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   _buildQuickActionCard(
//                     context,
//                     icon: Icons.business,
//                     title: 'Organizations',
//                     subtitle: 'Manage organizations',
//                     color: AppThemes.primaryColor,
//                     onTap: () {
//                       // Navigate to organizations list
//                     },
//                   ),
//                   _buildQuickActionCard(
//                     context,
//                     icon: Icons.person,
//                     title: 'Users',
//                     subtitle: 'Manage users',
//                     color: AppThemes.secondaryColor,
//                     onTap: () {
//                       // Navigate to users list
//                     },
//                   ),
//                   _buildQuickActionCard(
//                     context,
//                     icon: Icons.gavel,
//                     title: 'Blacklist',
//                     subtitle: 'Manage blacklisted users',
//                     color: AppThemes.errorColor,
//                     onTap: () {
//                       // Navigate to blacklist management
//                     },
//                   ),
//                   _buildQuickActionCard(
//                     context,
//                     icon: Icons.settings,
//                     title: 'Settings',
//                     subtitle: 'System settings',
//                     color: Colors.grey,
//                     onTap: () {
//                       // Navigate to settings
//                     },
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 32),
              
//               // Logout button
//               Center(
//                 child: PrimaryButton(
//                   onPressed: () async {
//                     await ref.read(authStateProvider.notifier).logout();
//                     if (context.mounted) {
//                       context.go('/login');
//                     }
//                   },
//                   label: 'Logout',
//                   icon: Icons.logout,
//                   width: 200,
//                 ),
//               ),
              
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildQuickActionCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                 ),
//               ),
              
//               const Spacer(),
              
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
              
//               const SizedBox(height: 4),
              
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }