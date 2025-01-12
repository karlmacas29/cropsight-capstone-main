import 'dart:io';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/navigation/notifier/change_notifier.dart';
import 'package:cropsight/views/pages/history_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPages extends StatefulWidget {
  const HistoryPages({super.key});

  @override
  State<HistoryPages> createState() => _HistoryPagesState();
}

class _HistoryPagesState extends State<HistoryPages> {
  Future<List<Map<String, dynamic>>>? scanningHistoryData;
  bool isLoad = false;

  // Method to load the saved value from SharedPreferences
  _loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('selectedDropdownValue')) {
      setState(() {
        selectedValue = prefs.getString('selectedDropdownValue');
        _fetchData(); // Debug log
      });

      print("Loaded value: $selectedValue");
    } else {
      print("No value found in SharedPreferences");
    }
  }

  void updateLocation(String? newLocation) {
    setState(() {
      selectedValue = newLocation;
      _fetchData(); // Refetch data with new location
    });
  }

  String _currentSort = 'latest'; // Default sort option
  int _currentLimit = 10; // Default limit option
  String? selectedValue;

  void _fetchData() {
    if (selectedValue != null) {
      setState(() {
        scanningHistoryData = CropSightDatabase().getScanningHistory(
          sortBy: _currentSort,
          limit: _currentLimit,
          location: selectedValue.toString(),
        );
        isLoad = false;
      });
    } else {
      setState(() {
        isLoad = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.selectedLocation != selectedValue) {
      updateLocation(locationProvider.selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: isLoad
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    'Scan History',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildFilterControls(),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: scanningHistoryData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data found'));
                      }

                      // Build the ListView with fetched data
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var item = snapshot.data![index];
                          return ListTile(
                            onTap: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDataScreen(
                                    id: (item['id']).toString(),
                                    insectId: (item['insectId']).toString(),
                                    insectName: item['insectName'],
                                    insectDamage: item['insectDamage'],
                                    insectPic: File(item['insectPic']),
                                    insectPercent: item['insectPercent'],
                                    location: item['location'],
                                    month: item['month'],
                                    year: item['year'],
                                  ),
                                ),
                              );

                              if (res == 'deleted') {
                                setState(() {
                                  _fetchData();
                                });
                              }
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: (File(item['insectPic']).existsSync())
                                  ? Image.file(
                                      File(item['insectPic']),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.fill,
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 50),
                            ), // Adjust path handling as needed
                            title: Text(item['insectName']),
                            subtitle: Text(
                              '${item['insectDamage']} - ${item['month']}, ${item['year']}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Filter controls widget
  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sorting Dropdown
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
              dropdownColor: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(244, 253, 255, 1)
                  : const Color.fromRGBO(18, 18, 18, 1),
              value: _currentSort,
              items: const [
                DropdownMenuItem(value: 'latest', child: Text('Latest')),
                DropdownMenuItem(value: 'year', child: Text('By Year')),
                DropdownMenuItem(value: 'month', child: Text('By Month')),
              ],
              onChanged: (value) {
                setState(() {
                  _currentSort = value!;
                  _fetchData();
                });
              },
            ),
          ),

          // Limit Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: DropdownButton<int>(
              underline: Container(
                height: 0,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(244, 253, 255, 1)
                  : const Color.fromRGBO(18, 18, 18, 1),
              value: _currentLimit,
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 20, child: Text('20')),
                DropdownMenuItem(value: 50, child: Text('50')),
                DropdownMenuItem(
                    value: -1, child: Text('All')), // -1 for no limit
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentLimit =
                        value == -1 ? -1 : value; // Use -1 directly for 'All'
                    _fetchData();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
