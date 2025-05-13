//
//  ArchivedData.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity


class Archiver {
    static func getPeerID() -> MCPeerID? {
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
    
    
    static func getName() -> String? {
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
