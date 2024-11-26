import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cropsight/views/navigation/cropsight.dart';
import 'package:cropsight/views/navigation/reports_tagging.dart';
import 'package:cropsight/views/navigation/home.dart';
import 'package:cropsight/views/navigation/history.dart';
import 'package:cropsight/views/navigation/settings.dart';
import 'package:flutter/material.dart';

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
    Icons.home_rounded,
    Icons.auto_stories,
    Icons.list_alt,
    Icons.analytics,
  ];

  final _titleAppbar = [
    'Home',
    'Cropsight',
    'History',
    'Reports',
  ];

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
                    icon: const Icon(Icons.settings))
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
                _iconappbar[index],
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
