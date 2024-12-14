import 'package:cropsight/controller/db_controller.dart';
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
  late String locn = widget.locationName;
  String rightTitle = DateFormat('MMMM').format(DateTime.now()).toString();
  //

  // List to store insect counts
  final List<double> insectCounts = [0, 0, 0, 0];

  // Insect names in the same order as the counts
  final List<String> insectNames = [
    'Green Leafhopper',
    'Stem Borer',
    'Rice Bugs',
    'Rice Leaffolder',
  ];

  Future<void> _fetchInsectCounts(String loc) async {
    final dbHelper = CropSightDatabase(); // Instance of your database class

    try {
      // Get current month and format it
      String currentMonth = DateFormat('MMMM').format(DateTime.now());
      String currentLocation = loc; // You can make this dynamic if needed

      // Fetch counts for the given location and month
      Map<String, int> counts = await dbHelper.countEntriesByLocationAndInsect(
          currentLocation, currentMonth);

      setState(() {
        // Update insect counts in the same order as insectNames
        insectCounts[0] = (counts['Green Leafhopper'] ?? 0).toDouble();
        insectCounts[1] = (counts['Stem Borer'] ?? 0).toDouble();
        insectCounts[2] = (counts['Rice bug'] ?? 0).toDouble();
        insectCounts[3] = (counts['Green leaffolder'] ?? 0).toDouble();
      });

      // Print the counts for debugging
      insectNames.asMap().forEach((index, name) {
        print(
            '$name count in $currentLocation by $currentMonth : ${insectCounts[index]}');
      });
    } catch (e) {
      print('Error fetching insect counts: $e');
    }
  }

  // Map to store insect counts for each year
  final Map<int, List<double>> yearlyInsectCounts = {
    DateTime.now().year - 3: [0, 0, 0, 0],
    DateTime.now().year - 2: [0, 0, 0, 0],
    DateTime.now().year - 1: [0, 0, 0, 0],
    DateTime.now().year: [0, 0, 0, 0],
  };

  final List<String> insectNames1 = [
    'Green Leafhopper',
    'Stem Borer',
    'Rice Bugs',
    'Rice Leaffolder',
  ];

  Future<void> _fetchYearlyInsectCounts(String loc) async {
    final dbHelper = CropSightDatabase(); // Instance of your database class

    try {
      // Fetch counts for the current location and years
      String currentLocation = loc; // You can make this dynamic if needed
      final years = yearlyInsectCounts.keys.toList();

      // Fetch counts for each year
      for (var year in years) {
        Map<String, int> counts =
            await dbHelper.countEntriesByLocationAndInsectForYear(
                currentLocation, year.toString());

        setState(() {
          // Update insect counts in the same order as insectNames
          yearlyInsectCounts[year]?[0] =
              (counts['Green Leafhopper'] ?? 0).toDouble();
          yearlyInsectCounts[year]?[1] = (counts['Stem Borer'] ?? 0).toDouble();
          yearlyInsectCounts[year]?[2] = (counts['Rice bug'] ?? 0).toDouble();
          yearlyInsectCounts[year]?[3] =
              (counts['Green leaffolder'] ?? 0).toDouble();
        });

        // Print the counts for debugging
        print('Counts for year $year:');
        insectNames.asMap().forEach((index, name) {
          print('$name count: ${yearlyInsectCounts[year]?[index]}');
        });
      }
    } catch (e) {
      print('Error fetching yearly insect counts: $e');
    }
  }

  // Get the current month and year

  List<int> monthlyInsectScan = [0, 0, 0, 0]; // Default empty data

  Future<void> _loadMonthlyData() async {
    List<int> data = await fetchMonthlyCounts(locn);
    setState(() {
      monthlyInsectScan = data; // Update the data and refresh the UI
    });
  }

  // Yearly data
  Map<int, double> yearlyScan = {};

  Future<void> _loadYearlyData() async {
    Map<int, double> data = await fetchYearlyCounts(locn);
    setState(() {
      yearlyScan = data; // Update state with fetched data
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchInsectCounts(locn);
    _fetchYearlyInsectCounts(locn);
    _loadMonthlyData();
    _loadYearlyData();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).brightness == Brightness.light
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Total Insect Scan in ${widget.locationName}',
                    style: const TextStyle(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Insect Scanning in ${isMonthlyView ? rightTitle : 'Years'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isMonthlyView
                    ? _buildInsectTotalChartBasedMonth()
                    : _buildYearlyInsectChart(),
              ),
              const SizedBox(height: 16),
              _buildCardLegend(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<int>> fetchMonthlyCounts(String location) async {
    final dbHelper = CropSightDatabase(); // Database instance

    // List to store counts for the last three months and current month
    List<int> counts = [];

    // Get the current date
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // Fetch counts for the current and previous three months
    for (int i = 3; i >= 0; i--) {
      int targetMonth = currentMonth - i;
      int targetYear = currentYear;

      // Adjust the year if the month calculation goes below 1 (January)
      if (targetMonth < 1) {
        targetMonth += 12; // Wrap around to December
        targetYear -= 1;
      }

      // Fetch the count for the specific month
      String countString = await dbHelper.countEntriesByLocationAndMonth(
          location,
          DateFormat.MMMM().format(DateTime(targetYear, targetMonth)));
      int count = int.tryParse(countString) ?? 0;
      counts.add(count);
    }

    return counts;
  }

//monthly
  Widget _buildMonthlyChart() {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyInsectScan.reduce((a, b) => a > b ? a : b).toDouble() +
            0.5, // Set maxY dynamically
        barGroups: monthlyInsectScan.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: widget.locationColorCode,
                width: 16,
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = List.generate(4, (i) {
                  int targetMonth = currentMonth - 3 + i;
                  int targetYear = currentYear;

                  if (targetMonth < 1) {
                    targetMonth += 12;
                    targetYear -= 1;
                  }

                  return DateFormat.MMMM()
                      .format(DateTime(targetYear, targetMonth));
                });
                return Text(months[value.toInt()]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<int, double>> fetchYearlyCounts(String location) async {
    final dbHelper = CropSightDatabase(); // Database instance
    int currentYear = DateTime.now().year;

    // Create a map to store counts for the last 4 years
    Map<int, double> yearlyCounts = {};

    for (int i = 3; i >= 0; i--) {
      int targetYear = currentYear - i;

      // Fetch the count for the specific year
      String countString = await dbHelper.countEntriesByLocationAndYear(
          location, targetYear.toString());
      double count = double.tryParse(countString) ?? 0.0;

      yearlyCounts[targetYear] = count;
    }

    return yearlyCounts;
  }

  Widget _buildYearlyChart() {
    double maxY = yearlyScan.values.reduce((a, b) => a > b ? a : b) *
        1.1; // Dynamic maxY with padding

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: yearlyScan.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: widget.locationColorCode,
                width: 16,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString()); // Year labels
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsectTotalChartBasedMonth() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barGroups: insectCounts.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: _getColorForInsect(entry.key),
                width: 16,
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  insectNames[value.toInt()],
                  maxLines: 2,
                  textAlign: TextAlign.center,
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

  Color _getColorForInsect(int index) {
    switch (index) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.purple;
      case 2:
        return Colors.brown;
      case 3:
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }

  double _getMaxY() {
    // Find the maximum value
    double maxValue =
        insectCounts.reduce((curr, next) => curr > next ? curr : next);

    // Add some padding (e.g., 10% more than the max)
    return maxValue * 1.1;
  }

  Widget _buildYearlyInsectChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxYY(),
        barGroups: yearlyInsectCounts.entries.map((yearEntry) {
          return BarChartGroupData(
            x: yearEntry.key,
            barRods: yearEntry.value.asMap().entries.map((insectEntry) {
              return BarChartRodData(
                toY: insectEntry.value,
                color: _getColorForInsect(insectEntry.key),
                width: 16,
              );
            }).toList(),
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // For the bottom titles, display the years
                return Text(value.toInt().toString());
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Display numbers on the left side
                return Text(value.toInt().toString(),
                    style: TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to calculate max Y value dynamically
  double _getMaxYY() {
    // Flatten all values and find the maximum
    double maxValue = yearlyInsectCounts.values
        .expand((list) => list)
        .reduce((curr, next) => curr > next ? curr : next);

    // Add some padding (e.g., 10% more than the max)
    return maxValue * 1.1;
  }

  Widget _buildCardLegend() {
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
                _buildLegendItem('Rice bug', _getColorForInsect(2)),
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
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
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
