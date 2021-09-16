# cn_locate

封装的原生flutter高德定位组件.

## 用法

```dart
import 'package:cn_locate/cn_locate.dart';
...
initLocation() async {
    // if (await Permission.location.serviceStatus.isEnabled) {
    //   var options = AMapOptions(
    //       locationMode: LocationMode.hightAccuracy, isNeedAddress: true);
    //   CnLocate.init(
    //       options: options,
    //       callBack: (result) {
    //         print("------sdk初始化${result.message}");
    //       });
    // } else {
    if (await Permission.locationWhenInUse.request().isGranted) {
      if (await Permission.locationAlways.request().isGranted) {
        var options = AMapOptions(
            locationMode: LocationMode.hightAccuracy,
            isNeedAddress: true,
            interval: 10000,
            isGpsFirst: true,
            isMockEnable: true,
            isOnceLocation: false,
            apiKey: "0f5ae242daaa662569c2806f426b7020");
        CnLocate.init(
            options: options,
            callBack: (result) {
              print("------sdk初始化${result.message}");
            });
        CnLocate.onLocationChange.listen((event) {
          print(event);//返回定位成功后的坐标
        });
      } else {
        openAppSettings();
      }
    }
    //}
  }
```

