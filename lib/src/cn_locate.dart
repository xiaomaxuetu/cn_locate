import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:cn_locate/cn_locate.dart';
import 'package:cn_locate/src/bean/location.dart';
import 'package:cn_locate/src/bean/mapoptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CnLocateInitCallBack = Function(InitResultInfo);

class CnLocate {
  static const MethodChannel _channel = MethodChannel('cn_locate');

  static final _onLocationChange = StreamController<AmapLocation>.broadcast();

  CnLocate._();
  static Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onLocationChange':
        AmapLocation _amapLocation = AmapLocation.fromJson(call.arguments);
        _onLocationChange.add(_amapLocation);
        break;
    }
  }

  static Stream<AmapLocation> get onLocationChange => _onLocationChange.stream;

  static void init(
      {CnLocateInitCallBack? callBack, required AMapOptions options}) {
    _channel.setMethodCallHandler(_handleMessages);
    var map = options.toJson();
    var resultBean;
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZonedGuarded(() async {
      final String result = await _channel.invokeMethod('initSdk', map);
      Map resultMap = json.decode(result);
      resultBean = InitResultInfo.fromJson(resultMap as Map<String, dynamic>);
      callBack!(resultBean);
    }, (error, stackTrace) {
      resultBean = InitResultInfo();
      callBack!(resultBean);
    });
    FlutterError.onError = (details) {
      if (details.stack == null) {
        FlutterError.presentError(details);
      }
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    };
  }

  static Future<Null> start() async {
    await _channel.invokeMethod('startLocate');
  }

  static Future<Null> stop() async {
    await _channel.invokeMethod('stopLocate');
  }
}
