//
//  NearbyMessageConverter.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 29/1/24.
//

import Foundation
import MultipeerConnectivity

class NearbyMessageConverter {
    static func convert(userInfo: [AnyHashable : Any]?) -> String? {
        if let data = getMessageData(userInfo: userInfo),
           let peerID = getMessagePeerID(userInfo: userInfo) {
            return createMessage(data: data, peerID: peerID)
        }
        return nil
    }
    
    static private func getMessageData(userInfo: [AnyHashable : Any]?) ->  [String: String]? {
        do {
            if let data = userInfo?["data"] as? Data,
               let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return dictionary
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        return nil
    }
    
    static private func getMessagePeerID(userInfo: [AnyHashable:Any]?) -> MCPeerID? {
        return userInfo?["from"] as? MCPeerID
        
    }
    
    static private func createMessage(data: [String: String], peerID: MCPeerID)-> String? {
        do {
            if let message = data["message"],
               let name = data["name"] {
                
                var result: String?
                let jsonObject = [
                    "message": message,
                    "sender": ["id": peerID.displayName, "displayName": name],
                ] as [String : Any]
                
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    result = jsonString
                }
                return result
            }
        } catch let error {
            Logger.error(message: error.localizedDescription)
        }
        return nil
    }
}
