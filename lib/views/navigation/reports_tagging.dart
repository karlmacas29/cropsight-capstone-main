import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/pages/reports_location.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/connection_ctrl.dart';
import 'report_graph/bargraph_r.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportsTaggingView extends StatefulWidget {
  const ReportsTaggingView({super.key});

  @override
  State<ReportsTaggingView> createState() => _ReportsTaggingViewState();
}

class _ReportsTaggingViewState extends State<ReportsTaggingView> {
  String formattedDate = DateFormat('E MMMM dd, y').format(DateTime.now());
  bool isMonthlyView = true;
  String selectedPeriod = 'Monthly';

  void startSyncListener() async {
    bool isConnected = await InternetConnectionChecker.instance.hasConnection;
    if (isConnected) {
      await SyncService().syncData();
    }
  }

  Future<void> _checkConnection() async {
    setState(() {
      _getData();
      isLoaded = true;
    });
    final conn = await InternetConnectionChecker.instance.hasConnection;
    if (mounted) {
      if (conn) {
        setState(() {
          isOnline = true;
        });
        await _getData();
        if (mounted) {
          setState(() {
            isLoaded = false;
          });
        }
      } else {
        setState(() {
          isOnline = false;
        });
        await _getData();
        if (mounted) {
          setState(() {
            isLoaded = false;
          });
        }
      }
    }
  }

  bool isOnline = false;
  bool isLoaded = true;

  List<LocationModel> locationsData = [];

  // Get the current month and year
  List<double> monthlyScan = [
    0,
    0,
    0,
    0,
  ];

  Map<int, List<double>> yearlyScan = {};

  Future<void> _getData() async {
    Future<bool> checkConnection() async {
      return await InternetConnectionChecker.instance.hasConnection;
    }

    LoadOnlineData loadOnlineData =
        LoadOnlineData(isOnline: await checkConnection());
    List<double> monthlyData = await loadOnlineData.fetchMonthlyData();
    Map<int, List<double>> yearlyData = await loadOnlineData.fetchYearlyData();
    List<LocationModel> locations = await loadOnlineData.initializeLocations();

    // Create DataModel
    DataModel dataModel = DataModel(
      monthlyScan: monthlyData,
      yearlyScan: yearlyData,
      locations: locations,
    );

    if (mounted) {
      setState(() {
        monthlyScan = dataModel.monthlyScan;
        yearlyScan = dataModel.yearlyScan;
        locationsData = dataModel.locations;
      });
    }
  }

  void _refreshData() async {
    await _getData();
    if (mounted) {
      setState(() {
        isLoaded = false;
      });
    }
  }

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

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

  //Data and Wifi chekcer

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40.h,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: DropdownButton<String>(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(18, 18, 18, 1)
                          : const Color.fromRGBO(244, 253, 255, 1),
                      fontWeight: FontWeight.bold,
                    ),
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
                // Refresh Button
                ElevatedButton.icon(
                  onPressed: isOnline
                      ? isLoaded
                          ? null
                          : () {
                              _checkConnection();
                            }
                      : null,
                  icon: isOnline
                      ? isLoaded
                          ? SizedBox(
                              width: 15.w,
                              height: 15.h,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            )
                          : Icon(
                              FluentIcons.arrow_sync_12_filled,
                              color: Colors.white,
                            )
                      : isLoaded
                          ? SizedBox(
                              width: 15.w,
                              height: 15.h,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            )
                          : Icon(
                              FluentIcons.arrow_sync_12_filled,
                              color: Colors.white,
                            ),
                  label: isOnline
                      ? isLoaded
                          ? Text(
                              'Loading',
                              style: TextStyle(fontSize: 12.sp),
                            )
                          : Text(
                              'Refresh',
                              style: TextStyle(fontSize: 12.sp),
                            )
                      : isLoaded
                          ? Text(
                              'Loading',
                              style: TextStyle(fontSize: 12.sp),
                            )
                          : Text(
                              'Offline',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                )
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Scans',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: isMonthlyView
                  ? buildMonthlyChart(
                      context: context,
                      isOnline: isOnline,
                      isLoad: isLoaded,
                      monthlyScan: monthlyScan,
                    )
                  : buildYearlyChart(
                      context: context,
                      isOnline: isOnline,
                      isLoad: isLoaded,
                      yearlyScan: yearlyScan,
                    ),
            ),
            const SizedBox(height: 5),

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
                itemCount: locationsData.length,
                itemBuilder: (context, index) {
                  return _buildLocationCard(locationsData[index], isLoaded);
                },
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

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
    return num.toStringAsFixed(0);
  }

  Widget _buildLocationCard(LocationModel location, bool isLoad) {
    return InkWell(
      onTap: !isLoad
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationReportScreen(
                    locationName: location.name,
                    locationColorCode: location.color,
                  ),
                ),
              );
            }
          : null,
      child: Skeletonizer(
        enabled: isLoad,
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
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // const SizedBox(height: 5),
              Text(
                _formatNumber(double.parse(location.totalScans.toString())),
                style: TextStyle(
                  fontSize: 25.sp,
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
      ),
    );
  }
}
