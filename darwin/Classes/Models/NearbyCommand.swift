//
//  NearbyCommand.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity


class NearbyStartCommand {
    
    init(id: String, senderName: String, filesCount: Int) {
        self.id = id
        self.senderName = senderName
        self.filesCount = filesCount
    }
    
    static func fromUserInfo(userInfo: NearbyUserInfo)-> NearbyStartCommand? {
        if let name = userInfo.dictionary["name"] as? String,
           let filesCount = userInfo.dictionary["filesCount"] as? Int,
           let id = userInfo.dictionary["id"] as? String
        {
            return NearbyStartCommand(id: id, senderName: name, filesCount: filesCount)
        }
        return nil
    }
    
    func toDictionary() -> [String: Any] {
        return ["name": senderName, "filesCount": filesCount, "id": id]
    }
    
    let id: String
    let senderName: String
    let filesCount: Int
}
