import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsTaggingView extends StatefulWidget {
  const ReportsTaggingView({super.key});

  @override
  State<ReportsTaggingView> createState() => _ReportsTaggingViewState();
}

class _ReportsTaggingViewState extends State<ReportsTaggingView> {
  final List<LocationData> locations = [
    LocationData(name: 'Carmen', totalScans: 5, color: Colors.pink),
    LocationData(name: 'Panabo', totalScans: 7, color: Colors.blue),
    LocationData(name: 'Dujali', totalScans: 5, color: Colors.amber),
    LocationData(name: 'Davao', totalScans: 12, color: Colors.teal),
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Line Chart
            const Text(
              'Total Scan',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildBarChart(),
            const SizedBox(height: 20),

            // Location Cards
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return _buildLocationCard(locations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return _getBottomTitles(value);
                  },
                  reservedSize: 38,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.black26,
                width: 1,
              ),
            ),
            barGroups: _generateBarGroups(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            maxY: 20,
          ),
        ),
      ),
    );
  }

  Widget _getBottomTitles(double value) {
    final locations = ['Carmen', 'Panabo', 'Dujali', 'Davao'];
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Text(
        locations[value.toInt()],
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return locations.asMap().entries.map((entry) {
      int index = entry.key;
      LocationData location = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: location.totalScans.toDouble(),
            color: location.color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: location.color.withOpacity(0.7),
              width: 2,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLocationCard(LocationData location) {
    return Card(
      color: location.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            location.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${location.totalScans}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'Total Scans',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Location data model
class LocationData {
  final String name;
  final int totalScans;
  final Color color;

  LocationData(
      {required this.name, required this.totalScans, required this.color});
}
