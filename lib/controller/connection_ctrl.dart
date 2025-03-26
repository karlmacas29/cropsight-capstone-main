import 'package:cropsight/controller/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataModel {
  final List<double> monthlyScan;
  final Map<int, List<double>> yearlyScan;
  final List<LocationModel> locations;

  DataModel({
    required this.monthlyScan,
    required this.yearlyScan,
    required this.locations,
  });
}

class DataModelInsect {
  final List<String> insectNames;
  final List<double> insectCounts;
  final Map<int, List<double>> yearlyInsectCounts;

  DataModelInsect({
    required this.insectNames,
    required this.insectCounts,
    required this.yearlyInsectCounts,
  });
}

class CountLocDataModel {
  final List<double> monthlyCounts;
  final Map<int, List<double>> yearlyCounts;

  CountLocDataModel({
    required this.monthlyCounts,
    required this.yearlyCounts,
  });
}

class LoadOnlineData {
  final List<double> monthlyScan = [0, 0, 0, 0];
  late bool isOnline;

  LoadOnlineData({required this.isOnline});

  Future<dynamic> _getDatabaseHelper(bool isOn) async {
    if (isOn) {
      return OnlineDatabase();
    } else {
      return CropSightDatabase();
    }
  }

//----------------------------------------
  int _getMonthIndex(int month, int currentMonth) {
    int diff = currentMonth - month;
    return 3 - diff;
  }

  Future<List<double>> fetchMonthlyData() async {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    final months = [
      _getPreviousMonth(currentMonth, 3),
      _getPreviousMonth(currentMonth, 2),
      _getPreviousMonth(currentMonth, 1),
      {'month': currentMonth, 'year': currentYear}
    ];

    for (int i = 0; i < months.length - 1; i++) {
      if (months[i]['month'] > currentMonth) {
        months[i]['year'] = currentYear - 1;
      } else {
        months[i]['year'] = currentYear;
      }
    }

    for (int i = 0; i < months.length; i++) {
      await _fetchCountForMonth(months[i]);
    }

    return monthlyScan;
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
    final dbHelper = await _getDatabaseHelper(isOnline);

    try {
      String monthName = DateFormat.MMMM()
          .format(DateTime(monthData['year'], monthData['month']));

      String count = await dbHelper.countEntriesByMonth(
          monthName, monthData['year'].toString());
      double doubleValue = double.tryParse(count) ?? 0.0;

      int index = _getMonthIndex(monthData['month'], DateTime.now().month);

      if (index >= 0 && index < monthlyScan.length) {
        monthlyScan[index] = doubleValue;
      } else {
        debugPrint('Index out of bounds: $index');
      }

      debugPrint(
          'Number of entries in $monthName ${monthData['year']}: $count');
    } catch (e) {
      debugPrint(
          'Error fetching count for month ${monthData['month']} and year ${monthData['year']}: $e');
    }
  }

  final Map<int, List<double>> yearlyScan = {
    DateTime.now().year - 3: [0],
    DateTime.now().year - 2: [0],
    DateTime.now().year - 1: [0],
    DateTime.now().year: [0],
  };

  List<LocationModel> locations = [];

  Future<Map<int, List<double>>> fetchYearlyData() async {
    final currentYear = DateTime.now().year;
    final years = [
      currentYear - 3,
      currentYear - 2,
      currentYear - 1,
      currentYear
    ];

    for (var year in years) {
      await _fetchCountForYear(year.toString());
    }

    return yearlyScan;
  }

  Future<void> _fetchCountForYear(String yr) async {
    final dbHelper = await _getDatabaseHelper(isOnline);

    try {
      int count = await dbHelper.countEntriesByYear(yr);
      double doubleValue = count.toDouble();

      int yearKey = int.parse(yr);

      if (yearlyScan.containsKey(yearKey)) {
        yearlyScan[yearKey]?[0] = doubleValue;
      }

      debugPrint('Number of entries in $yr: $count');
    } catch (e) {
      debugPrint('Error fetching count for year $yr: $e');
    }
  }

  Future<List<LocationModel>> initializeLocations() async {
    try {
      locations = [
        LocationModel(name: 'Southern', totalScans: 0, color: Colors.green),
        LocationModel(name: 'Consolacion', totalScans: 0, color: Colors.green),
        LocationModel(name: 'Quezon', totalScans: 0, color: Colors.green),
        LocationModel(name: 'Nanyo', totalScans: 0, color: Colors.green),
      ];

      await Future.wait([
        _fetchTotalScansForLocation('Southern'),
        _fetchTotalScansForLocation('Consolacion'),
        _fetchTotalScansForLocation('Quezon'),
        _fetchTotalScansForLocation('Nanyo'),
      ]);

      return locations;
    } catch (e) {
      debugPrint('Error initializing locations: $e');
      return [];
    }
  }

  Future<void> _fetchTotalScansForLocation(String locationName) async {
    final dbHelper = await _getDatabaseHelper(isOnline);
    try {
      String count = await dbHelper.countEntriesByLocation(locationName);
      int index = locations.indexWhere((loc) => loc.name == locationName);
      if (index != -1) {
        locations[index] =
            locations[index].copyWith(totalScans: int.tryParse(count) ?? 0);
      }
    } catch (e) {
      debugPrint('Error fetching scans for $locationName: $e');
    }
  }

  // Insect Data Fetch-------------------------------------------------------

  // Insect names in the same order as the counts
  final List<String> insectNames = [
    'Green Leafhopper',
    'Stem Borer',
    'Rice Bugs',
    'Rice Leaffolder',
  ];

