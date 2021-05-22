#import "InfineaSdkFlutterPlugin.h"
#import <Foundation/Foundation.h>
#import <InfineaSDK/InfineaSDK.h>



@implementation InfineaStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    NSLog(@"ON LISTEN WITH ARGUMENTS");
    _eventSink = events;

    return nil;
}


- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

@end

@interface InfineaSdkFlutterPlugin() <IPCDTDeviceDelegate>
@property (strong, nonatomic) IPCIQ *iq;
@property (strong, nonatomic) IPCDTDevices *ipc;
@property(nonatomic) InfineaStreamHandler *infineaStreamHandler;
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
// @property(readonly, nonatomic) FlutterMethodChannel *deviceEventMethodChannel;

@end


@implementation InfineaSdkFlutterPlugin {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSLog(@"RegisterWithRegistrar");

  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.brianmtully.flutter.plugins.infinea/methods"
            binaryMessenger:[registrar messenger]];

 InfineaSdkFlutterPlugin* instance = [[InfineaSdkFlutterPlugin alloc] initWithRegistry:[registrar textures] messenger:[registrar messenger]];

      [registrar addMethodCallDelegate:instance channel:channel];

}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry messenger:(NSObject<FlutterBinaryMessenger> *)messenger{
NSLog(@"initWithRegistry");
self = [super init];
NSAssert(self, @"super init cannot be nil");
_registry = registry;
_messenger = messenger;
[self initEventChannel];
return self;
}

