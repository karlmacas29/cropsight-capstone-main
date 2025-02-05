import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/navigation/notifier/change_notifier.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:cropsight/views/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void startSyncListener() async {
  bool isConnected = await InternetConnectionChecker.instance.hasConnection;
  if (isConnected) {
    await SyncService().syncData();
  }
}

//Data and Wifi chekcer
List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
final Connectivity _connectivity = Connectivity();
late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
  _connectionStatus = result;

  // ignore: avoid_print
  debugPrint('Connectivity changed: $_connectionStatus');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final db = CropSightDatabase();
  try {
    // This will only populate if the database is empty
    await db.populateDatabase();
    debugPrint('Database initialization complete');
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }

  startSyncListener();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
  _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CropSight App',
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeProvider.themeMode,
        home: const SplashScreen(),
      );
    });
  }
}

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;

  ConnectivityProvider() {
    _checkConnection();
  }

  bool get isConnected => _isConnected;

  void _checkConnection() async {
    _isConnected = await InternetConnectionChecker.instance.hasConnection;
    notifyListeners();

    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      _isConnected = status == InternetConnectionStatus.connected;
      notifyListeners();
      if (_isConnected) {
        // Refresh data from Supabase
        _refreshData();
      }
    });
  }

  void _refreshData() {
    // Implement your data refresh logic here
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
