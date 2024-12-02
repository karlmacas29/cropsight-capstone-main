import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cropsight/views/navigation/cropsight.dart';
import 'package:cropsight/views/navigation/reports_tagging.dart';
import 'package:cropsight/views/navigation/home.dart';
import 'package:cropsight/views/navigation/history.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageNav extends StatefulWidget {
  const HomePageNav({super.key});

  @override
  State<HomePageNav> createState() => _HomePageNavState();
}

class _HomePageNavState extends State<HomePageNav> {
  int _currentIndex = 0;
  final tabsnav = [
    const HomeTab(),
    const CropsightTab(),
    const HistoryPages(),
    const ReportsTaggingView(),
  ];

  final _iconappbar = [
    FluentIcons.home_12_regular,
    FluentIcons.book_search_24_regular,
    FluentIcons.history_24_regular,
    FluentIcons.clipboard_data_bar_20_regular,
  ];

  final _iconFilled = [
    FluentIcons.home_12_filled,
    FluentIcons.book_search_24_filled,
    FluentIcons.history_24_filled,
    FluentIcons.clipboard_data_bar_20_filled,
  ];

  final _titleAppbar = [
    'Home',
    'Cropsight',
    'History',
    'Reports',
  ];

  final List<String> dropdownItems = [
    'Panabo',
    'Carmen',
    'Dujali',
    'Nanyo',
  ];

  String? selectedValue = 'Panabo';

  // Method to load the saved value from SharedPreferences
  _loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('selectedDropdownValue')) {
      setState(() {
        selectedValue = prefs.getString('selectedDropdownValue');
      });
      print("Loaded value: $selectedValue"); // Debug log
    } else {
      print("No value found in SharedPreferences");
    }
  }

  // Method to save the selected value to SharedPreferences
  _saveValue(String? value) async {
    if (value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDropdownValue', value);
      print("Saved value: $value");
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the saved value when the widget is first initialized
    _loadSavedValue();
    print('Location $selectedValue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(244, 253, 255, 1)
          : const Color.fromARGB(255, 41, 41, 41),
      appBar: PreferredSize(
        preferredSize: const Size.square(80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(244, 253, 255, 1)
                  : const Color.fromARGB(255, 41, 41, 41),
              scrolledUnderElevation: 0.0,
              actions: [
                DropdownButton<String>(
                  iconEnabledColor: Colors.green,
                  icon: const Icon(FluentIcons.location_12_filled),
                  dropdownColor:
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(244, 253, 255, 1)
                          : const Color.fromRGBO(18, 18, 18, 1),
                  hint: const Text('Location?'),
                  value: selectedValue,
                  items: dropdownItems.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                    // Save the new value
                    _saveValue(newValue);
                    // Print the current selected value
                    print('Selected value: $selectedValue');

                    _loadSavedValue();
                  },
                ),
                IconButton(
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsApp(),
                      ),
                    );
                  },
                  icon: const Icon(FluentIcons.settings_24_regular),
                )
              ],
              leadingWidth: 28,
              leading: Icon(
                _iconappbar[_currentIndex],
                color: const Color.fromRGBO(86, 144, 51, 1),
                size: 42,
              ),
              title: Text(
                _titleAppbar[_currentIndex],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: tabsnav[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        splashColor: Colors.green,
        splashRadius: 30,
        elevation: 15,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(244, 253, 255, 1)
            : const Color.fromARGB(255, 41, 41, 41),
        height: 80,
        gapLocation: GapLocation.none,
        activeIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: tabsnav.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? _iconFilled[index] : _iconappbar[index],
                color: isActive ? Colors.green : null,
              ),
              Text(
                _titleAppbar[index],
                style: TextStyle(
                  color: isActive ? Colors.green : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
