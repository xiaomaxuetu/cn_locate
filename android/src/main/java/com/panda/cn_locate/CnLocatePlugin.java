package com.panda.cn_locate;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.content.ContextCompat;
import androidx.core.content.PermissionChecker;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.panda.cn_locate.bean.InitResultInfo;
import com.panda.cn_locate.bean.Location;
import com.panda.cn_locate.util.JsonUtil;
import com.panda.cn_locate.util.MapUtil;

import java.security.Permission;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** CnLocatePlugin */
public class CnLocatePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;
  private Activity activity;
  //声明AMapLocationClient类对象
  public AMapLocationClient mLocationClient = null;


  // key 69f824bf2b9f251307bd384abdaef90e
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "cn_locate");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if(call.method.equals("initSdk")){

       String locationMode =  call.argument("locationMode");
       boolean isNeedAddress = call.argument("isNeedAddress");
       boolean isOnceLocation = call.argument("isOnceLocation");
       boolean isMockEnable = call.argument("isMockEnable");
       Integer interval = call.argument("interval");
       boolean isGpsFirst = call.argument("isGpsFirst");
      Integer distanceFilter = call.argument("distanceFilter");

      mLocationClient = new AMapLocationClient(context);
      //初始化定位参数
      AMapLocationClientOption option = new AMapLocationClientOption();

      //设置定位模式为高精度模式，Battery_Saving为低功耗模式，Device_Sensors是仅设备模式
      if(locationMode != null ){
        if(locationMode.contains("LocationMode.hightAccuracy")){
          option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
        }else  if(locationMode.contains("LocationMode.deviceSensors")){
          option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Device_Sensors);
        }else  if(locationMode.contains("LocationMode.batterySaving")){
          option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
        }
      }
      option.setDeviceModeDistanceFilter(distanceFilter);

      //设置是否返回地址信息（默认返回地址信息）
      if(isNeedAddress){
        option.setNeedAddress(false);
      }


      //设置是否只定位一次,默认为false
      if(isOnceLocation)
      option.setOnceLocation(true);

      //设置是否允许模拟位置,默认为false，不允许模拟位置
      if(isMockEnable)
      option.setMockEnable(true);

      //设置定位间隔,单位毫秒,默认为2000ms
      if(interval != null){
        option.setInterval(interval);
      }


      //设置是否优先返回GPS定位信息,默认值：false,只有在高精度定位模式下的单次定位有效
      if(isGpsFirst)
      option.setGpsFirst(true);

      //给定位客户端对象设置定位参数
      mLocationClient.setLocationOption(option);

      mLocationClient.setLocationListener(new AMapLocationListener() {
        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
            Location location = new Location();
            location.setLatitude(aMapLocation.getLatitude());
            location.setLongitude(aMapLocation.getLongitude());
            location.setAccuracy(aMapLocation.getAccuracy());
            location.setProvider(aMapLocation.getProvider());
            location.setSpeed(aMapLocation.getSpeed());
            channel.invokeMethod("onLocationChange",JsonUtil.toJson(MapUtil.deepToMap(location)));
        }
      });
      if(hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)){
        mLocationClient.startLocation();
        String  json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(true,"开启定位成功")));
        result.success(json);
      }else {
        String  json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(false,"定位未授权")));
        result.success(json);
      }

    }else if(call.method.equals("startLocate")){
      mLocationClient.startLocation();
    }else if(call.method.equals("stopLocate")){
      mLocationClient.stopLocation();
    }else {
      result.notImplemented();
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private boolean hasPermission(String permission){
    return ContextCompat.checkSelfPermission(activity,permission) == PermissionChecker.PERMISSION_GRANTED;
  }
  private InitResultInfo getResultBean(boolean isSuccess, String msg) {
    InitResultInfo bean = new InitResultInfo();
    bean.setSuccess(isSuccess);
    bean.setMessage(msg);
    return bean;
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
