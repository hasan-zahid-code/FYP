import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';

class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onActionPressed;

  const AnalyticsScreen({
    super.key,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Coming soon icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppThemes.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Coming soon text
            Text(
              'Analytics Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'We\'re working hard to bring you powerful analytics tools to help you track and visualize your donation impact.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
            ),

            const SizedBox(height: 8),

            // Features coming
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
                  _buildFeatureItem(context, 'Donation trends visualization'),
                  _buildFeatureItem(context, 'Donor demographics and insights'),
                  _buildFeatureItem(context, 'Category performance analysis'),
                  _buildFeatureItem(context, 'Impact reporting tools'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action button
            if (onActionPressed != null)
              PrimaryButton(
                onPressed: onActionPressed!,
                label: 'Back to Dashboard',
                width: 200,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppThemes.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';

// class AnalyticsScreen extends ConsumerStatefulWidget {
//   const AnalyticsScreen({super.key});

//   @override
//   ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }

// class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _timeRange = 'month'; // 'week', 'month', 'year', 'all'
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
    
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(authStateProvider).user;
//     final donationsAsync = ref.watch(organizationDonationsProvider(user?.id ?? ''));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Analytics'),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
//           fontWeight: FontWeight.bold,
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: AppThemes.primaryColor,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: AppThemes.primaryColor,
//           tabs: const [
//             Tab(text: 'Overview'),
//             Tab(text: 'Trends'),
//             Tab(text: 'Categories'),
//             Tab(text: 'Donors'),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: donationsAsync.when(
//           loading: () => const Center(child: LoadingIndicator()),
//           error: (error, stackTrace) => ErrorDisplay(
//             message: 'Failed to load donation data',
//             onRetry: () => ref.refresh(organizationDonationsProvider(user?.id ?? '')),
//           ),
//           data: (donations) {
//             if (donations.isEmpty) {
//               return const EmptyStateDisplay(
//                 message: 'No donation data available yet. Analytics will be displayed once you receive donations.',
//                 icon: Icons.analytics,
//               );
//             }

//             return TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildOverviewTab(context, donations),
//                 _buildTrendsTab(context, donations),
//                 _buildCategoriesTab(context, donations),
//                 _buildDonorsTab(context, donations),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewTab(BuildContext context, List<donation_platform.data.models.donation.Donation> donations) {
//     // Calculate overview metrics
//     final totalDonations = donations.length;
//     final completedDonations = donations.where((d) => d.status == 'completed').length;
//     final pendingDonations = donations.where((d) => d.status == 'pending').length;
//     final processingDonations = donations.where((d) => d.status == 'processing').length;
//     final failedDonations = donations.where((d) => d.status == 'failed' || d.status == 'rejected').length;
    
//     // Calculate monetary totals
//     final monetaryDonations = donations.where((d) => d.amount != null);
//     final totalAmount = monetaryDonations.fold(0.0, (sum, d) => sum + (d.amount ?? 0));
//     final monetaryCount = monetaryDonations.length;
    
//     // Calculate item donation totals
//     final itemDonations = donations.where((d) => d.amount == null);
//     final totalItems = itemDonations.fold(0, (sum, d) => sum + (d.quantity ?? 0));
//     final itemCount = itemDonations.length;
    
//     // Unique donors
//     final uniqueDonors = donations.map((d) => d.donorId).toSet().length;
    
//     // Recurring donations
//     final recurringCount = donations.where((d) => d.isRecurring).length;
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Time range selector
//           _buildTimeRangeSelector(),
          
//           const SizedBox(height: 24),
          
//           // Summary cards
//           Text(
//             'Summary',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 12),
          
//           // Total donations and amount
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   context,
//                   title: 'Total Donations',
//                   value: totalDonations.toString(),
//                   icon: Icons.volunteer_activism,
//                   color: AppThemes.primaryColor,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSummaryCard(
//                   context,
//                   title: 'Total Amount',
//                   value: NumberFormat.currency(symbol: '\$').format(totalAmount),
//                   icon: Icons.attach_money,
//                   color: AppThemes.successColor,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 16),
          
//           // Unique donors and recurring donations
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   context,
//                   title: 'Unique Donors',
//                   value: uniqueDonors.toString(),
//                   icon: Icons.people,
//                   color: AppThemes.secondaryColor,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSummaryCard(
//                   context,
//                   title: 'Recurring Donations',
//                   value: recurringCount.toString(),
//                   icon: Icons.repeat,
//                   color: AppThemes.accentColor,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 24),
          
//           // Status breakdown
//           Text(
//             'Status Breakdown',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           SizedBox(
//             height: 200,
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     value: completedDonations.toDouble(),
//                     title: '${((completedDonations / totalDonations) * 100).toStringAsFixed(1)}%',
//                     color: AppThemes.successColor,
//                     radius: 80,
//                     titleStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: pendingDonations.toDouble(),
//                     title: '${((pendingDonations / totalDonations) * 100).toStringAsFixed(1)}%',
//                     color: AppThemes.warningColor,
//                     radius: 80,
//                     titleStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: processingDonations.toDouble(),
//                     title: '${((processingDonations / totalDonations) * 100).toStringAsFixed(1)}%',
//                     color: AppThemes.primaryColor,
//                     radius: 80,
//                     titleStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: failedDonations.toDouble(),
//                     title: '${((failedDonations / totalDonations) * 100).toStringAsFixed(1)}%',
//                     color: AppThemes.errorColor,
//                     radius: 80,
//                     titleStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//                 sectionsSpace: 0,
//                 centerSpaceRadius: 0,
//                 borderData: FlBorderData(show: false),
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildLegendItem(context, 'Completed', AppThemes.successColor),
//               const SizedBox(width: 16),
//               _buildLegendItem(context, 'Pending', AppThemes.warningColor),
//               const SizedBox(width: 16),
//               _buildLegendItem(context, 'Processing', AppThemes.primaryColor),
//               const SizedBox(width: 16),
//               _buildLegendItem(context, 'Failed', AppThemes.errorColor),
//             ],
//           ),
          
//           const SizedBox(height: 24),
          
//           // Donation type breakdown
//           Text(
//             'Donation Type',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           SizedBox(
//             height: 180,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: PieChart(
//                     PieChartData(
//                       sections: [
//                         PieChartSectionData(
//                           value: monetaryCount.toDouble(),
//                           title: '${((monetaryCount / totalDonations) * 100).toStringAsFixed(1)}%',
//                           color: AppThemes.primaryColor,
//                           radius: 70,
//                           titleStyle: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         PieChartSectionData(
//                           value: itemCount.toDouble(),
//                           title: '${((itemCount / totalDonations) * 100).toStringAsFixed(1)}%',
//                           color: AppThemes.secondaryColor,
//                           radius: 70,
//                           titleStyle: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                       sectionsSpace: 0,
//                       centerSpaceRadius: 0,
//                       borderData: FlBorderData(show: false),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildLegendItem(context, 'Monetary ($monetaryCount)', AppThemes.primaryColor),
//                       const SizedBox(height: 16),
//                       _buildLegendItem(context, 'Items ($itemCount)', AppThemes.secondaryColor),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendsTab(BuildContext context, List<donation_platform.data.models.donation.Donation> donations) {
//     // Filter donations based on time range
//     final filteredDonations = _filterDonationsByTimeRange(donations);
    
//     // Group donations by day/week/month based on time range
//     final groupedDonations = _groupDonationsByTimeRange(filteredDonations);
    
//     // Generate line chart data
//     final amountSpots = <FlSpot>[];
//     final countSpots = <FlSpot>[];
    
//     final List<String> labels = [];
//     int index = 0;
    
//     groupedDonations.forEach((date, donationGroup) {
//       final totalAmount = donationGroup
//           .where((d) => d.amount != null)
//           .fold(0.0, (sum, d) => sum + (d.amount ?? 0));
      
//       amountSpots.add(FlSpot(index.toDouble(), totalAmount));
//       countSpots.add(FlSpot(index.toDouble(), donationGroup.length.toDouble()));
      
//       labels.add(date);
//       index++;
//     });
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Time range selector
//           _buildTimeRangeSelector(),
          
//           const SizedBox(height: 24),
          
//           // Donation amount over time
//           Text(
//             'Donation Amount Trend',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           if (amountSpots.isEmpty) 
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: Text('No donation data available for the selected time range'),
//               ),
//             )
//           else
//             SizedBox(
//               height: 250,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 50,
//                     getDrawingHorizontalLine: (value) {
//                       return FlLine(
//                         color: Colors.grey.withOpacity(0.2),
//                         strokeWidth: 1,
//                       );
//                     },
//                   ),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             '\$${value.toInt()}',
//                             style: TextStyle(
//                               color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                               fontSize: 10,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() >= labels.length || value.toInt() < 0) {
//                             return const SizedBox.shrink();
//                           }
                          
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Text(
//                               labels[value.toInt()],
//                               style: TextStyle(
//                                 color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                                 fontSize: 10,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: amountSpots,
//                       isCurved: true,
//                       color: AppThemes.primaryColor,
//                       barWidth: 3,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(show: true),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: AppThemes.primaryColor.withOpacity(0.1),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
          
//           const SizedBox(height: 24),
          
//           // Donation count over time
//           Text(
//             'Donation Count Trend',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           if (countSpots.isEmpty) 
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: Text('No donation data available for the selected time range'),
//               ),
//             )
//           else
//             SizedBox(
//               height: 250,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 1,
//                     getDrawingHorizontalLine: (value) {
//                       return FlLine(
//                         color: Colors.grey.withOpacity(0.2),
//                         strokeWidth: 1,
//                       );
//                     },
//                   ),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         interval: 1,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             value.toInt().toString(),
//                             style: TextStyle(
//                               color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                               fontSize: 10,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() >= labels.length || value.toInt() < 0) {
//                             return const SizedBox.shrink();
//                           }
                          
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Text(
//                               labels[value.toInt()],
//                               style: TextStyle(
//                                 color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                                 fontSize: 10,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: countSpots,
//                       isCurved: true,
//                       color: AppThemes.secondaryColor,
//                       barWidth: 3,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(show: true),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: AppThemes.secondaryColor.withOpacity(0.1),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoriesTab(BuildContext context, List<donation_platform.data.models.donation.Donation> donations) {
//     // Group donations by category
//     final Map<String, List<donation_platform.data.models.donation.Donation>> categoriesMap = {};
//     for (final donation in donations) {
//       final categoryId = donation.donationCategoryId;
      
//       if (!categoriesMap.containsKey(categoryId)) {
//         categoriesMap[categoryId] = [];
//       }
      
//       categoriesMap[categoryId]!.add(donation);
//     }
    
//     // Sort categories by count
//     final sortedCategories = categoriesMap.entries.toList()
//       ..sort((a, b) => b.value.length.compareTo(a.value.length));
    
//     // Get category data for pie chart
//     final List<PieChartSectionData> categorySections = [];
//     final List<MapEntry<String, List<donation_platform.data.models.donation.Donation>>> topCategories = 
//         sortedCategories.take(5).toList();
    
//     int otherCategoriesCount = 0;
//     if (sortedCategories.length > 5) {
//       for (int i = 5; i < sortedCategories.length; i++) {
//         otherCategoriesCount += sortedCategories[i].value.length;
//       }
//     }
    
//     // Colors for categories
//     final List<Color> categoryColors = [
//       AppThemes.primaryColor,
//       AppThemes.secondaryColor,
//       AppThemes.accentColor,
//       Colors.purple,
//       Colors.teal,
//       Colors.grey,
//     ];
    
//     for (int i = 0; i < topCategories.length; i++) {
//       final category = topCategories[i];
//       final percentage = (category.value.length / donations.length) * 100;
      
//       categorySections.add(
//         PieChartSectionData(
//           value: category.value.length.toDouble(),
//           title: '${percentage.toStringAsFixed(1)}%',
//           color: categoryColors[i],
//           radius: 80,
//           titleStyle: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       );
//     }
    
//     // Add "Other" category if needed
//     if (otherCategoriesCount > 0) {
//       final percentage = (otherCategoriesCount / donations.length) * 100;
      
//       categorySections.add(
//         PieChartSectionData(
//           value: otherCategoriesCount.toDouble(),
//           title: '${percentage.toStringAsFixed(1)}%',
//           color: categoryColors[5],
//           radius: 80,
//           titleStyle: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       );
//     }
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Time range selector
//           _buildTimeRangeSelector(),
          
//           const SizedBox(height: 24),
          
//           // Category distribution chart
//           Text(
//             'Donation Categories',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           if (categorySections.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: Text('No category data available'),
//               ),
//             )
//           else
//             SizedBox(
//               height: 250,
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: PieChart(
//                       PieChartData(
//                         sections: categorySections,
//                         sectionsSpace: 0,
//                         centerSpaceRadius: 0,
//                         borderData: FlBorderData(show: false),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ...List.generate(topCategories.length, (index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: _buildLegendItem(
//                               context, 
//                               _getCategoryName(topCategories[index].key), 
//                               categoryColors[index],
//                             ),
//                           );
//                         }),
//                         if (otherCategoriesCount > 0)
//                           _buildLegendItem(context, 'Other', categoryColors[5]),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
          
//           const SizedBox(height: 24),
          
//           // Category breakdown table
//           Text(
//             'Category Breakdown',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Table header
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 4,
//                         child: Text(
//                           'Category',
//                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           'Count',
//                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: Text(
//                           'Amount',
//                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const Divider(height: 24),
                  
//                   // Table rows
//                   ...categoriesMap.entries.map((entry) {
//                     final categoryName = _getCategoryName(entry.key);
//                     final count = entry.value.length;
                    
//                     // Calculate total amount for monetary donations in this category
//                     final amount = entry.value
//                         .where((d) => d.amount != null)
//                         .fold(0.0, (sum, d) => sum + (d.amount ?? 0));
                    
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 4,
//                             child: Text(categoryName),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               count.toString(),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Text(
//                               NumberFormat.currency(symbol: '\$').format(amount),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//  // Helper method to filter donations by time range
//   List<donation_platform.data.models.donation.Donation> _filterDonationsByTimeRange(
//     List<donation_platform.data.models.donation.Donation> donations,
//   ) {
//     final now = DateTime.now();
    
//     switch (_timeRange) {
//       case 'week':
//         final weekAgo = now.subtract(const Duration(days: 7));
//         return donations.where((d) => d.createdAt.isAfter(weekAgo)).toList();
//       case 'month':
//         final monthAgo = DateTime(now.year, now.month - 1, now.day);
//         return donations.where((d) => d.createdAt.isAfter(monthAgo)).toList();
//       case 'year':
//         final yearAgo = DateTime(now.year - 1, now.month, now.day);
//         return donations.where((d) => d.createdAt.isAfter(yearAgo)).toList();
//       case 'all':
//       default:
//         return donations;
//     }
//   } 
// }