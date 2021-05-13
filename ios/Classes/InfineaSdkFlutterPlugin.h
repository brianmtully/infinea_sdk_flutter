#import <Flutter/Flutter.h>

@interface InfineaStreamHandler : NSObject <FlutterStreamHandler>
@property FlutterEventSink eventSink;
@end

@interface InfineaSdkFlutterPlugin : NSObject<FlutterPlugin>

/*
- (void)setDeveloperKey:(NSString*)key result:(FlutterResult)result;
- (void)cognnect:(FlutterResult)result;
- (void)disconnect:(FlutterResult)result;
- (void)sdkVersion:(FlutterResult)result;
- (void)getConnectedDeviceInfo:(int)type result:(FlutterResult)result;
*/
@end
