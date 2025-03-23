// lib/ui/organization/screens/organization_dashboard_screen.dart
import 'package:flutter/material.dart';

class OrganizationDashboardScreen extends StatelessWidget {
  const OrganizationDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Dashboard'),
      ),
      body: const Center(
        child: Text('Organization Dashboard - Coming Soon'),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:donation_platform/config/themes.dart';
// import 'package:donation_platform/providers/auth_providers.dart';
// import 'package:donation_platform/providers/donation_providers.dart';
// import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
// import 'package:donation_platform/ui/common/widgets/error_displays.dart';
// import 'package:donation_platform/ui/organization/widgets/donation_stats_card.dart';
// import 'package:donation_platform/ui/organization/widgets/verification_status_card.dart';
// import 'package:donation_platform/providers/organization_providers.dart';
// import 'package:donation_platform/ui/organization/widgets/organization_bottom_nav.dart';
// import 'package:donation_platform/ui/organization/screens/pending_donations_screen.dart';
// import 'package:donation_platform/ui/organization/screens/completed_donations_screen.dart';
// import 'package:donation_platform/ui/organization/screens/analytics_screen.dart';
// import 'package:donation_platform/ui/organization/screens/organization_profile_screen.dart';

// class OrganizationDashboardScreen extends ConsumerStatefulWidget {
//   const OrganizationDashboardScreen({super.key});

//   @override
//   ConsumerState<OrganizationDashboardScreen> createState() => _OrganizationDashboardScreenState();
// }

// class _OrganizationDashboardScreenState extends ConsumerState<OrganizationDashboardScreen> {
//   int _currentIndex = 0;
  
//   final List<Widget> _pages = [
//     const OrganizationDashboardHome(),
//     const PendingDonationsScreen(),
//     const CompletedDonationsScreen(),
//     const AnalyticsScreen(),
//     const OrganizationProfileScreen(),
//   ];
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: OrganizationBottomNav(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }

// class OrganizationDashboardHome extends ConsumerWidget {
//   const OrganizationDashboardHome({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authStateProvider).user;
//     final organizationAsync = ref.watch(organizationProvider(user?.id ?? ''));
//     final donationsAsync = ref.watch(organizationDonationsProvider(user?.id ?? ''));
    
//     return Scaffold(
//       body: SafeArea(
//         child: organizationAsync.when(
//           loading: () => const Center(child: LoadingIndicator()),
//           error: (error, stackTrace) => ErrorDisplay(
//             message: 'Failed to load organization data',
//             onRetry: () => ref.refresh(organizationProvider(user?.id ?? '')),
//           ),
//           data: (organization) {
//             if (organization == null) {
//               return const Center(child: Text('Organization not found'));
//             }
            
//             return RefreshIndicator(
//               onRefresh: () async {
//                 ref.refresh(organizationProvider(user?.id ?? ''));
//                 ref.refresh(organizationDonationsProvider(user?.id ?? ''));
//               },
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // App Bar
//                     Row(
//                       children: [
//                         // Organization logo/avatar
//                         CircleAvatar(
//                           radius: 24,
//                           backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
//                           child: organization.logoUrl != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(24),
//                                 child: Image.network(
//                                   organization.logoUrl!,
//                                   width: 48,
//                                   height: 48,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Text(
//                                       organization.organizationName.substring(0, 1).toUpperCase(),
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: AppThemes.primaryColor,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               )
//                             : Text(
//                                 organization.organizationName.substring(0, 1).toUpperCase(),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: AppThemes.primaryColor,
//                                 ),
//                               ),
//                         ),
                        
//                         const SizedBox(width: 12),
                        
//                         // Organization name and type
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 organization.organizationName,
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 organization.organizationType,
//                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
                        
