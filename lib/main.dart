import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:cropsight/views/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = CropSightDatabase();
  try {
    // This will only populate if the database is empty
    await db.populateDatabase();
    print('Database initialization complete');
  } catch (e) {
    print('Error initializing database: $e');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
