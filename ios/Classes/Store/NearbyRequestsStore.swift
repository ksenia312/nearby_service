//
//  NearbyRequestsStore.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 5/2/24.
//

import Foundation

class NearbyRequestsStore {
    static let instance = NearbyRequestsStore()
    
    private var requests : [NearbyMessageFilesRequest] = []
   
    
    func add(request: NearbyMessageFilesRequest) {
        requests.append(request)
    }
    
    func find(for id: String) -> NearbyMessageFilesRequest? {
        return requests.first { request in
            return request.id == id
        }
    }
 
    func remove(for id: String) {
        self.requests = requests.filter{$0.id != id}
    }
}
