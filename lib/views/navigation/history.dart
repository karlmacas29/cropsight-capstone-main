import 'dart:io';

import 'package:cropsight/controller/db_controller.dart';
import 'package:cropsight/views/pages/history_data.dart';
import 'package:flutter/material.dart';

class HistoryPages extends StatefulWidget {
  const HistoryPages({super.key});

  @override
  State<HistoryPages> createState() => _HistoryPagesState();
}

class _HistoryPagesState extends State<HistoryPages> {
  late Future<List<Map<String, dynamic>>> scanningHistoryData;
  String _currentSort = 'latest'; // Default sort option
  int _currentLimit = 10; // Default limit option

  @override
  void initState() {
    super.initState();
    _fetchData(); // Initial data fetch
  }

  void _fetchData() {
    setState(() {
      scanningHistoryData = CropSightDatabase().getScanningHistory(
        sortBy: _currentSort,
        limit: _currentLimit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryDataScreen(
                                insectId: (item['insectId']).toString(),
                                insectName: item['insectName'],
                                insectDamage: item['insectDamage'],
                                insectPic: File(item['insectPic']),
                                insectPercent: item['insectPercent'],
                                location: item['location'],
                                month: item['month'],
                                year: item['year']),
                          ),
                        );
                      },
                      leading: (File(item['insectPic']).existsSync())
                          ? Image.file(File(item['insectPic']),
                              width: 50, height: 50)
                          : const Icon(Icons.image_not_supported,
                              size: 50), // Adjust path handling as needed
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
          DropdownButton<String>(
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

          // Limit Dropdown
          DropdownButton<int>(
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
        ],
      ),
    );
  }
}
