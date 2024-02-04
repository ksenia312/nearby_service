//
//  NearbyDevicesStore.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 16/1/24.
//

import Foundation
import MultipeerConnectivity

class NearbyDevicesStore : NSObject {
    static let instance = NearbyDevicesStore()
    
    private var devices : [NearbyDevice] = []
    
    func getDevices() -> [NearbyDevice] {
        return devices
    }
    
    func find(for deviceId: String) -> NearbyDevice? {
        return devices.first { device in
            return device.peerID.displayName == deviceId
        }
    }

    
    func add(for peerID: MCPeerID, discoveryInfo: [String: String]? = nil) -> NearbyDevice? {
        devices = devices.filter{$0.peerID.displayName != peerID.displayName}
        
        let device = NearbyDevice.fromDictionary(for: discoveryInfo, with: peerID)
        self.devices.append(device)
        
        return device
    }
    
    func remove(for peerID: MCPeerID) {
        self.devices = devices.filter{$0.peerID.displayName != peerID.displayName}
    }
    
    func clear() {
        self.devices = []
    }
    
    func toDartFormat() -> String {
        let devicesObject = devices.map { device in
            return device.toDictionary()
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: devicesObject)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return "[]"
        }
        return "[]"
    }
    
}
