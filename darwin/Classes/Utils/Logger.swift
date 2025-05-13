//
//  Logger.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 26/1/24.
//

import Foundation


class Logger {
    static func error(message: String) {
        NSLog("NearbyServicePluginError -- %@", message)
    }
}
