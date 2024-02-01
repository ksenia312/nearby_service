import Flutter
import MultipeerConnectivity
import UIKit

public class NearbyServicePlugin: NSObject, FlutterPlugin {
    
    let manager: NearbyManager;
    let channel: FlutterMethodChannel
    
    init(manager: NearbyManager, channel: FlutterMethodChannel) {
        self.manager = manager
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "nearby_service",
            binaryMessenger: registrar.messenger()
        )
        let nearbyPeersChannel = FlutterEventChannel(
            name: "nearby_service_peers",
            binaryMessenger: registrar.messenger()
        )
        let connectedDeviceChannel = FlutterEventChannel(
            name: "nearby_service_connected_device",
            binaryMessenger: registrar.messenger()
        )
        let nearbyPeersStreamHandler = NearbyPeersStreamHandler()
        nearbyPeersChannel.setStreamHandler(nearbyPeersStreamHandler)
        
        let connectedDeviceStreamHandler = ConnectedDeviceStreamHandler()
        connectedDeviceChannel.setStreamHandler(connectedDeviceStreamHandler)
        
        let manager = NearbyManager()
        let instance = NearbyServicePlugin(manager: manager, channel: channel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(onMessageReceived),
            name: ON_MESSAGE_RECEIVED,
            object: nil
        )
        
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        NearbyDevicesStore.instance.clear()
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getPlatformModel":
            result(UIDevice.current.name)
        case "initialize":
            if let deviceName: String = getArgument(for: "deviceName", call: call)  {
                manager.initialize(for: deviceName, result: result)
            } else {
                manager.initialize(for: nil, result: result)
            }
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
            if let content: Dictionary<String, AnyObject> = getArgument(for: "content", call: call),
                let message: String = content["value"] as? String {
                if let receiver : Dictionary<String, AnyObject> =  getArgument(for: "receiver", call: call),
                   let receiverId : String = receiver["id"] as? String
                {
                    manager.send(for: message, with: receiverId, result: result)
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
    @objc func onMessageReceived(notification: Notification) {
        DispatchQueue.main.async {
            let result = NearbyMessageConverter.convert(userInfo: notification.userInfo)
            self.channel.invokeMethod("invoke_nearby_service_message_received", arguments: result)
        }
    }
    
    private func getArgument<T>(for name: String, call: FlutterMethodCall) -> T? {
        guard let data = call.arguments as? Dictionary<String, AnyObject> else {
            return nil
        }
        guard let argument: T = data[name] as? T else {
            return nil
        }
        return argument
    }
}
