import Foundation
import MultipeerConnectivity
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
import Foundation
#endif


class MyDeviceDataGenerator {
    static func generate(name: String?) -> NearbyDevice {
        return NearbyDevice(
            peerID: getPeerID(),
            name: getNameArchived(or: name),
            deviceType: getDeviceType(),
            os: getOSName(),
            osVersion: getOSVersion()
        )
    }
    
    static private func getDeviceType() -> String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        return "Mac"
        #endif
    }
    
    static private func getOSName() -> String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "macOS"
        #endif
    }
    
    static private func getOSVersion() -> String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }
    static private func getPeerID() -> MCPeerID {
        if let archivedPeerID = Archiver.getPeerID() {
            return archivedPeerID
        } else {
            let deviceName: String
            #if os(iOS)
            deviceName = UIDevice.current.name
            #elseif os(macOS)
            deviceName = Host.current().localizedName ?? "Mac"
            #endif
            
            let peerID = MCPeerID(
                displayName: deviceName.replacingOccurrences(of: " ", with: "_")
                + "_"
                + String(Int.random(in: 1000..<50000))
            )
            Archiver.savePeerID(for: peerID)
            return peerID
        }
    }
    static private func getNameArchived(or name: String?) -> String {
        let archivedName = Archiver.getName()
        if let newName = name {
            if (archivedName != newName) {
                Archiver.saveName(for: newName)
            }
            return newName
        }
        #if os(iOS)
        return archivedName ?? UIDevice.current.name
        #elseif os(macOS)
        return archivedName ?? (Host.current().localizedName ?? "Mac")
        #endif
    }
    
}
