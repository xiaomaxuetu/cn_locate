import 'package:flutter/material.dart';
import 'package:cn_locate/cn_locate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('zh'),
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              //CnLocate.start();
              initLocation();
            },
            child: Text("点击定位"),
          ),
        ),
      ),
    );
  }

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
          print(event);
        });
      } else {
        openAppSettings();
      }
    }
    //}
  }

  showEnsureDiaolog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否前往后台开启定位权限"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: Text("确定"))
            ],
          );
        });
  }
}
