
import Foundation
import MultipeerConnectivity

class NearbyDevice : NSObject {
    var name: String
    var peerID: MCPeerID
    var deviceType: String?
    var os: String?
    var osVersion: String?
    var session: NearbySession?
    
    
    init(
        peerID: MCPeerID,
        name:String,
        deviceType:String? = nil,
        os: String? = nil,
        osVersion: String? = nil
    ) {
        self.name=name
        self.peerID = peerID
        self.deviceType=deviceType
        self.os=os
        self.osVersion=osVersion
    }
    
    func createSession(for peerID: MCPeerID) -> NearbySession {
        self.session = NearbySession.create(peerID: peerID)
        return session!
    }
    
    func deleteSession() {
        self.session = nil
    }
    
}

extension NearbyDevice {
    static func fromDictionary(for dictionary: [String: String]?, with peerID: MCPeerID) -> NearbyDevice {
        let device = NearbyDevice(
            peerID: peerID,
            name:(dictionary?["displayName"] as String?) ?? peerID.displayName,
            deviceType: dictionary?["deviceType"] as String?,
            os: dictionary?["os"] as String?,
            osVersion: dictionary?["osVersion"] as String?
        )
        return device
        
    }
    
    func toDictionary() -> [String: String] {
        var deviceDict: [String: String] = [
            "displayName": self.name,
            "id": self.peerID.displayName,
        ]
        if let os = self.os {
            deviceDict["os"] = os
        }
        if let deviceType = self.deviceType {
            deviceDict["deviceType"] = deviceType
        }
        if let osVersion = self.osVersion {
            deviceDict["osVersion"] = osVersion
        }
        if let session = self.session {
            deviceDict["state"] = String(session.state.rawValue)
        } else {
            deviceDict["state"] = String(0)
        }
        return deviceDict
    }
    
    func toDartFormat() -> String? {
        var result: String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: toDictionary())
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                result = jsonString
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        return result
    }
}
