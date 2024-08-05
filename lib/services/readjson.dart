import 'package:cropsight/services/insectjson.dart';
import 'package:flutter/services.dart';

class RemoteJson {
  Future<Insects> allData() async {
    var response =
        await rootBundle.loadString('assets/resources/cropsight.json');

    if (response.isNotEmpty) {
      Insects data = insectsFromJson(response);
      return data;
    } else {
      throw Exception('Error getting Json');
    }
  }
}
