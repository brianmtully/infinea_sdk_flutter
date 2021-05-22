# Infinea SDK Plugin

(https://pub.dev/packages/infinea_sdk_flutter)

Flutter Plugin for Infinite Peripherals Infinea SDK. This plugin allows you to connect and use devices compatible with Infinea SDK.

## Usage

To use this plugin, add `infinea_sdk_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
You will need a application key and application id setup in the Infinite Peripherals Developer Portal

## Using Infinea SDK


### Example Usage

```dart
final InfineaSdkFlutter infinea = InfineaSdkFlutter();
      await infinea.setDeveloperKey(key: 'enteryourapplicationkeyhere');
      await infinea.connect();  
    Function cancelListener = infinea.startListening((event) {
      if (event['event'] == 'barcode') {
        print(event['data']);
      }
    });
    
    await infinea.disconnect();)
    cancelListener();

```
