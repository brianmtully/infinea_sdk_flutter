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

  InfineaSdkFlutter._internal();

  int nextListenerId = 1;

  CancelListening startListening(Listener listener) {
    var subscription = _eventChannel
        .receiveBroadcastStream(nextListenerId++)
        .listen(listener, cancelOnError: true);
    return () {
      subscription.cancel();
    };
  }

  /// This must be the first function that gets called, and a valid develop key must be passed in, and validated, BEFORE any other functions get executed.
  /// @param {string} key The developer key given by IPC

  Future<Map?> setDeveloperKey({required String key}) async {
    try {
      final Map result = await _channel.invokeMethod('setDeveloperKey', [key]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Connect the hardware

  Future<void> connect() async {
    try {
      return await _channel.invokeMethod('connect');
    } catch (error) {
      print(error);
    }
  }

  /// Disconnect the hardware

  Future<void> disconnect() async {
    try {
      return await _channel.invokeMethod('disconnect');
    } catch (error) {
      print(error);
    }
  }

  /// Get the connected device info. Info will be passed to success function
  /// @param {SUPPORTED_DEVICE_TYPES} deviceType

  Future<Map> getConnectedDeviceInfo(
      {required SUPPORTED_DEVICE_TYPES type}) async {
    try {
      final Map result =
          await _channel.invokeMethod('getConnectedDeviceInfo', type.index);
      return result;
    } catch (error) {
      print(error);
    }
    return {};
  }

  /// Get the all connected devices info. Info will be passed to success function
  ///
  Future<List> getConnectedDevicesInfo() async {
    try {
      final List result =
          await _channel.invokeMethod('getConnectedDevicesInfo');
      return result;
    } catch (error) {
      print(error);
    }
    return [];
  }

  ///  Set pass-thru sync
  ///  @param {bool} value true or false

  Future<bool> setPassThroughSync({required bool value}) async {
    try {
      final bool result =
          await _channel.invokeMethod('setPassThroughSync', [value]);
      return result;
    } catch (error) {
      print(error);
    }
    return false;
  }

  /// Get pass-thru sync enabled or disabled

  Future<bool> getPassThroughSync() async {
    try {
      final bool result = await _channel.invokeMethod('getPassThroughSync');
      return result;
    } catch (error) {
      print(error);
    }
    return false;
  }

  /// Set the USB current
  /// @param {int} value Must be one of 500, 1000, 2100, 2400

  Future<int> setUSBChargeCurrent({required int value}) async {
    assert(value == 500 || value == 1000 || value == 2100 || value == 2400);
    try {
      final int result =
          await _channel.invokeMethod('setUSBChargeCurrent', [value]);
      return result;
    } catch (error) {
      print(error);
    }
    return -1;
  }

  /// Get current USB charge current

  Future<int?> getUSBChargeCurrent() async {
    try {
      final int? result = await _channel.invokeMethod('getUSBChargeCurrent');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Set IPC device sleep timer
  /// @param {int} timeIdle this is the idle time, connected or not, after which Linea will turn off. The default value is 5400 seconds (90 minutes)
  /// @param {int} timeDisconnected this is the time with no active program connection, after which Linea will turn off. The default value is 30 seconds

  Future<void> setAutoOffWhenIdle(
      {required int timeIdle, required int timeDisconnected}) async {
    try {
      return await _channel
          .invokeMethod('setAutoOffWhenIdle', [timeIdle, timeDisconnected]);
    } catch (error) {
      print(error);
    }
  }

  /// Get battery info

  Future<Map> getBatteryInfo() async {
    try {
      final Map result = await _channel.invokeMethod('getBatteryInfo');
      return result;
    } catch (error) {
      print(error);
    }
    return {};
  }

  /// Power on the RF module. Continuously leaving the RF module powered on will drain battery.

  Future<bool> rfInit() async {
    try {
      final bool result = await _channel.invokeMethod('rfInit');
      return result;
    } catch (error) {
      print(error);
    }
    return false;
  }

  /// Power down the RF module, when not in use.

  Future<bool> rfClose() async {
    try {
      final bool result = await _channel.invokeMethod('rfClose');
      return result;
    } catch (error) {
      print(error);
    }
    return false;
  }

  /// Get the scan button mode

  Future<int> barcodeGetScanButtonMode() async {
    try {
      final int result =
          await _channel.invokeMethod('barcodeGetScanButtonMode');
      return result;
    } catch (error) {
      print(error);
    }
    return -1;
  }

  /// Enable or Disable scan button.
  /// @param {bool} scanButtonMode true or false

  Future<bool?> barcodeSetScanButtonMode({required bool scanButtonMode}) async {
    try {
      final bool? result = await _channel
          .invokeMethod('barcodeSetScanButtonMode', [scanButtonMode]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Get the current barcode scan mode, one of SCAN_MODES
  Future<SCAN_MODES?> barcodeGetScanMode() async {
    try {
      final int result = await _channel.invokeMethod('barcodeGetScanMode');
      return SCAN_MODES.values[result];
    } catch (error) {
      print(error);
    }
  }

  /// Set a specific scan mode, one of SCAN_MODES
  /// @param {int} scanMode One of SCAN_MODES

  Future<bool?> barcodeSetScanMode({required SCAN_MODES scanMode}) async {
    try {
      final bool? result =
          await _channel.invokeMethod('barcodeSetScanMode', [scanMode.index]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Start scan engine. Can be used for on screen scan button

  Future<bool?> barcodeStartScan() async {
    try {
      final bool? result = await _channel.invokeMethod('barcodeStartScan');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Stop scan engine. If using an on screen scan button, call this after a barcode is read.

  Future<bool?> barcodeStopScan() async {
    try {
      final bool? result = await _channel.invokeMethod('barcodeStopScan');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Sets the sound, which is used upon successful barcode scan. This setting is not persistent and is best to configure it upon connect.
  ///    @note  A sample beep containing of 2 tones, each with 400ms duration, first one 2000Hz and second - 5000Hz will look int beepData[]=[2000,400,5000,400]
  ///    @param {BOOL} enabled turns on or off beeping
  ///    @param {List<int>} data an array of integer values specifying pairs of tone(Hz) and duration(ms).

  Future<bool?> barcodeSetScanBeep(
      {required bool enabled, required List<int> beepData}) async {
    try {
      final bool? result = await _channel
          .invokeMethod('barcodeSetScanBeep', [enabled, beepData]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Set sled's battery to charge iOS device.
  /// @param {bool} value true or false

  Future<bool?> setCharging({required bool value}) async {
    try {
      final bool? result = await _channel.invokeMethod('setCharging', [value]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Get information of a specific firmware file. Info will be passed to success function
  /// @param {string} resourcePath The path to resource file with "platforms/ios/www/resources" as the root folder, your files must be copied to here. If you have "platforms/ios/www/resources/test.txt", only pass "test.txt" as resourcePath parameter.

  Future<bool?> getFirmwareFileInformation(
      {required String resourcePath}) async {
    try {
      final bool? result = await _channel
          .invokeMethod('getFirmwareFileInformation', [resourcePath]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  ///Update firmware
  /// @param {string} resourcePath The path to resource file with "platforms/ios/www/resources" as the root folder, your files must be copied to here. If you have "platforms/ios/www/resources/test.txt", only pass "test.txt" as resourcePath parameter.

  Future<bool?> updateFirmwareData({required String resourcePath}) async {
    try {
      final bool? result =
          await _channel.invokeMethod('updateFirmwareData', [resourcePath]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Set encryption type
  /// @param {int} encryption algorithm used
  /// @param {int} keyID the ID of the key to use. The key needs to be suitable for the provided algorithm.
  /// @param {Map} params optional algorithm parameters.

  Future<bool?> emsrSetEncryption(
      {required int encryption,
      required int keyID,
      required Map params}) async {
    try {
      final bool? result = await _channel
          .invokeMethod('emsrSetEncryption', [encryption, keyID, params]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Set encryption active head
  /// @param {int} activeHead The encrypted head to use with all other emsr functions

  Future<bool?> emsrSetActiveHead({required int activeHead}) async {
    try {
      final bool? result =
          await _channel.invokeMethod('emsrSetActiveHead', [activeHead]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Fine-tunes which part of the card data will be masked, and which will be sent in clear text for display/print purposes
  /// @param {bool} showExpiration If set to TRUE, expiration date will be shown in clear text, otherwise will be masked
  /// @param {bool} showServiceCode if set to TRUE, service code will be shown in clear text, otherwise will be masked
  /// @param {int} unmaskedDigitsAtStart the number of digits to show in clear text at the start of the PAN, range from 0 to 6 (default is 4)
  /// @param {int} unmaskedDigitsAtEnd the number of digits to show in clear text at the end of the PAN, range from 0, to 4 (default is 4)
  /// @param {int} unmaskedDigitsAfter the number of digits to unmask after the PAN, i.e. 4 will give you the expiration, 7 will give expiration and service code (default is 0)

  Future<bool?> emsrConfigMaskedDataShowExpiration(
      {required bool showExpiration,
      required bool showServiceCode,
      required int unmaskedDigitsAtStart,
      required int unmaskedDigitsAtEnd,
      required int unmaskedDigitsAfter}) async {
    try {
      final bool? result =
          await _channel.invokeMethod('emsrConfigMaskedDataShowExpiration', [
        showExpiration,
        showServiceCode,
        unmaskedDigitsAtStart,
        unmaskedDigitsAtEnd,
        unmaskedDigitsAfter
      ]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Check if encrypted head is tampered

  Future<bool?> emsrIsTampered() async {
    try {
      final bool? result = await _channel.invokeMethod('emsrIsTampered');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Gets the key version from the keyID that is provided
  /// @param {int} keyID the ID of the key to get the version

  Future<bool?> emsrGetKeyVersion({required int keyID}) async {
    try {
      final bool? result =
          await _channel.invokeMethod('emsrGetKeyVersion', [keyID]);
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Returns general information about the encrypted head - firmware version, ident, serial number

  Future<Map?> emsrGetDeviceInfo() async {
    try {
      final Map? result = await _channel.invokeMethod('emsrGetDeviceInfo');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// Returns a string of iHUB Port Info

  Future<String?> iHUBGetPortsInfo() async {
    try {
      final String? result = await _channel.invokeMethod('iHUBGetPortsInfo');
      return result;
    } catch (error) {
      print(error);
    }
  }

  /// SDK Version

  static Future<String> get sdkVersion async {
    final String version = await _channel.invokeMethod('sdkVersion');
    return version;
  }
}
