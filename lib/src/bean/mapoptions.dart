class AMapOptions {
  LocationMode? locationMode;
  bool? isNeedAddress;
  bool? isOnceLocation;
  bool? isMockEnable;
  int? interval;
  bool? isGpsFirst;
  int? distanceFilter;
  String apiKey;
  AMapOptions(
      {required this.apiKey,
      this.locationMode = LocationMode.hightAccuracy,
      this.isNeedAddress = false,
      this.isOnceLocation = false,
      this.isMockEnable = true,
      this.interval = 5000,
      this.isGpsFirst = true,
      this.distanceFilter = 0});

  toJson() {
    Map<String, dynamic> map = {};
    map["locationMode"] = locationMode.toString();
    map["isNeedAddress"] = isNeedAddress;
    map["isOnceLocation"] = isOnceLocation;
    map["isMockEnable"] = isMockEnable;
    map["interval"] = interval;
    map["isGpsFirst"] = isGpsFirst;
    map["distanceFilter"] = distanceFilter;
    map["apiKey"] = apiKey;
    return map;
  }
}

enum LocationMode { batterySaving, deviceSensors, hightAccuracy }
