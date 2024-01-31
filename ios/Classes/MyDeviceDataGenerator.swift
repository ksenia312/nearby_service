import Foundation
import MultipeerConnectivity

let SERVICE_TYPE = "mp-connection"
let PEER_ID = "PEER-ID"
let DEVICE_NAME = "DEVICE-NAME"
let ON_MESSAGE_RECEIVED = Notification.Name("NearbySessionOnMessageReceived")

class MyDeviceDataGenerator {
    static func generate(name: String?) -> NearbyDevice {
        return NearbyDevice(
            peerID: ArchivedData.getPeerID(),
            name: ArchivedData.getRequireName(from: name),
            deviceType: UIDevice.current.model,
            os: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion
        )
    }
    
}

 
class ArchivedData {
    static func getPeerID() -> MCPeerID {
        if let archivedPeerID = getArchivedPeerID() {
            return archivedPeerID
        } else {
            let peerID = MCPeerID(
                displayName: UIDevice.current.name.replacingOccurrences(of: " ", with: "_") 
                + "_"
                + String(Int.random(in: 1000..<50000))
            )
            savePeerID(for: peerID)
            return peerID
        }
    }
    
    static func getRequireName(from name: String?) -> String {
        let archivedName = ArchivedData.getArchivedName()
        if let newName = name {
            if (archivedName != newName) {
                ArchivedData.saveName(for: newName)
            }
            return newName
        }
        return archivedName ?? UIDevice.current.name
    }

    static func getArchivedPeerID() -> MCPeerID? {
        guard let savedData = UserDefaults.standard.data(forKey: PEER_ID),
              let unarchivedPeerID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: savedData)
        else {
            return nil
        }
        return unarchivedPeerID
    }
    
    static func savePeerID(for peerID: MCPeerID) {
        
        do {
            UserDefaults.standard.set(
                try NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false),
                forKey: PEER_ID
            )
        } catch let e {
            Logger.error(message: e.localizedDescription)
        }
    }
    
    static func getArchivedName() -> String? {
        guard let savedData = UserDefaults.standard.data(forKey: DEVICE_NAME),
              let unarchivedName = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: savedData)
        else {
            return nil
        }
        return String(data: unarchivedName as Data, encoding: .utf8)
    }
    
    static func saveName(for name: String) {
        if let data = name.data(using: .utf8) {
            do {
                UserDefaults.standard.set(
                    try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false),
                    forKey: DEVICE_NAME
                )
            } catch let e {
                Logger.error(message: e.localizedDescription)
            }
        }
    }
}
