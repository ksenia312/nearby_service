//
//  NearbyCommand.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation


class NearbyStartCommand {
    
    init( id: String, filesCount: Int) {
        self.id = id
        self.filesCount = filesCount
    }
    
    static func fromUserInfo(userInfo: NearbyUserInfo)-> NearbyStartCommand? {
        if let id = userInfo.dictionary["id"] as? String ,
           let filesCount = userInfo.dictionary["filesCount"] as? Int
        {
            return NearbyStartCommand(
               id: id, filesCount: filesCount
            )
        }
        return nil
    }
    
    func toDictionary() -> [String: Any] {
        return ["id": id, "filesCount": filesCount]
    }
    
    let id: String
    let filesCount: Int
}
