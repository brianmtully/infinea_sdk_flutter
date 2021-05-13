import 'dart:async';

import 'package:flutter/services.dart';

/*
    All device types, used when setting active device = -1
 */
enum SUPPORTED_DEVICE_TYPES {
/*
    Linea Pro 1,2,3,4,4s, LineaTab
 */
  DEVICE_TYPE_LINEA,
/*
    Any of the supported printers - PP-60, DPP-250, DPP-350, DPP-450
 */
  DEVICE_TYPE_PRINTER,
/*
    Any of the supported pinpads - MPED-400, PPAD1, BP50, BP500
 */
  DEVICE_TYPE_PINPAD,
/*
    Transport device for connecting to other devices via bluetooth
 */
  DEVICE_TYPE_ISERIAL,
/*
    Any of the supported zebra printers - DPP-450
 */
  DEVICE_TYPE_PRINTER_ZPL,
/*
    Any of the supported iHUB devices
 */
  DEVICE_TYPE_IHUB,
/*
    Any of the supported HID barcode devices
 */
  DEVICE_TYPE_HID_BARCODE,
/*
    Any of the supported USB magnetic stripe reader devices
 */
  DEVICE_TYPE_USB_MSR,
/*
    HID keyboard devices
 */
  DEVICE_TYPE_HID_KEYBOARD,
}

enum CONN_STATES {
/*
    Device is disconnected, no automatic connection attempts will be made
 */
  CONN_DISCONNECTED,
/*
    The SDK is trying to connect to the device
 */
  CONN_CONNECTING,
/*
    Device is connected
 */
  CONN_CONNECTED
}

enum BATTERY_CHIPS {
  BATTERY_CHIP_NONE,
  BATTERY_CHIP_BQ27421,
}

enum SCAN_MODES {
/*
    The scan will be terminated after successful barcode recognition (default)
 */
  MODE_SINGLE_SCAN,
/*
    Scanning will continue unless either scan button is releasd, or stop scan function is called
 */
  MODE_MULTI_SCAN,
/*
    For as long as scan button is pressed or stop scan is not called the engine will operate in low power scan mode trying to detect objects entering the area, then will turn on the lights and try to read the barcode. Supported only on Code engine.
 */
  MODE_MOTION_DETECT,
/*
    Pressing the button/start scan will enter aim mode, while a barcode scan will actually be performed upon button release/stop scan.
 */
  MODE_SINGLE_SCAN_RELEASE,
/*
    Same as multi scan mode, but allowing no duplicate barcodes to be scanned
 */
  MODE_MULTI_SCAN_NO_DUPLICATES,
}

enum UPDATE_PHASE {
/*
    Initializing update
 */
  UPDATE_INIT,
/*
    Erasing old firmware/preparing memory
 */
  UPDATE_ERASE,
/*
    Writing data
 */
  UPDATE_WRITE,
/*
    Update complete, this is the final phase
 */
  UPDATE_FINISH,
/*
    Post-update operations
 */
  UPDATE_COMPLETING
}

typedef void Listener(dynamic msg);
typedef void CancelListening();

class InfineaSdkFlutter {
  static const MethodChannel _channel =
      const MethodChannel('com.brianmtully.flutter.plugins.infinea/methods');

  static const EventChannel _eventChannel =
      const EventChannel('com.brianmtully.flutter.plugins.infinea/events');

  static final InfineaSdkFlutter _instance = InfineaSdkFlutter._internal();

  factory InfineaSdkFlutter() {
    return _instance;
  }

  InfineaSdkFlutter._internal() {}

  int nextListenerId = 1;

  CancelListening startListening(Listener listener) {
    var subscription = _eventChannel
        .receiveBroadcastStream(nextListenerId++)
        .listen(listener, cancelOnError: true);
    return () {
      subscription.cancel();
    };
  }

  Future<Map> setDeveloperKey({String key}) async {
    final Map result = await _channel.invokeMethod('setDeveloperKey', key);
    print(result);
    return result;
  }

  Future<void> connect() async {
    return await _channel.invokeMethod('connect');
  }

  Future<void> disconnect() async {
    return await _channel.invokeMethod('disconnect');
  }

  Future<Map> getConnectedDeviceInfo({int type}) async {
    final Map result =
        await _channel.invokeMethod('getConnectedDeviceInfo', type);
    return result;
  }

  static Future<String> get sdkVersion async {
    final String version = await _channel.invokeMethod('sdkVersion');
    return version;
  }
}
