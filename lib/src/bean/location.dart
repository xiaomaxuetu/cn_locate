import 'dart:convert';

class AmapLocation {
  num? latitude;
  num? longitude;
  num? altitude;
  num? speed;
  num? accuracy;
  String? provider;

  AmapLocation.fromJson(String jsonStr) {
    Map resultMap = json.decode(jsonStr);
    latitude = resultMap['latitude'];
    longitude = resultMap['longitude'];
    altitude = resultMap['altitude'];
    speed = resultMap['speed'];
    accuracy = resultMap['accuracy'];
    provider = resultMap['provider'];
  }
}
