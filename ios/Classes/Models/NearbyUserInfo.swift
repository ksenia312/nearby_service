//
//  NearbyUserInfo.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity

class NearbyUserInfo {
    init(peerID: MCPeerID, dictionary: [String: Any]) {
        self.peerID = peerID
        self.dictionary = dictionary
    }
    
    static func resource(peerID: MCPeerID, url: URL?) -> NearbyUserInfo? {
        var dictionary: [String: Any] = [:]
    
        if let requireUrl = url {
            dictionary["url"] = requireUrl
        }
        return NearbyUserInfo(
            peerID: peerID,
            dictionary: dictionary
        )
        
    }
    
    static func message(peerID: MCPeerID, data: Data) -> NearbyUserInfo? {
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return NearbyUserInfo(
                    peerID: peerID,
                    dictionary: dict
                )
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        return nil
    }
    
    static func fromDictionary(userInfo: [AnyHashable : Any]?) -> NearbyUserInfo? {
        if let dictionary = userInfo?["dictionary"] as? [String: Any],
        let peerID = userInfo?["peerID"] as? MCPeerID {
            return NearbyUserInfo(peerID: peerID, dictionary:dictionary)
        }
        return nil
    }
    
    func toDictionary() -> [AnyHashable : Any]? {
        return ["peerID": peerID, "dictionary": dictionary]
    }
    
    let peerID: MCPeerID
    let dictionary: [String: Any]
}
