import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocationReportScreen extends StatefulWidget {
  const LocationReportScreen({
    super.key,
    required this.locationName,
    required this.locationColorCode,
  });

  final String locationName;
  final Color locationColorCode;

  @override
  State<LocationReportScreen> createState() => _LocationReportScreenState();
}

class _LocationReportScreenState extends State<LocationReportScreen> {
  String formattedDate = DateFormat('E MMMM dd, y').format(DateTime.now());
  bool isMonthlyView = true;
  String selectedPeriod = 'Monthly';
  //

  // Get the current month and year

  final List<double> monthlyScan = [
    100,
    200,
    300,
    400,
  ];

  // Yearly data
  final Map<int, List<double>> yearlyScan = {
    int.parse(DateFormat('y').format(DateTime.now())) - 3: [1],
    int.parse(DateFormat('y').format(DateTime.now())) - 2: [1],
    int.parse(DateFormat('y').format(DateTime.now())) - 1: [1],
    int.parse(DateFormat('y').format(DateTime.now())): [300],
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(244, 253, 255, 1)
          : const Color.fromARGB(255, 41, 41, 41),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(244, 253, 255, 1)
            : const Color.fromARGB(255, 41, 41, 41),
        title: Text(widget.locationName),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPeriod,
                items: ['Monthly', 'Yearly']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                    isMonthlyView = value == 'Monthly';
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Total Scan in ${widget.locationName}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    isMonthlyView ? _buildMonthlyChart() : _buildYearlyChart(),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Total Insect Scanning',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildInsectTotalChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForQuarter(int index) {
    switch (index) {
      case 0:
        return widget.locationColorCode;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return widget.locationColorCode;
    }
  }

//monthly
  Widget _buildMonthlyChart() {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // Calculate the previous month and handle the year change if it's January

    int previousMonth2 = currentMonth == 1 ? 12 : currentMonth - 3;
    int previousMonth1 = currentMonth == 1 ? 12 : currentMonth - 2;
    int previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int yearForPreviousMonth =
        currentMonth == 1 ? currentYear - 1 : currentYear;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 500,
        barGroups: monthlyScan.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: widget.locationColorCode,
                width: 16,
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     reservedSize: 40,
          //     getTitlesWidget: (value, meta) {
          //       return Text((value / 1000).toString());
          //     },
          //   ),
          // ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth, previousMonth2)),
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth, previousMonth1)),
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth, previousMonth)),
                  ' ${DateFormat.MMMM().format(DateTime(currentYear, currentMonth))}',
                ];
                return Text(months[value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 500,
        barGroups: yearlyScan.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: entry.value.asMap().entries.map((subEntry) {
              return BarChartRodData(
                toY: subEntry.value,
                color: _getColorForQuarter(subEntry.key),
                width: 16,
              );
            }).toList(),
          );
        }).toList(),
        titlesData: FlTitlesData(
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     reservedSize: 40,
          //     getTitlesWidget: (value, meta) {
          //       return Text('\$${(value / 1000).toStringAsFixed(0)}K');
          //     },
          //   ),
          // ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsectTotalChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 500,
        barGroups: monthlyScan.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: widget.locationColorCode,
                width: 16,
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     reservedSize: 40,
          //     getTitlesWidget: (value, meta) {
          //       return Text((value / 1000).toString());
          //     },
          //   ),
          // ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final instect = [
                  'Green Leafhopper',
                  'Stem Borer',
                  'Rice Bugs',
                  'Rice Leaffolder',
                ];
                return Text(
                  instect[value.toInt()],
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Location data model
class LocationData {
  final String name;
  final int totalScans;
  final Color color;

  LocationData(
      {required this.name, required this.totalScans, required this.color});
}
