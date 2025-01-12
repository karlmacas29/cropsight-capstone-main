import 'dart:async';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/pages/reports_location.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ReportsTaggingView extends StatefulWidget {
  const ReportsTaggingView({super.key});

  @override
  State<ReportsTaggingView> createState() => _ReportsTaggingViewState();
}

enum ConnectionStatus { checking, connected, disconnected }

class _ReportsTaggingViewState extends State<ReportsTaggingView> {
  String formattedDate = DateFormat('E MMMM dd, y').format(DateTime.now());
  bool isMonthlyView = true;
  String selectedPeriod = 'Monthly';
// Initialize controllers and variables
  final connectionController = StreamController<ConnectionStatus>.broadcast();
  late StreamSubscription internetSubscription;

  // Add this in dispose
  @override
  void dispose() {
    internetSubscription.cancel();
    connectionController.close();
    super.dispose();
  }

  //
  @override
  void initState() {
    super.initState();
    _fetchYearlyData();
    _fetchMonthlyData();
    _initializeLocations();

    checkInternetConnection();

    // Setup internet connection listener
    internetSubscription =
        InternetConnectionChecker.instance.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        if (!connectionController.isClosed) {
          connectionController.add(ConnectionStatus.connected);
        }
      } else {
        if (!connectionController.isClosed) {
          connectionController.add(ConnectionStatus.disconnected);
        }
      }
    });
  }

  Future<void> checkInternetConnection() async {
    connectionController.add(ConnectionStatus.checking);
    await Future.delayed(const Duration(seconds: 2));

    var status = await InternetConnectionChecker.instance.hasConnection;
    if (!connectionController.isClosed) {
      connectionController.add(
          status ? ConnectionStatus.connected : ConnectionStatus.disconnected);
    }
  }

  Widget connectionStatus() {
    return StreamBuilder<ConnectionStatus>(
      stream: connectionController.stream,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _getStatusColor(snapshot.data),
            ),
            child: Center(
              child: Text(
                _getStatusMessage(snapshot.data),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ConnectionStatus? status) {
    switch (status) {
      case ConnectionStatus.checking:
        return Colors.blue;
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
        return Colors.black45;
      default:
        return Colors.blue;
    }
  }

  String _getStatusMessage(ConnectionStatus? status) {
    switch (status) {
      case ConnectionStatus.checking:
        return 'Checking Connection...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'No Internet Connection';
      default:
        return 'Checking Connection...';
    }
  }

  //
  List<LocationData> locations = [];

  Future<void> _initializeLocations() async {
    // Instance of your database class

    try {
      // Initialize locations with default values
      locations = [
        LocationData(name: 'Southern', totalScans: 0, color: Colors.green),
        LocationData(name: 'Datu Abdul', totalScans: 0, color: Colors.green),
        LocationData(name: 'Dujali', totalScans: 0, color: Colors.green),
        LocationData(name: 'Nanyo', totalScans: 0, color: Colors.green),
      ];

      // Fetch counts for each location asynchronously
      await Future.wait([
        _fetchTotalScansForLocation('Southern'),
        _fetchTotalScansForLocation('Datu Abdul'),
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

    // Adjust the year for previous months if necessary
    for (int i = 0; i < months.length - 1; i++) {
      if (months[i]['month'] > currentMonth) {
        months[i]['year'] = currentYear - 1;
      } else {
        months[i]['year'] = currentYear;
      }
    }

    // Fetch data for each month
    for (int i = 0; i < months.length; i++) {
      await _fetchCountForMonth(months[i]);
    }
  }

  Map<String, dynamic> _getPreviousMonth(int currentMonth, int subtractMonths) {
    int month = currentMonth - subtractMonths;
    int year = DateTime.now().year;

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
      String count = await dbHelper.countEntriesByMonth(
          monthName, monthData['year'].toString());
      double doubleValue = double.tryParse(count) ?? 0.0;

      setState(() {
        // Determine the index in monthlyScan based on the month's relative position
        int index = _getMonthIndex(monthData['month'], DateTime.now().month);

        // Ensure the index is within the bounds of monthlyScan
        if (index >= 0 && index < monthlyScan.length) {
          monthlyScan[index] = doubleValue;
        } else {
          print('Index out of bounds: $index');
        }
      });

      print('Number of entries in $monthName ${monthData['year']}: $count');
    } catch (e) {
      print(
          'Error fetching count for month ${monthData['month']} and year ${monthData['year']}: $e');
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
            connectionStatus(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: DropdownButton<String>(
                    underline: Container(
                      height: 0,
                    ),
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.light
                            ? const Color.fromRGBO(244, 253, 255, 1)
                            : const Color.fromRGBO(18, 18, 18, 1),
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
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    checkInternetConnection();
                  },
                  icon: const Icon(
                    FluentIcons.arrow_sync_12_filled,
                    color: Colors.white,
                  ),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Insect Scans',
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 7,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return _buildLocationCard(locations[index]);
                },
              ),
            ),
            const SizedBox(height: 5),
          ],
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

//monthly
  Widget _buildMonthlyChart() {
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
                color: Colors.green,
                width: 36,
                borderRadius: BorderRadius.circular(0),
              )
            ],
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
                final months = [
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth3, previousMonth3)),
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth2, previousMonth2)),
                  DateFormat.MMMM()
                      .format(DateTime(yearForPreviousMonth1, previousMonth1)),
                  DateFormat.MMMM().format(DateTime(currentYear, currentMonth)),
                ];
                return Text(
                  months[value.toInt()],
                  style: const TextStyle(fontSize: 12),
                );
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
                width: 36,
                borderRadius: BorderRadius.circular(0),
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
        shadowColor: Colors.grey,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromRGBO(18, 18, 18, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            // const SizedBox(height: 5),
            Text(
              '${location.totalScans}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            // const Text(
            //   'Total Insect Scans',
            //   style: TextStyle(
            //     color: Colors.white70,
            //     fontSize: 14,
            //   ),
            // ),
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