-(void)initEventChannel {
  NSLog(@"tINIT EVENT CHANNEL");
  FlutterEventChannel* streamChannel = [FlutterEventChannel eventChannelWithName:@"com.brianmtully.flutter.plugins.infinea/events" binaryMessenger:_messenger];
     _infineaStreamHandler = [[InfineaStreamHandler alloc] init];
    [streamChannel setStreamHandler:_infineaStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    /*id rejecter = ^(NSString *code, NSString *message, NSError *error) {
        result([FlutterError errorWithCode:code ?: @"-" message:message details:error.localizedDescription]);
    };*/

  if ([@"setDeveloperKey" isEqualToString:call.method]) {
      [self setDeveloperKey:call.arguments result:result];
  } else if ([@"connect" isEqualToString:call.method]) {
      [self connect: result];
  } else if ([@"disconnect" isEqualToString:call.method]) {
      [self disconnect: result];
  } else if ([@"sdkVersion" isEqualToString:call.method]) {
      [self sdkVersion: result];
  } else if ([@"getConnectedDeviceInfo" isEqualToString:call.method]) {
      [self getConnectedDeviceInfo:call.arguments result:result];
  } else if ([@"getConnectedDevicesInfo" isEqualToString:call.method]) {
      [self getConnectedDevicesInfo: result];
  } else if ([@"setPassThroughSync" isEqualToString:call.method]) {
      [self setPassThroughSync:call.arguments result:result];
  } else if ([@"getPassThroughSync" isEqualToString:call.method]) {
      [self getPassThroughSync: result];
  }  else if ([@"setUSBChargeCurrent" isEqualToString:call.method]) {
      [self setUSBChargeCurrent:call.arguments result:result];
  } else if ([@"getUSBChargeCurrent" isEqualToString:call.method]) {
      [self getUSBChargeCurrent: result];
  } else if ([@"setAutoOffWhenIdle" isEqualToString:call.method]) {
      [self setAutoOffWhenIdle:call.arguments result:result];
  } else if ([@"getBatteryInfo" isEqualToString:call.method]) {
      [self getBatteryInfo: result];
  } else if ([@"rfInit" isEqualToString:call.method]) {
      [self rfInit: result];
  } else if ([@"rfClose" isEqualToString:call.method]) {
      [self rfClose: result];
  }  else if ([@"barcodeGetScanButtonMode" isEqualToString:call.method]) {
      [self barcodeGetScanButtonMode: result];
  } else if ([@"barcodeSetScanButtonMode" isEqualToString:call.method]) {
      [self barcodeSetScanButtonMode:call.arguments result:result];
  } else if ([@"barcodeGetScanMode" isEqualToString:call.method]) {
      [self barcodeGetScanMode: result];
  } else if ([@"barcodeSetScanMode" isEqualToString:call.method]) {
      [self barcodeSetScanMode:call.arguments result:result];
  } else if ([@"barcodeStartScan" isEqualToString:call.method]) {
      [self barcodeStartScan: result];
  } else if ([@"barcodeStopScan" isEqualToString:call.method]) {
      [self barcodeStopScan: result];
  } else if ([@"barcodeSetScanBeep" isEqualToString:call.method]) {
      [self barcodeSetScanBeep:call.arguments result:result];
  } else if ([@"setCharging" isEqualToString:call.method]) {
      [self setCharging:call.arguments result:result];
  } else if ([@"getFirmwareFileInformation" isEqualToString:call.method]) {
      [self getFirmwareFileInformation:call.arguments result:result];
  } else if ([@"updateFirmwareData" isEqualToString:call.method]) {
      [self updateFirmwareData:call.arguments result:result];
  } else if ([@"emsrSetEncryption" isEqualToString:call.method]) {
      [self emsrSetEncryption:call.arguments result:result];
  } else if ([@"emsrSetActiveHead" isEqualToString:call.method]) {
      [self emsrSetActiveHead:call.arguments result:result];
  } else if ([@"emsrConfigMaskedDataShowExpiration" isEqualToString:call.method]) {
      [self emsrConfigMaskedDataShowExpiration:call.arguments result:result];
  } else if ([@"emsrIsTampered" isEqualToString:call.method]) {
      [self emsrIsTampered: result];
  } else if ([@"emsrGetKeyVersion" isEqualToString:call.method]) {
      [self emsrGetKeyVersion:call.arguments result:result];
  } else if ([@"emsrGetDeviceInfo" isEqualToString:call.method]) {
      [self emsrGetDeviceInfo: result];
  } else if ([@"iHUBGetPortsInfo" isEqualToString:call.method]) {
      [self iHUBGetPortsInfo: result];
  } else {
      result(FlutterMethodNotImplemented);
  }
}



- (void)setDeveloperKey:(NSArray*)arguments result:(FlutterResult)result
{
      NSLog(@"Call setDeveloperKey");
      NSObject * pluginResult = nil;
      NSString* key = [arguments objectAtIndex:0];
      NSError *error;
       _iq = [IPCIQ registerIPCIQ];
      [_iq setDeveloperKey:key withError:&error];
      if (error) {
          NSString *errorCode = @"Error";
          pluginResult = [FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription];
          // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
          result(pluginResult);
          NSLog(@"Developer Key Error: %@", error.localizedDescription);
      }

      _ipc = [IPCDTDevices sharedDevice];
    result(pluginResult);
}


- (void)connect:(FlutterResult)result
{
    NSLog(@"Call connect");

    _ipc = [IPCDTDevices sharedDevice];
    [_ipc addDelegate:self];
    [_ipc connect];
    result(nil);
}

- (void)disconnect:(FlutterResult)result
{
    NSLog(@"Call disconnect");

    _ipc = [IPCDTDevices sharedDevice];
    [_ipc disconnect];
    result(nil);
}

-(void)sdkVersion:(FlutterResult)result
{
    NSLog(@"Call SDK Version");
    int sdk = [_ipc sdkVersion];
    NSString* sdkString = [@(sdk) stringValue];
    if(sdk){
        NSLog(@"SDK Version: %d", sdk);
    }
    result(sdkString);
}

- (void)getConnectedDeviceInfo:(NSNumber*)type result:(FlutterResult)result
{
    NSLog(@"Call getConnectedDeviceInfo");
    
    //NSString* echo = [arguments objectAtIndex:0];
    NSError *error = nil;
    DTDeviceInfo *deviceInfo = [_ipc getConnectedDeviceInfo:[type intValue] error:&error];
    if (!error) {
        NSDictionary *info = @{@"deviceType": @(deviceInfo.deviceType),
                               @"connectionType": @(deviceInfo.connectionType),
                               @"name": deviceInfo.name,
                               @"model": deviceInfo.model,
                               @"firmwareRevision": deviceInfo.firmwareRevision,
                               @"hardwareRevision": deviceInfo.hardwareRevision,
                               @"serialNumber": deviceInfo.serialNumber
                               };
        
        result(info);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
    
}

 - (void)getConnectedDevicesInfo:(FlutterResult)result
 {
     NSLog(@"Call getConnectedDevicesInfo");

     NSError *error = nil;

     NSArray *connectedDevices = [self.ipc getConnectedDevicesInfo:&error];

     if (!error) {
         NSMutableArray *devicesInfo = [NSMutableArray new];
         for (DTDeviceInfo *deviceInfo in connectedDevices) {
             NSDictionary *device = @{@"deviceType": @(deviceInfo.deviceType),
                                      @"connectionType": @(deviceInfo.connectionType),
                                      @"name": deviceInfo.name,
                                      @"model": deviceInfo.model,
                                      @"firmwareRevision": deviceInfo.firmwareRevision,
                                      @"hardwareRevision": deviceInfo.hardwareRevision,
                                      @"serialNumber": deviceInfo.serialNumber
                                      };

             [devicesInfo addObject:device];
         }

         result(devicesInfo);
     } else {
         NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
     }

 }

 - (void)setPassThroughSync:(BOOL)echo result:(FlutterResult)result
{
   NSLog(@"Call setPassThroughSync");

   // BOOL echo = [command.arguments objectAtIndex:0];

   NSError *error;
   BOOL isSuccess = [self.ipc setPassThroughSync:echo error:&error];
   if (!error || isSuccess) {
       NSNumber* output=[NSNumber numberWithBool:isSuccess];
       result(output);
   } else {
       NSString *errorCode = @"Error";
       result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
   }

}

 - (void)getPassThroughSync:(FlutterResult)result
 {
     NSLog(@"Call getPassThroughSync");

     NSError *error;
     BOOL isEnable = NO;
     BOOL isSuccess = [self.ipc getPassThroughSync:&isEnable error:&error];
     if (!error || isSuccess) {
         NSNumber* output=[NSNumber numberWithBool:isSuccess];
         result(output);
     } else {
       NSString *errorCode = @"Error";
       result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
     }
 }

  - (void)setUSBChargeCurrent:(NSArray*)arguments result:(FlutterResult)result
  {
      NSLog(@"Call setUSBChargeCurrent");

     int value = [[arguments objectAtIndex:0] intValue];
      NSError *error;
      BOOL isSuccess = [self.ipc setUSBChargeCurrent:value error:&error];
      if (!error || isSuccess) {
          NSNumber* output=[NSNumber numberWithBool:isSuccess];
          result(output);
      } else {
       NSString *errorCode = @"Error";
       result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
      }
  }


  - (void)getUSBChargeCurrent:(FlutterResult)result
  {
      NSLog(@"Call getUSBChargeCurrent");

      NSError *error;
      int current = 0;
      BOOL isSuccess = [self.ipc getUSBChargeCurrent:&current error:&error];
      if (!error || isSuccess) {
          NSNumber* output=[NSNumber numberWithBool:isSuccess];
          result(output);
      } else {
       NSString *errorCode = @"Error";
       result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
      }
  }

- (void)setAutoOffWhenIdle:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call setAutoOffWhenIdle");
    
    int timeIdle = [[arguments objectAtIndex:0] intValue];
    int timeDisconnected = [[arguments objectAtIndex:1] intValue];
    
    NSError *error;
    BOOL isSuccess = [self.ipc setAutoOffWhenIdle:timeIdle whenDisconnected:timeDisconnected error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
    
}

- (void)getBatteryInfo:(FlutterResult)result
{
    NSLog(@"Call getBatteryInfo");
    
    NSError *error = nil;
    DTBatteryInfo *battInfo = [self.ipc getBatteryInfo:&error];
    if (!error) {
        NSDictionary *info = @{@"voltage": @(battInfo.voltage),
                               @"capacity": @(battInfo.capacity),
                               @"health": @(battInfo.health),
                               @"maximumCapacity": @(battInfo.maximumCapacity),
                               @"charging": @(battInfo.charging),
                               @"batteryChipType": @(battInfo.batteryChipType),
                               @"extendedInfo": battInfo.extendedInfo != nil ? battInfo.extendedInfo : @""
                               };
        
        result(info);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }

}

- (void)rfInit:(FlutterResult)result
{
    NSLog(@"Call rfInit");
    
    NSError *error;
    BOOL isSuccess = [self.ipc rfInit:CARD_SUPPORT_PICOPASS_ISO15|CARD_SUPPORT_TYPE_A|CARD_SUPPORT_TYPE_B|CARD_SUPPORT_ISO15|CARD_SUPPORT_FELICA error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
    
}


- (void)rfClose:(FlutterResult)result
{
    NSLog(@"Call rfClose");
    
    NSError *error;
    BOOL isSuccess = [self.ipc rfClose:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)barcodeGetScanButtonMode:(FlutterResult)result
{
    NSLog(@"Call barcodeGetScanButtonMode");
    
    NSError *error;
    int scanButtonMode = 1;
    BOOL isSuccess = [self.ipc barcodeGetScanButtonMode:&scanButtonMode error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}


- (void)barcodeSetScanButtonMode:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call barcodeSetScanButtonMode");
    
    int echo = [[arguments objectAtIndex:0] intValue];
    
    NSError *error;
    BOOL isSuccess = [self.ipc barcodeSetScanButtonMode:echo error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)barcodeGetScanMode:(FlutterResult)result
{
    NSLog(@"Call barcodeGetScanMode");

    
    NSError *error;
    int scanMode = 1;
    BOOL isSuccess = [self.ipc barcodeGetScanMode:&scanMode error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)barcodeSetScanMode:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call barcodeSetScanMode");
    
    int echo = [[arguments objectAtIndex:0] intValue];
    
    NSError *error;
    BOOL isSuccess = [self.ipc barcodeSetScanMode:echo error:&error];
    int scanMode = 0;
    [self.ipc barcodeGetScanMode:&scanMode error:nil];
    NSLog(@"BarcodeSetScanMode - Scan Mode: %d",scanMode);
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)barcodeStartScan:(FlutterResult)result
{
    NSLog(@"Call barcodeStartScan");
    
    NSError *error;
    BOOL isSuccess = [self.ipc barcodeStartScan:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)barcodeStopScan:(FlutterResult)result
{
    NSLog(@"Call barcodeStopScan");
    
    NSError *error;
    BOOL isSuccess = [self.ipc barcodeStopScan:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}


- (void)barcodeSetScanBeep:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call barocdeSetScanBeep");
    
    BOOL enabled = [arguments[0] boolValue];
    NSError *beepError = nil;
    int volume = 100;
    NSArray *beeps = arguments[1];

    int numberOfData = (int)beeps.count;

    int beepData[numberOfData];
    for (int x = 0; x < numberOfData; x++) {
        beepData[x] = [beeps[x] intValue];
    }

    BOOL isSuccess =[self.ipc barcodeSetScanBeep:enabled volume:volume beepData:beepData length:(int)sizeof(beepData) error:&beepError];
    if (!beepError || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:beepError.localizedDescription details:beepError.localizedDescription]);
    }
}

- (void)setCharging:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call setCharging");
    
    BOOL echo = [arguments objectAtIndex:0];
    
    NSError *error;
    BOOL isSuccess = [self.ipc setCharging:echo error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)getFirmwareFileInformation:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call getFirmwareFileInformation");
    
    NSString *filePath = [arguments objectAtIndex:0];
    filePath = [filePath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSURL *fullFilePathURL = [[self resourcePath] URLByAppendingPathComponent:filePath];
    
    @try {
        NSData *fileData = [NSData dataWithContentsOfURL:fullFilePathURL];
        
        if (!fileData) {
            NSString *errorCode = @"Error";
            result([FlutterError errorWithCode:errorCode?: @"-" message:@"Unable to read file. Check file path!" details:@"Unable to read file. Check file path!"]);
            return;
        }
        else {
            
            NSError *error = nil;
            NSDictionary *firmwareInfo = [self.ipc getFirmwareFileInformation:fileData error:&error];
            if (!error) {
                result(firmwareInfo);
            } else {
                NSString *errorCode = @"Error";
                result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
            }
            
            return;
        }
        
    } @catch (NSException *exception) {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:exception.reason details:exception.reason]);
        return;
    }
}

- (void)updateFirmwareData:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call updateFirmwareData");
    
    self.ipc = [IPCDTDevices sharedDevice];
    
    NSString *filePath = [arguments objectAtIndex:0];
    filePath = [filePath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSURL *fullFilePathURL = [[self resourcePath] URLByAppendingPathComponent:filePath];
    
    if (self.ipc.connstate != CONN_CONNECTED) {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:@"Device is not connected!" details:@"Device is not connected!"]);
        return;
    }
    else {
        @try {
            NSData *fileData = [NSData dataWithContentsOfURL:fullFilePathURL];
            
            if (!fileData) {
                NSString *errorCode = @"Error";
                result([FlutterError errorWithCode:errorCode?: @"-" message:@"Unable to read file. Check file path!" details:@"Unable to read file. Check file path!"]);
                return;
            }
            else {
                NSError *error = nil;
                BOOL isUpdate = [self.ipc updateFirmwareData:fileData validate:YES error:&error];
                if (!error || isUpdate) {
                    NSNumber* output=[NSNumber numberWithBool:isUpdate];
                    result(output);
                } else {
                    NSString *errorCode = @"Error";
                    result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
                }
                return;
            }
            
        } @catch (NSException *exception) {
            NSString *errorCode = @"Error";
            result([FlutterError errorWithCode:errorCode?: @"-" message:exception.reason details:exception.reason]);
            return;
        }
    }
}

