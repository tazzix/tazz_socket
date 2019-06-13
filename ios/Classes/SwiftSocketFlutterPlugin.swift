import Flutter
import UIKit
import SocketIO
import Starscream

public class SwiftSocketFlutterPlugin: NSObject, FlutterPlugin {
    
    var mChannel: FlutterMethodChannel?
    
    init(channel: FlutterMethodChannel) {
        mChannel = channel
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socket_flutter_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftSocketFlutterPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    var socketManager: SocketManager?
    var socket: SocketIOClient?
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    //result("iOS " + UIDevice.current.systemVersion)
    if call.method == "socket" {
        do{
            if let args = call.arguments as? [String: String],let url = args["url"] {
                let  ca_cert = Bundle.main.path(forResource: "ca", ofType: "cert")
                let  intermediate_cert = Bundle.main.path(forResource: "intermediate", ofType: "cert")
                var certs = [SSLCert]()
                if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: ca_cert!)) as Data {
                    let certificate = SSLCert(data: certificateData)
                    certs.append(certificate)
                }
                
                if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: intermediate_cert!)) as Data {
                    let certificate = SSLCert(data: certificateData)
                    certs.append(certificate)
                }
                
                let security: SocketIO.SSLSecurity = SocketIO.SSLSecurity(certs: certs, usePublicKeys: false)
                security.security.validatedDN = false
                
                socketManager = SocketManager(
                    socketURL: URL(string: url)!,
                    config: [
                        .log(true),
                        .compress,
                        .selfSigned(true),
                        .forceWebsockets(true),
                        .forceNew(true),
                        .security(security)
                    ])
                socket = socketManager!.defaultSocket
                result("created")
            }
            

        }catch let error as NSError{
            print(error)
        }
    }else if call.method == "connect" {
        if socket != nil {
            socket!.connect()
        }
    }else if call.method == "emit" {
        
        if let args = call.arguments as? [String: String], let message = args["message"],let topic = args["topic"]{
            let data = message.data(using: .utf8)!
            do {
                var dictonary:[String:AnyObject]?
                
                if let data = message.data(using: String.Encoding.utf8) {
                    
                    do {
                        dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        
                        socket!.emit(topic, dictonary!)
                        result("sent")
                    } catch let error as NSError {
                        print(error)
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }

        
    }else if call.method == "on" {
        if let args = call.arguments as? [String: String],let topic = args["topic"]{
            socket!.on(topic) {(data, ack) -> Void in
                var dictonary:[String:Any] = [:];
                print(data)
                dictonary["message"] = data[0];
                print(data[0])
                self.mChannel!.invokeMethod("received", arguments: dictonary)
                result("sent")
            }
        }

    }else if call.method == "unsubscribe" {
        let args = call.arguments as? [String: String]
        let topic: String! = args!["topic"]
        
        socket!.off(topic)
        result("unsubscribe")
    }
  }
}
