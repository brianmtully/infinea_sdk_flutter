import 'package:flutter/material.dart';
import 'dart:async';

import 'package:infinea_sdk_flutter/infinea_sdk_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String sdkVersion = '';
  List? _devicesInfo = [];
  bool passThroughSyncReturnValue = false;
  String? _errorMessage;
  List events = [];
  InfineaSdkFlutter? infinea;
  Function? cancelListener;

  @override
  void dispose() {
    cancelListener!();
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
      await infinea?.setDeveloperKey(key: 'yourdeveloperkeyhere');
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
          mainAxisSize: MainAxisSize.max,
          children: [
            TextButton(
              onPressed: () async {
                sdkVersion = await InfineaSdkFlutter.sdkVersion;
                setState(() {});
              },
              child: Text('SDK VERSION'),
            ),
            Text(sdkVersion),
            TextButton(
              onPressed: () async {
                cancelListener = infinea?.startListening((event) {
                  if (event['event'] == 'barcode') {
                    setState(() {
                      events.add(event);
                    });
                  }
                });
                await infinea?.connect();
              },
              child: Text('Connect'),
            ),
            TextButton(
              onPressed: () async {
                await infinea?.disconnect();
              },
              child: Text('Disconnect'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  _devicesInfo = await infinea?.getConnectedDevicesInfo();
                  _errorMessage = null;
                } catch (e) {
                  _errorMessage = e.toString();
                  _devicesInfo = null;
                }
                setState(() {});
              },
              child: Text('Get Connected Devices Info'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (passThroughSyncReturnValue == true) {
                    passThroughSyncReturnValue = await infinea?.setPassThroughSync(value: false) ?? false;
                  } else {
                    passThroughSyncReturnValue = await infinea?.setPassThroughSync(value: true) ?? false;
                  }
                  setState(() {
                    _errorMessage = null;
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = e.toString();
                  });
                }
              },
              child: Text('Set Passthrough Sync'),
            ),
            _devicesInfo != null ? Text(_devicesInfo.toString()) : Container(),
            _errorMessage != null ? Text("$_errorMessage") : Container(),
            Text("Events:"),
            Text(events.toString()),
            Text(passThroughSyncReturnValue.toString()),
          ],
        ),
      ),
    );
  }
}
