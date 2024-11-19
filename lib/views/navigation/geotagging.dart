import 'package:flutter/material.dart';

class GeotaggingMapView extends StatefulWidget {
  const GeotaggingMapView({super.key});

  @override
  State<GeotaggingMapView> createState() => _GeotaggingMapViewState();
}

class _GeotaggingMapViewState extends State<GeotaggingMapView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Geotagging'),
        ],
      ),
    );
  }
}
