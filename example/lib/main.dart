import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tazz_socket/tazz_socket.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _platformVersion = 'Unknown';
  static const String socket_topic = 'response';
  TazzSocket myIO = new TazzSocket();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    myIO.unsubscribe(socket_topic);
    myIO.disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        myIO.unsubscribe(socket_topic);
        myIO.disconnect();
        break;
      case AppLifecycleState.resumed:
        initPlatformState();
        break;
      default:
    }
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      myIO.socket('http://10.2.2.22:9006', '/v2/socket.io', 'websocket', true, true, true);
      myIO.connect();
      String jsonData = '{"hello":"hi"}';
      myIO.on(socket_topic,(data){
        debugPrint(data.toString());
      });
      myIO.emit('request',jsonEncode(jsonDecode(jsonData)));
    } on PlatformException {
      _platformVersion = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
