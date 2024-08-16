import Foundation
import Flutter
import MultipeerConnectivity

class NearbyManager: NSObject {
    var device: NearbyDevice!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    var invitationHandlers: [String: ((Bool, MCSession?) -> Void)] = [:]
    
    
    func initialize(for deviceName: String? = nil, result: @escaping FlutterResult) {
        self.device = MyDeviceDataGenerator.generate(name: deviceName)
        
        self.advertiser = MCNearbyServiceAdvertiser(
            peer: self.device.peerID,
            discoveryInfo: self.device.toDictionary(),
            serviceType: SERVICE_TYPE
        )
        self.advertiser.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: self.device.peerID, serviceType: SERVICE_TYPE)
        self.browser.delegate = self
        
        result(true)
    }
    
    func getSavedDeviceName(result: @escaping FlutterResult) {
        result(Archiver.getName())
    }
    
    func getCurrentDevice(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        result(device.toDartFormat())
    }
    
    func openServicesSettings(result: @escaping FlutterResult) {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        result(true)
    }
    
    func startAdvertising(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
            
        self.advertiser.startAdvertisingPeer()
        result(true)
    }
    
    func startBrowsing(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        self.browser.startBrowsingForPeers()
        result(true)
    }
    
    func stopAdvertising(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        self.advertiser.stopAdvertisingPeer()
        NearbyDevicesStore.instance.clear()
        result(true)
    }
    
    func stopBrowsing(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        self.browser.stopBrowsingForPeers()
        NearbyDevicesStore.instance.clear()
        result(true)
    }
    
    func getPeers(result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        result(NearbyDevicesStore.instance.toDartFormat())
    }
    
    func invite(for deviceId: String, result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        do {
            let device = NearbyDevicesStore.instance.find(for: deviceId)
            if let requireDevice = device {
                let nearbySession = requireDevice.createSession(for: self.device.peerID)
                self.browser.invitePeer(
                    requireDevice.peerID,
                    to: nearbySession.session,
                    withContext: try JSONSerialization.data(withJSONObject:["displayName": self.device.name]),
                    timeout: 0
                )
                result(true)
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
            result(false)
        }
    }
    func acceptInvite(for deviceId: String, result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        let device = NearbyDevicesStore.instance.find(for: deviceId)
        if let requireDevice = device {
            let nearbySession = requireDevice.createSession(for: self.device.peerID)
            self.invitationHandlers[deviceId]?(true, nearbySession.session)
            result(true)
        }
    }
    
    func disconnect(for deviceId: String, result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        let device = NearbyDevicesStore.instance.find(for: deviceId)
        device?.deleteSession()
        result(true)
    }
    
    func send(for content: NearbyMessageContent, with receiverId: String, result: @escaping FlutterResult) {
        if (!checkInitialization(result: result)) { return }
        
        let device = NearbyDevicesStore.instance.find(for: receiverId)

        do {
            if let requireDevice = device {
                let message = NearbyMessage(content: content, senderName: self.device.name, senderPeerID: self.device.peerID)
                
                if (content is NearbyMessageFilesRequest) {
                   NearbyRequestsStore.instance.add(request: message.content as! NearbyMessageFilesRequest)
               }
                try requireDevice.session?.session?.send(
                    try JSONSerialization.data(withJSONObject: message.toDictionary()),
                    toPeers: [requireDevice.peerID],
                    with: MCSessionSendDataMode.reliable
                )
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        
        result(true)
    }
    
    func sendFiles(id: String, paths: [String], with receiverId: String) {
        do {
            let device = NearbyDevicesStore.instance.find(for: receiverId)
            if let requireDevice = device {
                let command = NearbyStartCommand(
                    id: id,
                    senderName: self.device.name,
                    filesCount: paths.count
                ).toDictionary()

                try requireDevice.session?.session?.send( 
                    try JSONSerialization.data(withJSONObject: command),
                    toPeers: [requireDevice.peerID],
                    with: MCSessionSendDataMode.reliable
                )

                for path in paths {
                     let url = URL(fileURLWithPath: path)
                        if FileManager.default.fileExists(atPath: url.path) {
                            requireDevice.session?.session?.sendResource(
                                at: url,
                                withName: url.lastPathComponent,
                                toPeer: requireDevice.peerID
                            )
                        } else {
                            Logger.error(message: "File does not exist: " + path)
                        }
                    
                }
            }
        }  catch let error {
            Logger.error(message: error.localizedDescription)
        }
    }
    
    func checkInitialization(result: @escaping FlutterResult) -> Bool {
        guard let _ = self.device,
              let _ = self.advertiser,
              let _ = self.browser else {
            Logger.error(message: "NearbyManager is not initialized. Please call 'initialize()' first")
            result(ERROR_NO_INITIALIZATION)
            return false
        }
        
        return true
    }
}

extension NearbyManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        var dict: Dictionary<String, String>?
        do {
            dict = try JSONSerialization.jsonObject(with: context ?? Data()) as? Dictionary<String, String>
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        _ = NearbyDevicesStore.instance.add(for: peerID, discoveryInfo: dict)
        self.invitationHandlers[peerID.displayName] = invitationHandler
        
    }
}

extension NearbyManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        _ = NearbyDevicesStore.instance.add(for: peerID, discoveryInfo: info)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let device = NearbyDevicesStore.instance.find(for: peerID.displayName)
        device?.deleteSession()
        NearbyDevicesStore.instance.remove(for: peerID)
    }
}
