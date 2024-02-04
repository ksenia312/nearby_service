//
//  NearbyFilesStore.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 3/2/24.
//

import Foundation

class NearbyFilesStore {
    static let instance = NearbyFilesStore()
    
    private var paths : [String] = []
    private var id: String? = nil
    private var maxCount: Int = 0
    private var count: Int = 0
    
    func startReceiving(command: NearbyStartCommand) {
        self.paths.removeAll()
        self.id = command.id
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
    
    func toDartFormat() -> String? {
        let pathsObject = paths.map { ["path": $0]}
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pathsObject)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return "[]"
        }
        return "[]"
    }
}
