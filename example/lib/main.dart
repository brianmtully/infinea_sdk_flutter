import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infinea_sdk_flutter/infinea_sdk_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Map _deviceInfo = {};
  PlatformException _errorMessage;
  List events = [];
  InfineaSdkFlutter infinea;
  Function cancelListener;

  @override
  void dispose() {
    cancelListener();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> init() async {
    infinea = InfineaSdkFlutter();
    try {
      await infinea.setDeveloperKey(
        key: 'enterkeyhere',
      );
      print('set developer key');
    } catch (e) {
      print(e);
    }

    /*  try {
      await InfineaSdkFlutter.connect();
    } catch (e) {
      print(e);
    }*/
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                String sdkVersion = await InfineaSdkFlutter.sdkVersion;
                setState(() {
                  print(sdkVersion);
                });
              },
              child: Text('SDK VERSION'),
            ),
            TextButton(
              onPressed: () async {
                cancelListener = infinea.startListening((event) {
                  if (event['event'] == 'barcode') {
                    setState(() {
                      events.add(event);
                    });
                  }
                });
                await infinea.connect();
              },
              child: Text('Connect'),
            ),
            TextButton(
              onPressed: () async {
                await infinea.disconnect();
              },
              child: Text('Disconnect'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  _deviceInfo = await infinea.getConnectedDeviceInfo(type: -1);
                  print(_deviceInfo);
                } catch (e) {
                  _errorMessage = e;
                }
                setState(() {});
              },
              child: Text('Get Connected Device Info'),
            ),
            _deviceInfo != null ? Text(_deviceInfo.toString()) : Container(),
            _errorMessage != null ? Text(_errorMessage.message) : Container(),
            Text(events.toString()),
          ],
        ),
      ),
    );
  }
}
