import 'dart:async';


import 'package:flutter/services.dart';

class TazzSocket {

  MethodChannel _channel = const MethodChannel('tazz_socket');

  Future<String> socket(url, path, transport, sslAcceptAll, forceNew, debug) async {
    final String socket = await _channel.invokeMethod('socket',<String, dynamic>{'url': url, 'path': path, 'transport': transport, 'sslAcceptAll': sslAcceptAll, 'forceNew': forceNew, 'debug': debug});
    return socket;
  }

  Future<String> emit(topic, message) async {
    final String success = await _channel.invokeMethod('emit',<String, dynamic>{'message': message, 'topic': topic});
    return success;
  }

  Future<Null> connect() async {
    final String socket = await _channel.invokeMethod('connect');
  }

  Future<Null> disconnect() async {
    final String socket = await _channel.invokeMethod('disconnect');
  }

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

  Future<String> unsubscribe(topic) async {
    final String success = await _channel.invokeMethod('unsubscribe', <String, dynamic>{'topic': topic});
    return success;
  }
}
