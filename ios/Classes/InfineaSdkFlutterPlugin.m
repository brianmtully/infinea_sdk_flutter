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
  NSLog(@"INIT EVENT CHANNEL");
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
  } else {
    result(FlutterMethodNotImplemented);
  }
}



- (void)setDeveloperKey:(NSString*)key result:(FlutterResult)result
{
      NSLog(@"Call setDeveloperKey");
      NSLog(@"Set Key");
      NSObject * pluginResult = nil;
      NSLog(@"%@", key);
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

- (void)getConnectedDeviceInfo:(int)type result:(FlutterResult)result
{
    NSLog(@"Call getConnectedDeviceInfo");
    
    //NSString* echo = [command.arguments objectAtIndex:0];
    NSLog(@" %i",type);
    NSError *error = nil;
    DTDeviceInfo *deviceInfo = [_ipc getConnectedDeviceInfo:0 error:&error];
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


 - (void)getConnectedDevicesInfo:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call getConnectedDevicesInfo");
     
     CDVPluginResult* pluginResult = nil;
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
         
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:devicesInfo];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)setPassThroughSync:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call setPassThroughSync");
     
     CDVPluginResult* pluginResult = nil;
     BOOL echo = [command.arguments objectAtIndex:0];
     
     NSError *error;
     BOOL isSuccess = [self.ipc setPassThroughSync:echo error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)getPassThroughSync:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call getPassThroughSync");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     BOOL isEnable = NO;
     BOOL isSuccess = [self.ipc getPassThroughSync:&isEnable error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnable];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)setUSBChargeCurrent:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call setUSBChargeCurrent");
     
     CDVPluginResult* pluginResult = nil;
     int echo = [[command.arguments objectAtIndex:0] intValue];
     
     NSError *error;
     BOOL isSuccess = [self.ipc setUSBChargeCurrent:echo error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }


 - (void)getUSBChargeCurrent:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call getUSBChargeCurrent");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     int current = 0;
     BOOL isSuccess = [self.ipc getUSBChargeCurrent:&current error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:current];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)setAutoOffWhenIdle:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call setAutoOffWhenIdle");
     
     CDVPluginResult* pluginResult = nil;
     int timeIdle = [[command.arguments objectAtIndex:0] intValue];
     int timeDisconnected = [[command.arguments objectAtIndex:1] intValue];
     
     NSError *error;
     BOOL isSuccess = [self.ipc setAutoOffWhenIdle:timeIdle whenDisconnected:timeDisconnected error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)getBatteryInfo:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call getBatteryInfo");
     
     CDVPluginResult* pluginResult = nil;
     
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
         
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)rfInit:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call rfInit");
     
     CDVPluginResult* pluginResult = nil;
     NSError *error;
     BOOL isSuccess = [self.ipc rfInit:CARD_SUPPORT_PICOPASS_ISO15|CARD_SUPPORT_TYPE_A|CARD_SUPPORT_TYPE_B|CARD_SUPPORT_ISO15|CARD_SUPPORT_FELICA error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }


 - (void)rfClose:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call rfClose");
     
     CDVPluginResult* pluginResult = nil;
     NSError *error;
     BOOL isSuccess = [self.ipc rfClose:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)barcodeGetScanButtonMode:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeGetScanButtonMode");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     int scanButtonMode = 1;
     BOOL isSuccess = [self.ipc barcodeGetScanButtonMode:&scanButtonMode error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:scanButtonMode];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }


 - (void)barcodeSetScanButtonMode:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeSetScanButtonMode");
     
     CDVPluginResult* pluginResult = nil;
     int echo = [[command.arguments objectAtIndex:0] intValue];
     
     NSError *error;
     BOOL isSuccess = [self.ipc barcodeSetScanButtonMode:echo error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)barcodeGetScanMode:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeGetScanMode");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     int scanMode = 1;
     BOOL isSuccess = [self.ipc barcodeGetScanMode:&scanMode error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:scanMode];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)barcodeSetScanMode:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeSetScanMode");
     
     CDVPluginResult* pluginResult = nil;
     int echo = [[command.arguments objectAtIndex:0] intValue];
     
     NSError *error;
     BOOL isSuccess = [self.ipc barcodeSetScanMode:echo error:&error];
     int scanMode = 0;
     [self.ipc barcodeGetScanMode:&scanMode error:nil];
     NSLog(@"BarcodeSetScanMode - Scan Mode: %d",scanMode);
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)barcodeStartScan:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeStartScan");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     BOOL isSuccess = [self.ipc barcodeStartScan:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)barcodeStopScan:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call barcodeStopScan");
     
     CDVPluginResult* pluginResult = nil;
     
     NSError *error;
     BOOL isSuccess = [self.ipc barcodeStopScan:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }


 - (void)barcodeSetScanBeep: (CDVInvokedUrlCommand *)command{
     NSLog(@"Call barocdeSetScanBeep");
     
     CDVPluginResult *pluginResult = nil;
     BOOL enabled = [command.arguments[0] boolValue];
     NSError *beepError = nil;
     int volume = 100;
     NSArray *beeps = command.arguments[1];

     int numberOfData = (int)beeps.count;

     int beepData[numberOfData];
     for (int x = 0; x < numberOfData; x++) {
         beepData[x] = [beeps[x] intValue];
     }

     BOOL isSuccess =[self.ipc barcodeSetScanBeep:enabled volume:volume beepData:beepData length:(int)sizeof(beepData) error:&beepError];
     if(isSuccess){
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:enabled];
     }
     else{
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:beepError.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)setCharging:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call setCharging");
     
     CDVPluginResult* pluginResult = nil;
     BOOL echo = [command.arguments objectAtIndex:0];
     
     NSError *error;
     BOOL isSuccess = [self.ipc setCharging:echo error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)getFirmwareFileInformation:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call getFirmwareFileInformation");
     
     CDVPluginResult *pluginResult = nil;
     NSString *filePath = [command.arguments objectAtIndex:0];
     filePath = [filePath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
     NSURL *fullFilePathURL = [[self resourcePath] URLByAppendingPathComponent:filePath];
     
     @try {
         NSData *fileData = [NSData dataWithContentsOfURL:fullFilePathURL];
         
         if (!fileData) {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to read file. Check file path!"];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             return;
         }
         else {
             
             NSError *error = nil;
             NSDictionary *firmwareInfo = [self.ipc getFirmwareFileInformation:fileData error:&error];
             if (!error) {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:firmwareInfo];
             } else {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
             }
             
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             
             return;
         }
         
     } @catch (NSException *exception) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         
         return;
     }
 }

 - (void)updateFirmwareData:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call updateFirmwareData");
     
     self.ipc = [IPCDTDevices sharedDevice];
     
     CDVPluginResult *pluginResult = nil;
     NSString *filePath = [command.arguments objectAtIndex:0];
     filePath = [filePath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
     NSURL *fullFilePathURL = [[self resourcePath] URLByAppendingPathComponent:filePath];
     
     if (self.ipc.connstate != CONN_CONNECTED) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Device is not connected!"];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         
         return;
     }
     else {
         @try {
             NSData *fileData = [NSData dataWithContentsOfURL:fullFilePathURL];
             
             if (!fileData) {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to read file. Check file path!"];
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                 return;
             }
             else {
                 NSError *error = nil;
                 BOOL isUpdate = [self.ipc updateFirmwareData:fileData validate:YES error:&error];
                 if (!error || isUpdate) {
                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                 } else {
                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                 }
                 
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                 
                 return;
             }
             
         } @catch (NSException *exception) {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             
             return;
         }
     }
 }

 - (void)emsrSetEncryption:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call emsrSetEncryption");
     
     CDVPluginResult* pluginResult = nil;
     int encryption = [[command.arguments objectAtIndex:0] intValue];
     int keyID = [[command.arguments objectAtIndex:1] intValue];
     NSDictionary *params = nil;
     if (command.arguments.count > 2) {
         // Check for null
         id object = [command.arguments objectAtIndex:2];
         if ([object isKindOfClass:[NSDictionary class]]) {
             params = (NSDictionary *)object;
         }
     }
     
     NSError *error = nil;
     BOOL isSuccess = [self.ipc emsrSetEncryption:encryption keyID:keyID params:params error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)emsrSetActiveHead:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call emsrSetActiveHead");
     
     CDVPluginResult* pluginResult = nil;
     int active = [[command.arguments objectAtIndex:0] intValue];
     
     NSError *error = nil;
     BOOL isSuccess = [self.ipc emsrSetActiveHead:active error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)emsrConfigMaskedDataShowExpiration:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call emsrConfigMaskedDataShowExpiration");
     
     CDVPluginResult* pluginResult = nil;
     BOOL showExpiration = [[command.arguments objectAtIndex:0] boolValue];
     BOOL showServiceCode = [[command.arguments objectAtIndex:1] boolValue];
     int unmaskedDigitsAtStart = [[command.arguments objectAtIndex:2] intValue];
     int unmaskedDigitsAtEnd = [[command.arguments objectAtIndex:3] intValue];
     int unmaskedDigitsAfter = [[command.arguments objectAtIndex:4] intValue];
     
     NSError *error = nil;
     BOOL isSuccess = [self.ipc emsrConfigMaskedDataShowExpiration:showExpiration showServiceCode:showServiceCode unmaskedDigitsAtStart:unmaskedDigitsAtStart unmaskedDigitsAtEnd:unmaskedDigitsAtEnd unmaskedDigitsAfter:unmaskedDigitsAfter error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)emsrIsTampered:(CDVInvokedUrlCommand *)command
 {
     NSLog(@"Call emsrIsTampered");
     
     CDVPluginResult* pluginResult = nil;
     BOOL isTampered = NO;
     
     NSError *error = nil;
     BOOL isSuccess = [self.ipc emsrIsTampered:&isTampered error:&error];
     if (!error || isSuccess) {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isTampered];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)emsrGetKeyVersion:(CDVInvokedUrlCommand*)command{
     NSLog(@"Call emsrGetKeyVersion");
     [NSThread sleepForTimeInterval:.2];
     
     CDVPluginResult* pluginResult = nil;
     int keyID = [command.arguments[0] intValue];
     int keyVersion = -1;
     NSError *error = nil;
     
     BOOL isSuccess = [self.ipc emsrGetKeyVersion:keyID keyVersion:&keyVersion error:&error];
     
     if(isSuccess){
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:keyVersion];
     }
     else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (void)emsrGetDeviceInfo:(CDVInvokedUrlCommand *)command{
     NSLog(@"Call emsrGetDeviceInfo");
     
     CDVPluginResult* pluginResult = nil;
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
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:emsrInfoDictionary];
     }else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }

 - (NSURL *)resourcePath
 {
     NSURL *pathURL = [[NSBundle mainBundle] resourceURL];
     return [pathURL URLByAppendingPathComponent:@"www/resources"];
 }

 - (void)iHUBGetPortsInfo:(CDVInvokedUrlCommand *)command{
     NSLog(@"Call iHUBGetPortsInfo");
     
     CDVPluginResult* pluginResult = nil;
     NSError *err = nil;
     NSArray *ports = [self.ipc iHUBGetPortsInfo:&err];
     NSString *portInfo= @"";
     
     for (iHUBPortInfo *port in ports){
         NSLog(@"Port %d: %@", port.portIndex, port.portConfig);
         portInfo = [portInfo stringByAppendingFormat:@"Port %d: %@\n", port.portIndex, port.portConfig];
     }
     
     
     if(ports){
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:portInfo];
     }
     else{
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:err.localizedDescription];
     }
     
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }







 */

@end