  Future<List<double>> fetchInsectCounts(String loc) async {
    final dbHelper = await _getDatabaseHelper(isOnline);
    final List<double> insectCounts = [0, 0, 0, 0];

    try {
      // Get current month and year, and format the month
      String currentMonth = DateFormat('MMMM').format(DateTime.now());
      String currentYear = DateFormat('yyyy').format(DateTime.now());
      String currentLocation = loc; // You can make this dynamic if needed

      // Fetch counts for the given location, month, and year
      Map<String, int> counts = await dbHelper.countEntriesByLocationAndInsect(
          currentLocation, currentMonth, currentYear);

      // Update insect counts in the same order as insectNames
      insectCounts[0] = (counts['Green Leafhopper'] ?? 0).toDouble();
      insectCounts[1] = (counts['Stem Borer'] ?? 0).toDouble();
      insectCounts[2] = (counts['Rice Bugs'] ?? 0).toDouble();
      insectCounts[3] = (counts['Green leaffolder'] ?? 0).toDouble();

      // debugPrint the counts for debugging
      insectNames.asMap().forEach((index, name) {
        debugPrint(
            '$name count in $currentLocation by $currentMonth $currentYear: ${insectCounts[index]}');
      });
    } catch (e) {
      debugPrint('Error fetching insect counts: $e');
    }

    return insectCounts;
  }

  Future<Map<int, List<double>>> fetchYearlyInsectCounts(String loc) async {
    final dbHelper = await _getDatabaseHelper(isOnline);
    final Map<int, List<double>> yearlyInsectCounts = {
      DateTime.now().year - 3: [0, 0, 0, 0],
      DateTime.now().year - 2: [0, 0, 0, 0],
      DateTime.now().year - 1: [0, 0, 0, 0],
      DateTime.now().year: [0, 0, 0, 0],
    };

    try {
      // Fetch counts for the current location and years
      String currentLocation = loc; // You can make this dynamic if needed
      final years = yearlyInsectCounts.keys.toList();

      // Fetch counts for each year
      for (var year in years) {
        Map<String, int> counts =
            await dbHelper.countEntriesByLocationAndInsectForYear(
                currentLocation, year.toString());

        // Update insect counts in the same order as insectNames
        yearlyInsectCounts[year]?[0] =
            (counts['Green Leafhopper'] ?? 0).toDouble();
        yearlyInsectCounts[year]?[1] = (counts['Stem Borer'] ?? 0).toDouble();
        yearlyInsectCounts[year]?[2] = (counts['Rice Bugs'] ?? 0).toDouble();
        yearlyInsectCounts[year]?[3] =
            (counts['Green leaffolder'] ?? 0).toDouble();

        // debugPrint the counts for debugging
        debugPrint('Counts for year $year:');
        insectNames.asMap().forEach((index, name) {
          debugPrint('$name count: ${yearlyInsectCounts[year]?[index]}');
        });
      }
    } catch (e) {
      debugPrint('Error fetching yearly insect counts: $e');
    }

    return yearlyInsectCounts;
  }

  // Get the current month and year
  Future<DataModelInsect> buildDataModel(String loc) async {
    final List<String> insectNames = [
      'Green Leafhopper',
      'Stem Borer',
      'Rice Bugs',
      'Rice Leaffolder',
    ];

    final List<double> insectCounts = await fetchInsectCounts(loc);
    final Map<int, List<double>> yearlyInsectCounts =
        await fetchYearlyInsectCounts(loc);

    return DataModelInsect(
      insectNames: insectNames,
      insectCounts: insectCounts,
      yearlyInsectCounts: yearlyInsectCounts,
    );
  }

  // Get the current month and year based on location-------------------------------

  Future<List<double>> fetchMonthlyCounts(String location) async {
    final dbHelper = await _getDatabaseHelper(isOnline);

    // List to store counts for the last three months and current month
    List<double> counts = [];

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
      counts.add(count.toDouble()); // Convert int to double
    }

    return counts;
  }

  Future<Map<int, List<double>>> fetchYearlyCounts(String location) async {
    final dbHelper = await _getDatabaseHelper(isOnline);
    int currentYear = DateTime.now().year;

    // Create a map to store counts for the last 4 years
    Map<int, List<double>> yearlyCounts = {};

    for (int i = 3; i >= 0; i--) {
      int targetYear = currentYear - i;

      // Fetch the count for the specific year
      String countString = await dbHelper.countEntriesByLocationAndYear(
          location, targetYear.toString());
      double count = double.tryParse(countString) ?? 0.0;

      yearlyCounts[targetYear] = [count]; // Store count in a list
    }

    return yearlyCounts;
  }

  Future<CountLocDataModel> buildCountDataModel(String location) async {
    final List<double> monthlyCounts = await fetchMonthlyCounts(location);
    final Map<int, List<double>> yearlyCounts =
        await fetchYearlyCounts(location);

    return CountLocDataModel(
      monthlyCounts: monthlyCounts,
      yearlyCounts: yearlyCounts,
    );
  }
}

class LocationModel {
  final String name;
  final int totalScans;
  final Color color;

  LocationModel({
    required this.name,
    required this.totalScans,
    required this.color,
  });

  LocationModel copyWith({
    String? name,
    int? totalScans,
    Color? color,
  }) {
    return LocationModel(
      name: name ?? this.name,
      totalScans: totalScans ?? this.totalScans,
      color: color ?? this.color,
    );
  }
}
