import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color _getColorForInsect(int index) {
  switch (index) {
    case 0:
      return Colors.orange;
    case 1:
      return Colors.purple;
    case 2:
      return Colors.indigoAccent;
    case 3:
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

//simple number conversion
String _formatNumber(double num) {
  if (num >= 1000000000) {
    return '${(num / 1000000000).toStringAsFixed(num % 1000000000 == 0 ? 0 : 1)}B';
  } else if (num >= 1000000) {
    return '${(num / 1000000).toStringAsFixed(num % 1000000 == 0 ? 0 : 1)}M';
  } else if (num >= 10000) {
    return '${(num / 1000).toStringAsFixed(0)}K'; // No decimal if 10K+
  } else if (num >= 1000) {
    return '${(num / 1000).toStringAsFixed(1)}K'; // 1 decimal for 1K-9.9K
  }
  return num.toStringAsFixed(1);
}

Widget buildInsectTotalChartBasedMonth({
  required BuildContext context,
  required List<String> insectName,
  required List<double> insectCounts,
  required bool isLoad,
}) {
  double maxY = insectCounts.reduce((a, b) => a > b ? a : b);
  return Skeletonizer(
    enabled: isLoad,
    child: Skeleton.leaf(
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromARGB(255, 26, 26, 26),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BarChart(
            curve: Curves.easeInOut,
            BarChartData(
              maxY: maxY,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: maxY,
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashArray: [5],
                  ),
                ],
              ),
              gridData: FlGridData(
                show: true,
                checkToShowVerticalLine: (value) => value % 1 == 0,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5],
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                  left: BorderSide(color: Colors.grey, width: 1),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              // maxY: _getMaxY(),
              barGroups: insectCounts.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: _getColorForInsect(entry.key),
                      width: 34.w,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(6),
                        topRight: const Radius.circular(6),
                      ),
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(_formatNumber(value),
                          style: TextStyle(fontSize: 10.sp));
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SizedBox(
                        width: 78.w,
                        child: Text(
                          insectName[value.toInt()],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                          ),
                          maxLines: 2,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildYearlyInsectChart({
  required BuildContext context,
  required Map<int, List<double>> yearlyInsectCounts,
  required bool isLoad,
}) {
  double maxY = yearlyInsectCounts.values
      .expand((list) => list)
      .reduce((a, b) => a > b ? a : b);

  return Skeletonizer(
    enabled: isLoad,
    child: Skeleton.leaf(
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromARGB(255, 26, 26, 26),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BarChart(
            curve: Curves.easeInOut,
            BarChartData(
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: maxY,
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashArray: [5],
                  ),
                ],
              ),
              gridData: FlGridData(
                show: true,
                // checkToShowHorizontalLine: (value) => value % 10 == 0,
                // getDrawingVerticalLine: (value) => FlLine(
                //   color: Colors.grey,
                //   strokeWidth: 0.5,
                //   dashArray: [5],
                // ),
                checkToShowVerticalLine: (value) => value % 1 == 0,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5],
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                  left: BorderSide(color: Colors.grey, width: 1),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              // maxY: _getMaxYY(),
              barGroups: yearlyInsectCounts.entries.map((yearEntry) {
                return BarChartGroupData(
                  x: yearEntry.key,
                  barRods: yearEntry.value.asMap().entries.map((insectEntry) {
                    return BarChartRodData(
                      toY: insectEntry.value,
                      color: _getColorForInsect(insectEntry.key),
                      width: 15.w,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(6),
                        topRight: const Radius.circular(6),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // For the bottom titles, display the years
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10.sp),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Display numbers on the left side
                      return Text(
                        _formatNumber(value),
                        style: TextStyle(fontSize: 10.sp),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildCardLegend(BuildContext context) {
  return Card(
    color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color.fromARGB(255, 26, 26, 26),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem('Green Leafhopper', _getColorForInsect(0)),
              const SizedBox(width: 16),
              _buildLegendItem('Stem Borer', _getColorForInsect(1)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem('Rice Bugs', _getColorForInsect(2)),
              const SizedBox(width: 16),
              _buildLegendItem('Green leaffolder', _getColorForInsect(3)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildLegendItem(String label, Color color) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        width: 16.w,
        height: 16.h,
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(fontSize: 12.sp),
      ),
    ],
  );
}
