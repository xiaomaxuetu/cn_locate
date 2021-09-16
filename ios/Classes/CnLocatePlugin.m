#import "CnLocatePlugin.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <CoreLocation/CLLocationManager.h>

@interface CnLocatePlugin ()<AMapLocationManagerDelegate>
@property(nonatomic) AMapLocationManager *locationManager;

@end
FlutterMethodChannel* cn_locate_channel;
@implementation CnLocatePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    cn_locate_channel = [FlutterMethodChannel
      methodChannelWithName:@"cn_locate"
            binaryMessenger:[registrar messenger]];
  CnLocatePlugin* instance = [[CnLocatePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:cn_locate_channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initSdk" isEqualToString:call.method]) {
      if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)){
          
          NSString *apiKey = call.arguments[@"apiKey"];
          NSString *locationMode = call.arguments[@"locationMode"];
          NSNumber *distanceFilter  = call.arguments[@"distanceFilter"];
//          BOOL isOnceLocation = call.arguments[@"isOnceLocation"];
//          BOOL isNeedAdress = call.arguments[@"isNeedAdress"];
          
          
          
          [AMapServices sharedServices].apiKey = apiKey;
          
          self.locationManager = [[AMapLocationManager alloc] init];
          self.locationManager.delegate = self;
          if([locationMode isEqualToString:@"LocationMode.hightAccuracy"]){
              [self.locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
          }else if([locationMode isEqualToString:@"LocationMode.batterySaving"]){
              [self.locationManager setDesiredAccuracy: kCLLocationAccuracyHundredMeters];
          }else if([locationMode isEqualToString:@"LocationMode.deviceSensors"]){
              [self.locationManager setDesiredAccuracy: kCLLocationAccuracyBestForNavigation];
          }
          
          
          [self.locationManager setDistanceFilter:[distanceFilter intValue]];
          self.locationManager.allowsBackgroundLocationUpdates = YES;
          [self.locationManager startUpdatingLocation];
          
          
          NSDictionary * dict = @{@"message":@"初始化成功", @"isSuccess":@YES};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          result(json);
      }else{
          NSDictionary * dict = @{@"message":@"请开始定位权限", @"isSuccess":@NO};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          result(json);
      }
      
      
  } else if([@"startLocate" isEqualToString:call.method]) {
      [self.locationManager startUpdatingLocation];
      
  }else if([@"stopLocate" isEqualToString:call.method]) {
      [self.locationManager stopUpdatingLocation];
  }else{
      result(FlutterMethodNotImplemented);
  }
}
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location{
    NSDictionary * dict = @{
        @"latitude":[NSNumber numberWithDouble:location.coordinate.latitude],
        @"longitude":[NSNumber numberWithDouble:location.coordinate.longitude],
        @"altitude":[NSNumber numberWithDouble:location.altitude],
        @"speed":[NSNumber numberWithDouble:location.speed],
        @"provider":@"lbs",
        @"accuracy":[NSNumber numberWithDouble:location.horizontalAccuracy]
        
    };
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
              NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [channel invokeMethod:@"onLocationChange" arguments:json];
}

@end
