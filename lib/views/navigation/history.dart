import 'package:flutter/material.dart';

class HistoryPages extends StatefulWidget {
  const HistoryPages({super.key});

  @override
  State<HistoryPages> createState() => _HistoryPagesState();
}

class _HistoryPagesState extends State<HistoryPages> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Scanning History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ), //scanning
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/greenleafhopper/1s.jpg'),
                    ),
                    title: Text('Green LeafHopper'),
                    subtitle: Text('Damage: Tungro Virus'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/greenleafhopper/1s.jpg'),
                    ),
                    title: Text('Green LeafHopper'),
                    subtitle: Text('Damage: Tungro Virus'),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