- (void)emsrSetEncryption:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call emsrSetEncryption");
    
    int encryption = [[arguments objectAtIndex:0] intValue];
    int keyID = [[arguments objectAtIndex:1] intValue];
    NSDictionary *params = nil;
    if (arguments.count > 2) {
        // Check for null
        id object = [arguments objectAtIndex:2];
        if ([object isKindOfClass:[NSDictionary class]]) {
            params = (NSDictionary *)object;
        }
    }
    
    NSError *error = nil;
    BOOL isSuccess = [self.ipc emsrSetEncryption:encryption keyID:keyID params:params error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)emsrSetActiveHead:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call emsrSetActiveHead");
    
    int active = [[arguments objectAtIndex:0] intValue];
    
    NSError *error = nil;
    BOOL isSuccess = [self.ipc emsrSetActiveHead:active error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)emsrConfigMaskedDataShowExpiration:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call emsrConfigMaskedDataShowExpiration");
    
    BOOL showExpiration = [[arguments objectAtIndex:0] boolValue];
    BOOL showServiceCode = [[arguments objectAtIndex:1] boolValue];
    int unmaskedDigitsAtStart = [[arguments objectAtIndex:2] intValue];
    int unmaskedDigitsAtEnd = [[arguments objectAtIndex:3] intValue];
    int unmaskedDigitsAfter = [[arguments objectAtIndex:4] intValue];
    
    NSError *error = nil;
    BOOL isSuccess = [self.ipc emsrConfigMaskedDataShowExpiration:showExpiration showServiceCode:showServiceCode unmaskedDigitsAtStart:unmaskedDigitsAtStart unmaskedDigitsAtEnd:unmaskedDigitsAtEnd unmaskedDigitsAfter:unmaskedDigitsAfter error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)emsrIsTampered:(FlutterResult)result
{
    NSLog(@"Call emsrIsTampered");
    
    BOOL isTampered = NO;
    
    NSError *error = nil;
    BOOL isSuccess = [self.ipc emsrIsTampered:&isTampered error:&error];
    if (!error || isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)emsrGetKeyVersion:(NSArray*)arguments result:(FlutterResult)result
{
    NSLog(@"Call emsrGetKeyVersion");
    [NSThread sleepForTimeInterval:.2];
    
    int keyID = [arguments[0] intValue];
    int keyVersion = -1;
    NSError *error = nil;
    
    BOOL isSuccess = [self.ipc emsrGetKeyVersion:keyID keyVersion:&keyVersion error:&error];
    
    if (isSuccess) {
        NSNumber* output=[NSNumber numberWithBool:isSuccess];
        result(output);
    } else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (void)emsrGetDeviceInfo:(FlutterResult)result
{
    NSLog(@"Call emsrGetDeviceInfo");
    
    NSError *error = nil;
    EMSRDeviceInfo *emsrInfo = [self.ipc emsrGetDeviceInfo:&error];
    
    if(emsrInfo){
        NSDictionary *emsrInfoDictionary = @{@"ident": emsrInfo.ident,
                                             @"serialNumber": [NSString stringWithFormat:@"%@", emsrInfo.serialNumber],
                                             @"serialNumberString": emsrInfo.serialNumberString,
                                             @"firmwareVersion": @(emsrInfo.firmwareVersion),
                                             @"firmwareVersionString": emsrInfo.firmwareVersionString,
                                             @"securityVersion": @(emsrInfo.securityVersion),
                                             @"securityVersionString": emsrInfo.securityVersionString
                                             };
        result(emsrInfoDictionary);
    }else {
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:error.localizedDescription details:error.localizedDescription]);
    }
}

