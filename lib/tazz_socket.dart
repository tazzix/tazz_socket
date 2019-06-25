import 'dart:async';


import 'package:flutter/services.dart';

class TazzSocket {

  MethodChannel _channel = const MethodChannel('tazz_socket');

  /// Method to construct and initialize a socket object
  /// 
  /// Takes a base URL, path, transport (websocket|polling), wether to accept all certs, force a new connection everytime, or if to enable debug log
  Future<String> socket(url, path, transport, sslAcceptAll, forceNew, debug) async {
    final String socket = await _channel.invokeMethod('socket',<String, dynamic>{'url': url, 'path': path, 'transport': transport, 'sslAcceptAll': sslAcceptAll, 'forceNew': forceNew, 'debug': debug});
    return socket;
  }

  /// Emit a message on the socket for the given topic
  /// 
  /// Takes a topic to emit on and a message to emit
  Future<String> emit(topic, message) async {
    final String success = await _channel.invokeMethod('emit',<String, dynamic>{'message': message, 'topic': topic});
    return success;
  }

  /// Connects the socket encapsulated by the object
  Future<Null> connect() async {
    await _channel.invokeMethod('connect');
  }

  /// Disconnects the socket encapsulated by the object
  Future<Null> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  /// Register a listener for a topic on the socket
  /// 
  /// Takes a topic and a callback handler
  Future<String> on(String topic, Function _handle) async {
    final String socket = await _channel.invokeMethod('on', <String, dynamic>{'topic': topic});
    _channel.setMethodCallHandler((call) {
      if (call.method == 'received') {
        final String received = call.arguments['message'];
        Function.apply(_handle, [received]);
      }
    });
    return socket;
  }

  /// Unsubscribe a listener that was earlier registerd
  Future<String> unsubscribe(topic) async {
    final String success = await _channel.invokeMethod('unsubscribe', <String, dynamic>{'topic': topic});
    return success;
  }
}