//                         // Notifications icon
//                         IconButton(
//                           icon: const Icon(Icons.notifications_outlined),
//                           onPressed: () {
//                             // Navigate to notifications
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Verification status card
//                     VerificationStatusCard(
//                       status: organization.verificationStatus,
//                       onAction: () {
//                         // Navigate to verification form if not verified
//                         if (organization.verificationStatus != 'approved') {
//                           // Navigate to verification form
//                         }
//                       },
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Quick actions
//                     Text(
//                       'Quick Actions',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Quick action buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildQuickActionButton(
//                           context,
//                           icon: Icons.add_box_outlined,
//                           label: 'New Campaign',
//                           onTap: () {
//                             // Navigate to create campaign
//                           },
//                         ),
//                         _buildQuickActionButton(
//                           context,
//                           icon: Icons.history,
//                           label: 'Pending',
//                           onTap: () {
//                             setState(() {
//                               _currentIndex = 1; // Go to pending donations tab
//                             });
//                           },
//                         ),
//                         _buildQuickActionButton(
//                           context,
//                           icon: Icons.insert_chart_outlined,
//                           label: 'Analytics',
//                           onTap: () {
//                             setState(() {
//                               _currentIndex = 3; // Go to analytics tab
//                             });
//                           },
//                         ),
//                         _buildQuickActionButton(
//                           context,
//                           icon: Icons.edit_outlined,
//                           label: 'Profile',
//                           onTap: () {
//                             setState(() {
//                               _currentIndex = 4; // Go to profile tab
//                             });
//                           },
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Donation statistics
//                     Text(
//                       'Donation Statistics',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Statistics
//                     donationsAsync.when(
//                       loading: () => const Center(child: LoadingSpinner()),
//                       error: (error, stackTrace) => const Center(
//                         child: Text('Failed to load donation statistics'),
//                       ),
//                       data: (donations) {
//                         // Calculate statistics
//                         final totalDonations = donations.length;
//                         final pendingDonations = donations.where((d) => d.status == 'pending').length;
                        
//                         // Calculate total monetary donations
//                         final monetaryDonations = donations.where((d) => d.amount != null);
//                         final totalAmount = monetaryDonations.fold(
//                           0.0, 
//                           (sum, donation) => sum + (donation.amount ?? 0),
//                         );
                        
//                         // Calculate non-monetary donations
//                         final itemDonations = donations.where((d) => d.amount == null).length;
                        
//                         return Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: DonationStatsCard(
//                                     title: 'Total Donations',
//                                     value: totalDonations.toString(),
//                                     icon: Icons.volunteer_activism,
//                                     color: AppThemes.primaryColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: DonationStatsCard(
//                                     title: 'Pending',
//                                     value: pendingDonations.toString(),
//                                     icon: Icons.pending_actions,
//                                     color: AppThemes.warningColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
                            
//                             const SizedBox(height: 16),
                            
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: DonationStatsCard(
//                                     title: 'Total Amount',
//                                     value: '\$${totalAmount.toStringAsFixed(2)}',
//                                     icon: Icons.attach_money,
//                                     color: AppThemes.successColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: DonationStatsCard(
//                                     title: 'Item Donations',
//                                     value: itemDonations.toString(),
//                                     icon: Icons.inventory_2,
//                                     color: AppThemes.accentColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         );
//                       },
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Recent activity
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Recent Activity',
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             // View all
//                           },
//                           child: const Text('View All'),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Recent activity list
//                     donationsAsync.when(
//                       loading: () => const Center(child: LoadingSpinner()),
//                       error: (error, stackTrace) => const Center(
//                         child: Text('Failed to load recent activity'),
//                       ),
//                       data: (donations) {
//                         if (donations.isEmpty) {
//                           return const Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Text('No recent activity'),
//                             ),
//                           );
//                         }
                        
//                         // Get most recent 5 donations
//                         final recentDonations = donations
//                             .take(5)
//                             .toList();
                        
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: recentDonations.length,
//                           itemBuilder: (context, index) {
//                             final donation = recentDonations[index];
//                             return ListTile(
//                               leading: CircleAvatar(
//                                 backgroundColor: donation.status == 'pending'
//                                   ? AppThemes.warningColor.withOpacity(0.1)
//                                   : donation.status == 'completed'
//                                     ? AppThemes.successColor.withOpacity(0.1)
//                                     : Colors.grey.withOpacity(0.1),
//                                 child: Icon(
//                                   donation.amount != null
//                                     ? Icons.attach_money
//                                     : Icons.inventory_2,
//                                   color: donation.status == 'pending'
//                                     ? AppThemes.warningColor
//                                     : donation.status == 'completed'
//                                       ? AppThemes.successColor
//                                       : Colors.grey,
//                                 ),
//                               ),
//                               title: Text(
//                                 donation.isAnonymous
//                                   ? 'Anonymous Donor'
//                                   : 'Donor', // Replace with actual donor name
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Text(
//                                 donation.amount != null
//                                   ? '\$${donation.amount!.toStringAsFixed(2)}'
//                                   : '${donation.quantity} items',
//                               ),
//                               trailing: Text(
//                                 donation.status.toUpperCase(),
//                                 style: TextStyle(
//                                   color: donation.status == 'pending'
//                                     ? AppThemes.warningColor
//                                     : donation.status == 'completed'
//                                       ? AppThemes.successColor
//                                       : Colors.grey,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               onTap: () {
//                                 // Navigate to donation details
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
  
//   Widget _buildQuickActionButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppThemes.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppThemes.primaryColor,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   void setState(VoidCallback callback) {
//     // Proxy method to update _currentIndex in parent widget
//     callback();
//   }
// }