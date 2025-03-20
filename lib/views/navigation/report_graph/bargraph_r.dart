//monthly
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

Widget buildMonthlyChart({
  required BuildContext context,
  required bool isOnline,
  required bool isLoad,
  required List<double> monthlyScan,
}) {
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  // Calculate the previous months and handle the year change if necessary
  int previousMonth3 = currentMonth - 3;
  int previousMonth2 = currentMonth - 2;
  int previousMonth1 = currentMonth - 1;

  int yearForPreviousMonth3 = currentYear;
  int yearForPreviousMonth2 = currentYear;
  int yearForPreviousMonth1 = currentYear;

  if (previousMonth3 <= 0) {
    previousMonth3 += 12;
    yearForPreviousMonth3 -= 1;
  }
  if (previousMonth2 <= 0) {
    previousMonth2 += 12;
    yearForPreviousMonth2 -= 1;
  }
  if (previousMonth1 <= 0) {
    previousMonth1 += 12;
    yearForPreviousMonth1 -= 1;
  }

  double maxY = monthlyScan.reduce((a, b) => a > b ? a : b);

  return Skeletonizer(
    enabled: isLoad,
    child: Skeleton.leaf(
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromRGBO(18, 18, 18, 1),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BarChart(
            curve: Curves.easeInOut,
            BarChartData(
              maxY: maxY,
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                  left: BorderSide(color: Colors.grey, width: 1),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
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
              alignment: BarChartAlignment.spaceAround,
              // maxY: _getMaxYMonth(),
              barGroups: monthlyScan.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      gradient: isOnline
                          ? LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                            )
                          : null,
                      toY: entry.value,
                      color: isOnline ? null : Colors.green,
                      width: 35.w,
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
                      return Text(
                        _formatNumber(value),
                        style: TextStyle(fontSize: 10.sp),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final months = [
                        DateFormat.MMMM().format(
                            DateTime(yearForPreviousMonth3, previousMonth3)),
                        DateFormat.MMMM().format(
                            DateTime(yearForPreviousMonth2, previousMonth2)),
                        DateFormat.MMMM().format(
                            DateTime(yearForPreviousMonth1, previousMonth1)),
                        DateFormat.MMMM()
                            .format(DateTime(currentYear, currentMonth)),
                      ];
                      return Text(
                        months[value.toInt()],
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

Color _getColorForQuarter(int index) {
  switch (index) {
    case 0:
      return Colors.green;
    case 1:
      return Colors.green;
    case 2:
      return Colors.green;
    default:
      return Colors.green;
  }
}

Widget buildYearlyChart({
  required BuildContext context,
  required bool isOnline,
  required bool isLoad,
  required Map<int, List<double>> yearlyScan,
}) {
  double maxY =
      yearlyScan.values.expand((list) => list).reduce((a, b) => a > b ? a : b);

  return Skeletonizer(
    enabled: isLoad,
    child: Skeleton.leaf(
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromRGBO(18, 18, 18, 1),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BarChart(
            curve: Curves.easeInOut,
            BarChartData(
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                checkToShowVerticalLine: (value) => value % 1 == 0,
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5],
                ),
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
              alignment: BarChartAlignment.spaceAround,
              // maxY: _getMaxYYear(),
              barGroups: yearlyScan.entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: entry.value.asMap().entries.map((subEntry) {
                    return BarChartRodData(
                      toY: subEntry.value,
                      gradient: isOnline
                          ? LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                            )
                          : null,
                      color:
                          isOnline ? null : _getColorForQuarter(subEntry.key),
                      width: 34.w,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(6),
                        topRight: const Radius.circular(6),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatNumber(value),
                        style: TextStyle(fontSize: 10.sp),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
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
