#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
import Foundation
#endif
import MultipeerConnectivity

public class NearbyServicePlugin: NSObject, FlutterPlugin{
    

    let manager: NearbyManager;
    let channel: FlutterMethodChannel
    
    init(manager: NearbyManager, channel: FlutterMethodChannel) {
        self.manager = manager
        self.channel = channel
    
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Workaround for https://github.com/flutter/flutter/issues/118103.
        #if os(iOS)
        let messenger = registrar.messenger()
        #else
        let messenger = registrar.messenger
        #endif
        
        let channel = FlutterMethodChannel(
            name: "nearby_service",
            binaryMessenger: messenger
        )
        let nearbyPeersChannel = FlutterEventChannel(
            name: "nearby_service_peers",
            binaryMessenger: messenger
        )
        let connectedDeviceChannel = FlutterEventChannel(
            name: "nearby_service_connected_device",
            binaryMessenger: messenger
        )
        let nearbyPeersStreamHandler = NearbyPeersStreamHandler()
        nearbyPeersChannel.setStreamHandler(nearbyPeersStreamHandler)
        
        let connectedDeviceStreamHandler = ConnectedDeviceStreamHandler()
        connectedDeviceChannel.setStreamHandler(connectedDeviceStreamHandler)
        
        let manager = NearbyManager()
        let instance = NearbyServicePlugin(manager: manager, channel: channel)
        
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(onMessageReceived),
            name: ON_MESSAGE_RECEIVED,
            object: nil
        )
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(onResourceReceived),
            name: ON_RESOURCE_RECEIVED,
            object: nil
        )
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        NearbyDevicesStore.instance.clear()
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "getPlatformVersion":
            #if os(iOS)
            result("iOS " + UIDevice.current.systemVersion)
            #elseif os(macOS)
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
            #endif
        case "getPlatformModel":
            #if os(iOS)
            result(UIDevice.current.name)
            #elseif os(macOS)
            result(Host.current().localizedName ?? "Mac")
            #endif
        case "initialize":
            manager.initialize(for: getArgument(for: "deviceName", call: call), result: result)
        case "getSavedDeviceName":
            manager.getSavedDeviceName(result: result)
        case "getCurrentDevice":
            manager.getCurrentDevice(result: result)
        case "openServicesSettings":
            manager.openServicesSettings(result: result)
        case "startAdvertising":
            manager.startAdvertising(result: result)
        case "startBrowsing":
            manager.startBrowsing(result: result)
        case "stopAdvertising":
            manager.stopAdvertising(result: result)
        case "stopBrowsing":
            manager.stopBrowsing(result: result)
        case "getPeers":
            manager.getPeers(result: result)
        case "invite":
            if let deviceId: String = getArgument(for: "deviceId", call: call)  {
                manager.invite(for: deviceId, result: result)
            } else {
                result(false)
            }
            
        case "acceptInvite":
            if let deviceId : String = getArgument(for: "deviceId", call: call) {
                manager.acceptInvite(for: deviceId, result: result)
            } else {
                result(false)
            }
            
        case "disconnect":
            if let deviceId: String = getArgument(for: "deviceId", call: call) {
                manager.disconnect(for: deviceId, result: result)
            } else {
                result(false)
            }
            
        case "send":
            if let contentJson: Dictionary<String, AnyObject> = getArgument(for: "content", call: call),
               let content: NearbyMessageContent = NearbyMessageContent.typedFromJson(json: contentJson) {
                if let receiver : Dictionary<String, AnyObject> =  getArgument(for: "receiver", call: call),
                   let receiverId : String = receiver["id"] as? String
                {
                    manager.send(for: content, with: receiverId, result: result)
                } else {
                    result(false)
                }
            } else {
                result(false)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    func getArgument<T>(for name: String, call: FlutterMethodCall) -> T? {
        guard let data = call.arguments as? Dictionary<String, AnyObject> else {
            return nil
        }
        guard let argument: T = data[name] as? T else {
            return nil
        }
        return argument
    }
}

