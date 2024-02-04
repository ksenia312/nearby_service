//
//  NearbyMessage.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity

class NearbyMessageContent {
    
    init(type: MessageContentType) {
        self.type = type
    }
    
    let type: MessageContentType
    
    static func typedFromJson(json: [String: Any]) -> NearbyMessageContent? {
        if let typeString: String = json["type"] as? String {
            let type = MessageContentType.fromString(value: typeString)
            if (type == MessageContentType.text) {
                return NearbyMessageTextContent.fromJson(json: json)
            } else if (type == MessageContentType.filesRequest) {
                return NearbyMessageFilesRequest.fromJson(json: json)
            } else if (type == MessageContentType.filesResponse) {
                return NearbyMessageFilesResponse.fromJson(json: json)
            }
        }
        return nil;
    }
    
    
    func toJson() ->  [String : Any] {
        return ["type": type.name]
    }
}

class NearbyMessageTextContent : NearbyMessageContent {
    init(value: String) {
        self.value = value
        super.init(type: MessageContentType.text)
    }
    
    static func fromJson(json:[String: Any]) -> NearbyMessageTextContent? {
        if let message: String = json["value"] as? String {
            return NearbyMessageTextContent(value: message)
        }
        return nil;
    }
    
    override func toJson() ->  [String : Any] {
        return ["value": value].merging( super.toJson()) { (current, _) in current}
    }
    
    let value: String
}

class NearbyMessageFilesContent : NearbyMessageContent {
    
    init(files: Array<String>, id: String, type: MessageContentType) {
        self.files = files
        self.id = id
        super.init(type: type)
    }
    
    static func fromJsonRaw(type: MessageContentType, json: [String: Any]) -> NearbyMessageFilesContent? {
        if let filesObjects: Array = json["files"] as? Array<Dictionary<String, AnyObject>> {
            let files : [String]? = filesObjects.map({ $0["path"] as? String }).compactMap({$0})
            if let id: String = json["id"] as? String{
                if let requireFiles = files {
                    return NearbyMessageFilesContent(files: requireFiles, id: id, type: type)
                }
            }
        }
        return nil;
    }
    
    override func toJson() ->  [String : Any] {
        return [
            "files": files.map{["path": $0]},
            "id": id,
        ].merging( super.toJson()) { (current, _) in current}
    }
    
    let files: Array<String>
    let id: String
}

class NearbyMessageFilesRequest : NearbyMessageFilesContent {
    init(files: Array<String>, id: String) {
        super.init(files: files, id: id, type: MessageContentType.filesRequest)
    }
    static func fromJson( json: [String: Any]) -> NearbyMessageFilesRequest? {
        let message = NearbyMessageFilesContent.fromJsonRaw(type: MessageContentType.filesRequest, json: json)
        if let requireMessage = message {
            return NearbyMessageFilesRequest(files: requireMessage.files, id: requireMessage.id)
        }
        return nil
    }
}
class NearbyMessageFilesResponse : NearbyMessageFilesContent {
    init(files: Array<String>, id: String, response: Bool) {
        self.response = response
        super.init(files: files, id: id, type: MessageContentType.filesResponse)
    }
    static func fromJson( json: [String: Any]) -> NearbyMessageFilesResponse? {
        let message = NearbyMessageFilesContent.fromJsonRaw(type: MessageContentType.filesResponse, json: json)
        if let requireMessage = message,
           let response = json["response"] as? Bool {
            return NearbyMessageFilesResponse(files: requireMessage.files, id: requireMessage.id, response: response)
        }
        return nil
    }
    override func toJson() ->  [String : Any] {
        return [
            "response": response
        ].merging( super.toJson()) { (current, _) in current}
    }
    
    let response: Bool
}


enum MessageContentType {
    case text
    case filesRequest
    case filesResponse
    
    static func fromString(value: String) -> MessageContentType {
        if (value == text.name) {
            return text
        } else if (value == filesRequest.name) {
            return filesRequest
        } else if (value == filesResponse.name) {
            return filesResponse
        } else {
            return text
        }
    }
    
    var name : String {
        switch self {
        case .text: return "text"
        case .filesRequest: return "filesRequest"
        case .filesResponse: return "filesResponse"
        }
    }
}