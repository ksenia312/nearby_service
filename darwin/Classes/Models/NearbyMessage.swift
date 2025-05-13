//
//  NearbyMessage.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity


class NearbyMessage {
    init(content: NearbyMessageContent, senderName: String, senderPeerID: MCPeerID) {
        self.content = content
        self.senderName = senderName
        self.senderPeerID = senderPeerID
    }
    
    let content: NearbyMessageContent
    let senderPeerID: MCPeerID
    let senderName: String
    
    static func fromUserInfo(userInfo: NearbyUserInfo)-> NearbyMessage? {
        if let jsonContent = userInfo.dictionary["content"] as? [String : Any],
           let content = NearbyMessageContent.typedFromJson(json: jsonContent),
           let name = userInfo.dictionary["name"] as? String {
            return NearbyMessage(
                content: content,
                senderName: name,
                senderPeerID: userInfo.peerID
            )
        }
        return nil
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": senderName,
            "content": content.toJson()
        ]
    }
    
    func toDartFormat() -> String? {
        do {
            let object = [
                "sender":  ["id": senderPeerID.displayName, "displayName": senderName],
                "content": content.toJson()
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: object)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        return nil
    }
}


