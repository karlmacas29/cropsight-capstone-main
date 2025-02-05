import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cropsight/controller/connection_ctrl.dart';
import 'package:cropsight/views/navigation/report_graph/bargraph_r.dart';
import 'package:cropsight/views/navigation/report_graph/bargraph_r_location.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
  bool isLoad = true;
  bool isOnline = false;

  // List to store insect counts
  List<double> insectCounts = [0, 0, 0, 0];
  // Map to store insect counts for each year
  Map<int, List<double>> yearlyInsectCounts = {
    DateTime.now().year - 3: [0, 0, 0, 0],
    DateTime.now().year - 2: [0, 0, 0, 0],
    DateTime.now().year - 1: [0, 0, 0, 0],
    DateTime.now().year: [0, 0, 0, 0],
  };

  // Insect names in the same order as the counts
  List<String> insectNames = [
    'Green Leafhopper',
    'Stem Borer',
    'Rice Bugs',
    'Rice Leaffolder',
  ];

  Future<void> _fetchInsectData(String loct) async {
    final conn = await InternetConnectionChecker.instance.hasConnection;
    LoadOnlineData loadOnlineData = LoadOnlineData(isOnline: conn);

    // Fetch data and build the DataModel
    DataModelInsect dataModel = await loadOnlineData.buildDataModel(loct);
    CountLocDataModel countLocDataModel =
        await loadOnlineData.buildCountDataModel(loct);

    debugPrint(dataModel.toString());
    if (mounted) {
      setState(() {
        yearlyInsectCounts = dataModel.yearlyInsectCounts;
        insectCounts = dataModel.insectCounts;
        //==================//
        monthlyInsectScan = countLocDataModel.monthlyCounts;
        yearlyScan = countLocDataModel.yearlyCounts;
      });
    }
  }

  List<double> monthlyInsectScan = [0, 0, 0, 0]; // Default empty data
  Map<int, List<double>> yearlyScan = {};

  Future<void> _checkConnection() async {
    setState(() {
      _fetchInsectData(widget.locationName);
      isLoad = true;
    });
    final conn = await InternetConnectionChecker.instance.hasConnection;
    if (mounted) {
      if (conn) {
        setState(() {
          isOnline = true;
        });
        await _fetchInsectData(widget.locationName);
        if (mounted) {
          setState(() {
            isLoad = false;
          });
        }
      } else {
        setState(() {
          isOnline = false;
        });
        await _fetchInsectData(widget.locationName);
        if (mounted) {
          setState(() {
            isLoad = false;
          });
        }
      }
    }
  }

  void _refreshData() async {
    await _fetchInsectData(widget.locationName);

    if (mounted) {
      setState(() {
        isLoad = false;
      });
    }
  }

  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    debugPrint('Connectivity changed: $_connectionStatus');
    _checkConnection();
    _refreshData();
  }

  @override
  void initState() {
    initConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        title: Text(
          "Brgy. ${widget.locationName}, Panabo City",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    onPressed: isOnline
                        ? isLoad
                            ? null
                            : () {
                                _checkConnection();
                              }
                        : null,
                    icon: Icon(
                      isOnline
                          ? isLoad
                              ? FluentIcons.arrow_sync_12_filled //isload
                              : FluentIcons.arrow_sync_12_filled
                          : FluentIcons.wifi_off_24_regular,
                      color: Colors.white,
                    ),
                    label: isOnline
                        ? isLoad
                            ? Text('Loading')
                            : Text('Refresh')
                        : Text('Offline'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Scan Report',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: isMonthlyView
                    ? buildMonthlyChart(
                        context: context,
                        isOnline: isOnline,
                        isLoad: isLoad,
                        monthlyScan: monthlyInsectScan,
                      )
                    : buildYearlyChart(
                        context: context,
                        isOnline: isOnline,
                        isLoad: isLoad,
                        yearlyScan: yearlyScan,
                      ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Scan in ${isMonthlyView ? rightTitle : 'Years'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 10.5),
              Expanded(
                child: isMonthlyView
                    ? buildInsectTotalChartBasedMonth(
                        context: context,
                        insectName: insectNames,
                        insectCounts: insectCounts,
                        isLoad: isLoad,
                      )
                    : buildYearlyInsectChart(
                        context: context,
                        yearlyInsectCounts: yearlyInsectCounts,
                        isLoad: isLoad,
                      ),
              ),
              const SizedBox(height: 16),
              buildCardLegend(context),
              const SizedBox(height: 16),
            ],
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
