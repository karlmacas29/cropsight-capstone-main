import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cropsight/views/navigation/cropsight.dart';
import 'package:cropsight/views/navigation/notifier/change_notifier.dart';
import 'package:cropsight/views/navigation/reports_tagging.dart';
import 'package:cropsight/views/navigation/home.dart';
import 'package:cropsight/views/navigation/history.dart';
import 'package:cropsight/views/pages/settings.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageNav extends StatefulWidget {
  const HomePageNav({super.key});

  @override
  State<HomePageNav> createState() => _HomePageNavState();
}

class _HomePageNavState extends State<HomePageNav> {
  int _currentIndex = 0;
  late List<Widget> tabsnav;

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
    'Rice Pest',
    'History',
    'Reports',
  ];

  final List<String> dropdownItems = [
    'Southern',
    'Datu Abdul',
    'Quezon',
    'Nanyo',
  ];

  String? selectedValue;

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
  // _saveValue(String? value) async {
  //   if (value != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('selectedDropdownValue', value);
  //     print("Saved value: $value");
  //   }
  // }

  bool isHide() {
    if (_titleAppbar[_currentIndex] == 'Rice Pest' ||
        _titleAppbar[_currentIndex] == 'Reports') {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    // Load the saved value when the widget is first initialized
    _loadSavedValue();
    print('Location $selectedValue');
    super.initState();
    //
    tabsnav = [
      const HomeTab(),
      const CropsightTab(),
      const HistoryPages(),
      const ReportsTaggingView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
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
                isHide()
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal:5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(35, 76, 175, 79),
                          ),
                          child: DropdownButton<String>(
                            alignment: AlignmentDirectional.center,
                            icon: Visibility(
                                visible: false,
                                child: Icon(Icons.arrow_downward)),
                            iconSize: 0,
                            underline: SizedBox.shrink(),
                            hint: Text(
                              'Location?',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            value: selectedValue ??
                                locationProvider.selectedLocation,
                            items: dropdownItems.map((String value) {
                              return DropdownMenuItem<String>(
                                alignment: AlignmentDirectional.center,
                                value: value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      FluentIcons.location_12_filled,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    Text(
                                      "$value, Panabo",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: null,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
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
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
