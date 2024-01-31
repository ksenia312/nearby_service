//
//  NearbySession.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 16/1/24.
//

import Foundation
import MultipeerConnectivity

class NearbySession: NSObject {
    var session: MCSession!
    var state: MCSessionState = MCSessionState.notConnected

    private init(peerID: MCPeerID) {
        self.session = MCSession(peer: peerID)
    }
    
    static func create(peerID: MCPeerID) -> NearbySession {
        let instance = NearbySession(peerID: peerID)
        instance.session.delegate = instance
        return instance
    }
}


extension NearbySession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.state = state

    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NotificationCenter.default.post(
            name: ON_MESSAGE_RECEIVED,
            object: nil,
            userInfo: ["from": peerID, "data": data]
        )
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}
