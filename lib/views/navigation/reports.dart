import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              )
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
                    trailing: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.delete),
                    ),
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
                    trailing: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.delete),
                    ),
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
