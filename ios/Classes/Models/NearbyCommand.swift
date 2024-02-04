//
//  NearbyCommand.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity


class NearbyStartCommand {
    
    init(senderName: String, filesCount: Int) {
        self.senderName = senderName
        self.filesCount = filesCount
    }
    
    static func fromUserInfo(userInfo: NearbyUserInfo)-> NearbyStartCommand? {
        if let name = userInfo.dictionary["name"] as? String,
           let filesCount = userInfo.dictionary["filesCount"] as? Int
        {
            return NearbyStartCommand(senderName: name, filesCount: filesCount)
        }
        return nil
    }
    
    func toDictionary() -> [String: Any] {
        return ["name": senderName, "filesCount": filesCount]
    }
    
    let senderName: String
    let filesCount: Int
}
