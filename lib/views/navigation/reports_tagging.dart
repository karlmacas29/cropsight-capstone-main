import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/pages/reports_location.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsTaggingView extends StatefulWidget {
  const ReportsTaggingView({super.key});

  @override
  State<ReportsTaggingView> createState() => _ReportsTaggingViewState();
}

class _ReportsTaggingViewState extends State<ReportsTaggingView> {
  String formattedDate = DateFormat('E MMMM dd, y').format(DateTime.now());
  bool isMonthlyView = true;
  String selectedPeriod = 'Monthly';

  //
  @override
  void initState() {
    super.initState();
    _fetchYearlyData();
    _fetchMonthlyData();
    _initializeLocations();
  }

  //
  List<LocationData> locations = [];

  Future<void> _initializeLocations() async {
    // Instance of your database class

    try {
      // Initialize locations with default values
      locations = [
        LocationData(name: 'Carmen', totalScans: 0, color: Colors.orange),
        LocationData(name: 'Panabo', totalScans: 0, color: Colors.amber),
        LocationData(name: 'Dujali', totalScans: 0, color: Colors.green),
        LocationData(name: 'Nanyo', totalScans: 0, color: Colors.brown),
      ];

      // Fetch counts for each location asynchronously
      await Future.wait([
        _fetchTotalScansForLocation('Carmen'),
        _fetchTotalScansForLocation('Panabo'),
        _fetchTotalScansForLocation('Dujali'),
        _fetchTotalScansForLocation('Nanyo'),
      ]);
    } catch (e) {
      print('Error initializing locations: $e');
    }
  }

  Future<void> _fetchTotalScansForLocation(String locationName) async {
    final dbHelper = CropSightDatabase(); // Instance of your database class

    try {
      String count = await dbHelper.countEntriesByLocation(locationName);

      setState(() {
        // Find and update the location in the list
        int index = locations.indexWhere((loc) => loc.name == locationName);
        if (index != -1) {
          locations[index] =
              locations[index].copyWith(totalScans: int.tryParse(count) ?? 0);
        }
      });
    } catch (e) {
      print('Error fetching scans for $locationName: $e');
    }
  }

  // Helper method to calculate max Y value dynamically
  double _getMaxYMonth() {
    // Find the maximum value
    double maxValue =
        monthlyScan.reduce((curr, next) => curr > next ? curr : next);

    // Add some padding (e.g., 10% more than the max)
    return maxValue * 1.1;
  }

  double _getMaxYYear() {
    // Expand the list of lists and find the maximum value
    double maxValue = yearlyScan.values
        .expand((list) => list)
        .reduce((curr, next) => curr > next ? curr : next);

    // Add some padding (e.g., 10% more than the max)
    return maxValue * 1.1;
  }

  // Get the current month and year

  final List<double> monthlyScan = [
    0,
    0,
    0,
    0,
  ];

  Future<void> _fetchMonthlyData() async {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // Calculate the months to fetch
    final months = [
      _getPreviousMonth(currentMonth, 3),
      _getPreviousMonth(currentMonth, 2),
      _getPreviousMonth(currentMonth, 1),
      {'month': currentMonth, 'year': currentYear}
    ];

    // Fetch data for each month
    for (int i = 0; i < months.length; i++) {
      await _fetchCountForMonth(months[i]);
    }
  }

  Map<String, dynamic> _getPreviousMonth(int currentMonth, int subtractMonths) {
    int month = currentMonth - subtractMonths;
    int year = DateTime.now().year;

    // Handle year change
    if (month <= 0) {
      month += 12;
      year--;
    }

    return {'month': month, 'year': year};
  }

  Future<void> _fetchCountForMonth(Map<String, dynamic> monthData) async {
    final dbHelper = CropSightDatabase(); // Instance of your database class

    try {
      // Convert month to full month name
      String monthName = DateFormat.MMMM()
          .format(DateTime(monthData['year'], monthData['month']));

      // Fetch count from database
      String count = await dbHelper.countEntriesByMonth(monthName);
      double doubleValue = double.tryParse(count) ?? 0.0;

      setState(() {
        // Determine the index in monthlyScan based on the month's relative position
        int index = _getMonthIndex(monthData['month'], DateTime.now().month);
        monthlyScan[index] = doubleValue;
      });

      print('Number of entries in $monthName: $count');
    } catch (e) {
      print('Error fetching count for month ${monthData['month']}: $e');
    }
  }

  int _getMonthIndex(int month, int currentMonth) {
    // Calculate the index based on the month's relative position to the current month
    int diff = currentMonth - month;
    return 3 - diff; // Reverse the order to match your chart layout
  }

  final Map<int, List<double>> yearlyScan = {
    DateTime.now().year - 3: [0],
    DateTime.now().year - 2: [0],
    DateTime.now().year - 1: [0],
    DateTime.now().year: [0],
  };

  Future<void> _fetchYearlyData() async {
    final currentYear = DateTime.now().year;
    final years = [
      currentYear - 3,
      currentYear - 2,
      currentYear - 1,
      currentYear
    ];

    // Fetch data for each year
    for (var year in years) {
      await _fetchCountForYear(year.toString());
    }
  }

  Future<void> _fetchCountForYear(String yr) async {
    final dbHelper = CropSightDatabase(); // Instance of your database class

    try {
      int count = await dbHelper.countEntriesByYear(yr);
      double doubleValue = count.toDouble();

      setState(() {
        // Convert year string to int
        int yearKey = int.parse(yr);

        // Update the first (default) entry for this year
        // You can modify this logic if you want to distribute across quarters
        if (yearlyScan.containsKey(yearKey)) {
          yearlyScan[yearKey]?[0] = doubleValue;
        }
      });

      print('Number of entries in $yr: $count');
    } catch (e) {
      print('Error fetching count for year $yr: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Total Scan',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Text(formattedDate)
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isMonthlyView ? _buildMonthlyChart() : _buildYearlyChart(),
            ),
            const SizedBox(height: 20),

            // Location Cards
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return _buildLocationCard(locations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForQuarter(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
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
        maxY: _getMaxYMonth(),
        barGroups: monthlyScan.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
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
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
        maxY: _getMaxYYear(),
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
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildLocationCard(LocationData location) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationReportScreen(
              locationName: location.name,
              locationColorCode: location.color,
            ),
          ),
        );
      },
      child: Card(
        color: location.color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${location.totalScans}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Total Scans',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Optional: If your LocationData class doesn't have a copyWith method, add it
class LocationData {
  final String name;
  final int totalScans;
  final Color color;

  LocationData(
      {required this.name, required this.totalScans, required this.color});

  LocationData copyWith({
    String? name,
    int? totalScans,
    Color? color,
  }) {
    return LocationData(
      name: name ?? this.name,
      totalScans: totalScans ?? this.totalScans,
      color: color ?? this.color,
    );
  }
}
