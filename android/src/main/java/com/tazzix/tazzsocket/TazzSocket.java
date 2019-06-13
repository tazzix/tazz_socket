package com.tazzix.tazzsocket;

import android.util.Log;
import android.app.Activity;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.github.nkzawa.emitter.Emitter;
import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;

import org.json.JSONException;
import org.json.JSONObject;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

/** SocketFlutterPlugin */
public class TazzSocket implements MethodCallHandler {
  /** Plugin registration. */

  private Activity activity;
  private Socket mSocket;
  private MethodChannel channel;
  private boolean debug = false;

  public TazzSocket(MethodChannel channel, Activity activity) {
    this.channel = channel;
    this.activity = activity;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "tazz_socket");
    channel.setMethodCallHandler(new TazzSocket(channel, registrar.activity()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("socket")) {
      {
        debug = call.argument("debug");

        try {
          SSLContext mySSLContext = SSLContext.getInstance("TLS");
          TrustManager[] trustAllCerts = new TrustManager[] { 
            new X509TrustManager() {
              public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                return new java.security.cert.X509Certificate[] {};
              }

              public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType)
                  throws java.security.cert.CertificateException {
              }

              public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType)
                  throws java.security.cert.CertificateException {
              }
            } 
          };

          mySSLContext.init(null, trustAllCerts, null);

          HostnameVerifier myHostnameVerifier = new HostnameVerifier() {
            @Override
            public boolean verify(String hostname, SSLSession session) {
              return true;
            }
          };
          IO.Options opts = new IO.Options();
          opts.forceNew = call.argument("sslAcceptAll");
          if (call.argument("sslAcceptAll")) opts.sslContext = mySSLContext;
          opts.path = call.argument("path");
          opts.transports = new String[] { call.argument("transport") };
          opts.hostnameVerifier = myHostnameVerifier;
          String url = call.argument("url");// , opts);
          mSocket = IO.socket(url, opts);
          if (debug) Log.d("SocketIO ", "Socket initialised: " + url);
        } catch (Exception e) {
          if (debug) Log.e("SocketIO ", e.toString());
        }
      }
      result.success("created");

    } else if (call.method.equals("connect")) {
      mSocket.connect();
      if (debug) Log.d("SocketIO  ", "Connected");
      result.success("connected");
    } else if (call.method.equals("disconnect")) {
      mSocket.disconnect();
      if (debug) Log.d("SocketIO  ", "Disconnected");
      result.success("disconnected");
    } else if (call.method.equals("emit")) {
      String message = call.argument("message");
      String topic = call.argument("topic");
      if (debug) Log.d("SocketIO  ", "Pushing " + message + " on topic " + topic);
      JSONObject jb = null;
      try {
        jb = new JSONObject(message);
      } catch (JSONException e) {
        e.printStackTrace();
      }
      if (jb != null) {
        mSocket.emit(topic, jb);
        result.success("sent");
      }

    } else if (call.method.equals("on")) {
      String topic = call.argument("topic");
      if (debug) Log.d("SocketIO  ", "registering to " + topic + " topic");
      mSocket.on(topic, onNewMessage);
      result.success("sent");
    } else if (call.method.equals("unsubscribe")) {
      String topic = call.argument("topic");
      mSocket.off(topic);
    } else {
      result.notImplemented();
      if (debug) Log.d("SocketIO ", "Not Implemented");
    }
  }

  private Emitter.Listener onNewMessage = new Emitter.Listener() {
    @Override
    public void call(final Object... args) {
      String data = args[0].toString();
      if (debug) Log.d("SocketIO ", "Received " + data);
      final Map<String, String> myMap = new HashMap<String, String>();
      myMap.put("message", data);
      // Run this in the UI thread to avoid a crash in flutter engine.
      activity.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod("received", myMap);
        }
      });
    }
  };
}
