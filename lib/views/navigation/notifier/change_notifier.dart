import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  String? _selectedLocation;

  String? get selectedLocation => _selectedLocation;

  void updateLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }
}
