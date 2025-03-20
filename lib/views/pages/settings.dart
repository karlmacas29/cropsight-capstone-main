import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restart_app/restart_app.dart';

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
  String _currentLanguage = 'en';
  final LanguagePreference _languagePreference = LanguagePreference();

  Future<void> _loadLanguagePreference() async {
    await _languagePreference.init();
    setState(() {
      _currentLanguage = _languagePreference.languageCode;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

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
                title: Text(
                  'About this app',
                  style: TextStyle(fontSize: 17.sp),
                ),
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
                        textStyle: TextStyle(fontSize: 17.sp),
                        value: choice,
                        child: Text(
                          choice,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  'Choose Language',
                  style: TextStyle(fontSize: 14.sp),
                ),
                trailing: Container(
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
                    ),
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.light
                            ? const Color.fromRGBO(244, 253, 255, 1)
                            : const Color.fromRGBO(18, 18, 18, 1),
                    value: _currentLanguage,
                    icon: const Icon(
                      Icons.language,
                    ),
                    elevation: 16,
                    underline: Container(
                      height: 0,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _currentLanguage) {
                        _showRestartDialog(context, newValue);
                      }
                    },
                    items: <Map<String, String>>[
                      {'code': 'en', 'name': 'English'},
                      {'code': 'cb', 'name': 'Cebuano (Bisaya)'},
                    ].map<DropdownMenuItem<String>>(
                        (Map<String, String> value) {
                      return DropdownMenuItem<String>(
                        value: value['code'],
                        child: Text(value['name']!),
                      );
                    }).toList(),
                  ),
                ),
              )
            ]);
          }),
        ),
      ),
    );
  }

  Future<void> _showRestartDialog(
      BuildContext context, String languageCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromRGBO(244, 253, 255, 1)
              : const Color.fromRGBO(18, 18, 18, 1),
          title: const Text('Change Language'),
          content: const Text(
              'You need to restart the app to change the language. Do you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed'),
              onPressed: () {
                _languagePreference.setLanguage(languageCode);
                setState(() {
                  _currentLanguage = languageCode;
                });
                Navigator.of(context).pop();
                // Here you might want to implement app restart logic
                // For example, using a package like restart_app
                // Or by navigating to a splash screen and reinitializing the app
                Restart.restartApp();
              },
            ),
          ],
        );
      },
    );
  }
}

const String LANGUAGE_CODE = 'languageCode';

class LanguagePreference {
  // Singleton instance
  static final LanguagePreference _instance = LanguagePreference._internal();
  factory LanguagePreference() => _instance;
  LanguagePreference._internal();

  // Default language
  String _languageCode = 'en';
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(LANGUAGE_CODE) ?? 'en';
    _isInitialized = true;
  }

  String get languageCode => _languageCode;

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, code);
    _languageCode = code;
  }
}