- (NSURL *)resourcePath
{
    NSURL *pathURL = [[NSBundle mainBundle] resourceURL];
    return [pathURL URLByAppendingPathComponent:@"www/resources"];
}

- (void)iHUBGetPortsInfo:(FlutterResult)result
{
    NSLog(@"Call iHUBGetPortsInfo");
    
    NSError *err = nil;
    NSArray *ports = [self.ipc iHUBGetPortsInfo:&err];
    NSString *portInfo= @"";
    
    for (iHUBPortInfo *port in ports){
        NSLog(@"Port %d: %@", port.portIndex, port.portConfig);
        portInfo = [portInfo stringByAppendingFormat:@"Port %d: %@\n", port.portIndex, port.portConfig];
    }
    
    
    if(ports){
        result(portInfo);
    }
    else{
        NSString *errorCode = @"Error";
        result([FlutterError errorWithCode:errorCode?: @"-" message:err.localizedDescription details:err.localizedDescription]);
    }
}



 #pragma mark - IPCDeviceDelegate
 
 - (void)connectionState:(int)state
 {
     if (_infineaStreamHandler.eventSink != nil) {
          _infineaStreamHandler.eventSink(@{
              @"event" : @"connectionState",
              @"state" : @(state)
          });
     }
 }

 - (void)barcodeData:(NSString *)barcode type:(int)type
{

     // This send to regular barcgodeData as string
     //[self callback:@"Infinea.barcodeData(\"%@\", %i)", barcode, type];
     NSLog(@"%@", barcode);

    if (_infineaStreamHandler.eventSink != nil) {
         _infineaStreamHandler.eventSink(@{
             @"event" : @"barcode",
             @"data" : barcode,
             @"type" : @(type)
         });
    }

     // Convert to decimal
     const char *barcodes = [barcode UTF8String];
     NSMutableArray *barcodeDecimalArray = [NSMutableArray new];
     for (int i = 0; i < sizeof(barcodes); i++) {
         NSString *string = [NSString stringWithFormat:@"%02d", barcodes[i]];
         NSLog(@"%@", string);
         [barcodeDecimalArray addObject:string];
     }
     NSString *barcodeDecimalString = [barcodeDecimalArray componentsJoinedByString:@","];

    if (_infineaStreamHandler.eventSink != nil) {
      _infineaStreamHandler.eventSink(@{
          @"event" : @"barcodeDecimal",
          @"data" : barcodeDecimalString,
          @"type" : @(type)
      });
    }
 }



 - (void)barcodeNSData:(NSData *)barcode type:(int)type
 {
     // Hex data
     NSString *hexData = [NSString stringWithFormat:@"%@", barcode];
     hexData = [hexData stringByReplacingOccurrencesOfString:@"<" withString:@""];
     hexData = [hexData stringByReplacingOccurrencesOfString:@">" withString:@""];
     hexData = [hexData stringByReplacingOccurrencesOfString:@" " withString:@""];

     // Ascii string
     uint8_t *bytes=(uint8_t *)[barcode bytes];
     NSMutableString *escapedString = [@"" mutableCopy];
     for (int x = 0; x < barcode.length;x++)
     {
         [escapedString appendFormat:@"\\x%02X", bytes[x] ];
     }

     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"barcodeNSData",
           @"data" : hexData,
           @"type" : @(type)
       });
     }
 }

 - (void)rfCardDetected:(int)cardIndex info:(DTRFCardInfo *)info
 {
     NSDictionary *cardInfo = @{@"type": @(info.type),
                                @"typeStr": info.typeStr,
                                @"UID": [NSString stringWithFormat:@"%@", info.UID],
                                @"ATQA": @(info.ATQA),
                                @"SAK": @(info.SAK),
                                @"AFI": @(info.AFI),
                                @"DSFID": @(info.DSFID),
                                @"blockSize": @(info.blockSize),
                                @"nBlocks": @(info.nBlocks),
                                @"felicaPMm": [NSString stringWithFormat:@"%@", info.felicaPMm],
                                @"felicaRequestData": [NSString stringWithFormat:@"%@", info.felicaRequestData],
                                @"cardIndex": @(info.cardIndex)
                                };

     
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"rfCardDetected",
           @"data" : cardInfo,
           @"index" : @(cardIndex)
       });
     }
 }

 - (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"magneticCardData",
           @"track1" : track1,
           @"track2" : track2,
           @"track3" : track3
       });
     }
     
 }

 - (void)magneticCardEncryptedData:(int)encryption tracks:(int)tracks data:(NSData *)data track1masked:(NSString *)track1masked track2masked:(NSString *)track2masked track3:(NSString *)track3 source:(int)source
 {
         // Ascii string
     uint8_t *bytes=(uint8_t *)[data bytes];
    // NSMutableString *escapedString = [@"" mutableCopy];
     NSMutableString *escapedString = [[NSMutableString alloc]init];
     NSMutableString *hexData = [[NSMutableString alloc] init];
     for (int x=0; x<data.length;x++)
     {
         [hexData appendFormat:@"%02x", (unsigned int)bytes[x]];
         [escapedString appendFormat:@"\\x%02X", bytes[x] ];
     }

     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"magneticCardEncryptedData",
           @"encryption" : @(encryption),
           @"tracks" : @(tracks),
           @"escapedString" : escapedString,
           @"track1masked": track1masked,
           @"track2masked": track2masked,
           @"track3": track3,
           @"source": @(source)
       });
     }
 }

 - (void)magneticCardReadFailed:(int)source reason:(int)reason
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"magneticCardReadFailed",
           @"source" : @(source),
           @"reason" : @(reason)
       });
     }
 }

 - (void)magneticCardReadFailed:(int)source
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"magneticCardReadFailed",
           @"source" : @(source),
       });
     }
 }

 - (void)deviceButtonPressed:(int)which
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"deviceButtonPressed",
           @"button" : @(which)
       });
     }
 }

 - (void)deviceButtonReleased:(int)which
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"deviceButtonReleased",
           @"button" : @(which)
       });
     }
 }

 - (void)firmwareUpdateProgress:(int)phase percent:(int)percent
 {
     if (_infineaStreamHandler.eventSink != nil) {
       _infineaStreamHandler.eventSink(@{
           @"event" : @"firemwareUpdateProgress",
           @"phase" : @(phase),
           @"percent": @(percent)
       });
     }
 }


 
/*




 */

@end
