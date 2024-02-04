import Foundation
import MultipeerConnectivity


class MyDeviceDataGenerator {
    static func generate(name: String?) -> NearbyDevice {
        return NearbyDevice(
            peerID: getPeerID(),
            name: getNameArchived(or: name),
            deviceType: UIDevice.current.model,
            os: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion
        )
    }
    static private func getPeerID() -> MCPeerID {
        if let archivedPeerID = Archiver.getPeerID() {
            return archivedPeerID
        } else {
            let peerID = MCPeerID(
                displayName: UIDevice.current.name.replacingOccurrences(of: " ", with: "_")
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
        return archivedName ?? UIDevice.current.name
    }
    
}
