//
//  NearbyFilesStore.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 3/2/24.
//

import Foundation
import MultipeerConnectivity

class NearbyFilesStore {
    static let instance = NearbyFilesStore()
    
    private var paths : [String] = []
    private var senderName: String? = nil
    private var maxCount: Int = 0
    private var count: Int = 0
    private var id: String? = nil
    
    func startReceiving(command: NearbyStartCommand) {
        self.paths.removeAll()
        self.id = command.id
        self.senderName = command.senderName
        self.maxCount = command.filesCount
        self.count = 0
    }
    
    func add(url: URL) {
        paths.append(url.path)
        self.count = self.count + 1
    }
    
    func checkIsFull() -> Bool {
        return maxCount <= count
    }
    
    func clear() {
        self.id = nil
        self.paths.removeAll()
        self.senderName = nil
        self.maxCount = 0
        self.count = 0
    }
    
    func toDartFormat(peerID: MCPeerID) -> String? {
        if (senderName != nil && id != nil) {
            let object = [
                "id": id!,
                "files":  paths.map { ["path": $0]},
                "sender": ["id": peerID.displayName, "displayName": senderName!]
            ] as [String : Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: object)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            } catch {
                return nil
            }
            return nil
        }
        return nil
    }
}
