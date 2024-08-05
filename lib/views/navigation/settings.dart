import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('themeMode') ?? 'system';
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.light) {
      prefs.setString('themeMode', 'light');
    } else if (themeMode == ThemeMode.dark) {
      prefs.setString('themeMode', 'dark');
    } else {
      prefs.setString('themeMode', 'system');
    }
    notifyListeners();
  }
}

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  Icon? icon;
  Text? label;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Theme.of(context).brightness == Brightness.light) {
      setState(() {
        icon = const Icon(Icons.sunny);
        label = const Text('Theme Mode (Light Mode)');
      });
    } else {
      setState(() {
        icon = const Icon(Icons.dark_mode);
        label = const Text('Theme Mode (Dark Mode)');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(244, 253, 255, 1)
          : const Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(244, 253, 255, 1)
            : const Color.fromRGBO(18, 18, 18, 1),
        automaticallyImplyLeading: true,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: Center(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 1,
          itemBuilder: ((context, index) {
            return Column(children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About this app'),
                onTap: () {},
              ),
              ListTile(
                leading: icon,
                title: label,
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.settings),
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromRGBO(244, 253, 255, 1)
                      : const Color.fromRGBO(18, 18, 18, 1),
                  onSelected: (value) {
                    if (value == 'light') {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(ThemeMode.light);
                    } else if (value == 'dark') {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(ThemeMode.dark);
                    } else {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(ThemeMode.system);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'light', 'dark', 'system'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              )
            ]);
          }),
        ),
      ),
    );
  }
}
