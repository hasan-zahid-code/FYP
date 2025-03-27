import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/data/models/donation/donation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DonationTimelineChart extends StatelessWidget {
  final List<Donation> donations;

  const DonationTimelineChart({
    super.key,
    required this.donations,
  });

  @override
  Widget build(BuildContext context) {
    if (donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
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

    // Sort donations by date
    final sortedDonations = List<Donation>.from(donations)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Group donations by month
    final Map<String, List<Donation>> donationsByMonth = {};
    for (var donation in sortedDonations) {
      final date = donation.createdAt;
      final month = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      if (!donationsByMonth.containsKey(month)) {
        donationsByMonth[month] = [];
      }

      donationsByMonth[month]!.add(donation);
    }

    // Calculate monthly totals (only for monetary donations)
    final List<FlSpot> monetarySpots = [];
    final List<FlSpot> itemSpots = [];

    int index = 0;
    donationsByMonth.forEach((month, monthlyDonations) {
      double monetarySum = 0;
      int itemsCount = 0;

      for (var donation in monthlyDonations) {
        if (donation.amount != null) {
          monetarySum += donation.amount!;
        } else {
          itemsCount++;
        }
      }

      monetarySpots.add(FlSpot(index.toDouble(), monetarySum));
      itemSpots.add(FlSpot(index.toDouble(), itemsCount.toDouble()));

      index++;
    });

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= donationsByMonth.length ||
                      value.toInt() < 0) {
                    return const SizedBox.shrink();
                  }

                  final month = donationsByMonth.keys.elementAt(value.toInt());
                  final date = DateTime(
                    int.parse(month.split('-')[0]),
                    int.parse(month.split('-')[1]),
                    1,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM yy').format(date),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Monetary donations line
            LineChartBarData(
              spots: monetarySpots,
              isCurved: true,
              color: AppThemes.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppThemes.primaryColor.withOpacity(0.1),
              ),
            ),
            // Item donations line
            LineChartBarData(
              spots: itemSpots,
              isCurved: true,
              color: AppThemes.secondaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppThemes.secondaryColor.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Colors.black.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final month = donationsByMonth.keys.elementAt(index);
                  final isMonetary = spot.barIndex == 0;

                  return LineTooltipItem(
                    '${isMonetary ? 'Money' : 'Items'}: ${spot.y.toStringAsFixed(isMonetary ? 2 : 0)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '\n$month',
                        style: TextStyle(
                          color: isMonetary
                              ? AppThemes.primaryColor
                              : AppThemes.secondaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
