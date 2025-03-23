import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:fl_chart/fl_chart.dart';

class DonationCategoryChart extends StatefulWidget {
  final List<Donation> donations;
  
  const DonationCategoryChart({
    super.key,
    required this.donations,
  });

  @override
  State<DonationCategoryChart> createState() => _DonationCategoryChartState();
}

class _DonationCategoryChartState extends State<DonationCategoryChart> {
  int touchedIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    // Process data for chart
    final Map<String, double> categoryData = {};
    
    // Group donations by category
    for (var donation in widget.donations) {
      final category = donation.donationCategoryId;
      final amount = donation.amount ?? (donation.estimatedValue ?? 0);
      
      if (categoryData.containsKey(category)) {
        categoryData[category] = categoryData[category]! + amount;
      } else {
        categoryData[category] = amount;
      }
    }
    
    // Set colors for categories
    final List<Color> categoryColors = [
      AppThemes.primaryColor,
      AppThemes.secondaryColor,
      AppThemes.accentColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    
    // Create sections for pie chart
    final sections = <PieChartSectionData>[];
    int colorIndex = 0;
    
    categoryData.forEach((category, amount) {
      final isTouched = sections.length == touchedIndex;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 110 : 100;
      final Color color = categoryColors[colorIndex % categoryColors.length];
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${(amount / categoryData.values.fold(0, (sum, value) => sum + value) * 100).toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
              ),
            ],
          ),
        ),
      );
      
      colorIndex++;
    });
    
    // If no data, show empty state
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No donation data available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: sections,
            ),
          ),
        ),
        
        // Legend
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...categoryData.entries.map((entry) {
                  final color = categoryColors[
                    categoryData.keys.toList().indexOf(entry.key) % categoryColors.length
                  ];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getCategoryName(entry.key),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _getCategoryName(String categoryId) {
    // This is a placeholder - in a real app, you'd look up the
    // category name from a list of categories
    switch (categoryId) {
      case 'money':
        return 'Money';
      case 'food':
        return 'Food';
      case 'clothes':
        return 'Clothes';
      case 'books':
        return 'Books';
      case 'medical':
        return 'Medical Supplies';
      case 'household':
        return 'Household Items';
      default:
        return 'Other';
    }
  }
}