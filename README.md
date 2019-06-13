
## socket_flutter_plugin

[socket_flutter_plugin on GitHub](https://github.com/toanphung/socket_flutter_plugin)


# tazz_socket
Fork of socket_flutter_plugin with additional Options for Socket.IO clients.


Support both Android and iOS, custom Options only on Android


### Definition:
```
Future<String> socket(url, path, transport, sslAcceptAll, forceNew, debug) async
```
* **URL** (String): protocol, server and port only, e.g.: 'http://10.2.2.22:9006'<br/>
* **Path** (String): relative path for socket, or empty; e.g.: '/v2/socket.io'<br/>
* **Transport** (String): transport to use, websocket OR polling<br/>
* **sslAcceptAll** (boolean): accept all SSL certificates, including self-signed?<br/>
* **forceNew** (boolean): force a new connection?<br/>
* **debug** (boolean): print debug statements from native code<br/>

## Usage:

### Pubspec:
```
tazz_socket: ^1.0.0
```

### Code:
```
import 'package:tazz_socket/tazz_socket.dart';
// ...

IO.socket('http://10.2.2.22:9006', '/v2/socket.io', 'websocket', true, true, true);
```


## Example
```
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
  SocketFlutterPlugin myIO = new SocketFlutterPlugin();

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

```
