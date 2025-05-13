//
//  NearbyMessage.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import MultipeerConnectivity

class NearbyMessageContent {
    
    init(id: String, type: MessageContentType) {
        self.type = type
        self.id = id
    }
    
    let type: MessageContentType
    
    static func typedFromJson(json: [String: Any]) -> NearbyMessageContent? {
        if let typeString: String = json["type"] as? String {
            let type = MessageContentType.fromString(value: typeString)
            if (type == MessageContentType.textRequest) {
                return NearbyMessageTextRequest.fromJson(json: json)
            }  else if (type == MessageContentType.textResponse) {
                return NearbyMessageTextResponse.fromJson(json: json)
            } else if (type == MessageContentType.filesRequest) {
                return NearbyMessageFilesRequest.fromJson(json: json)
            } else if (type == MessageContentType.filesResponse) {
                return NearbyMessageFilesResponse.fromJson(json: json)
            }
        }
        return nil;
    }
    
    static func fromJsonRaw(type: MessageContentType, json: [String: Any]) -> NearbyMessageContent? {
        if let id: String = json["id"] as? String {
            return NearbyMessageContent(id: id, type: type)
        }
        return nil;
    }
    
    func toJson() ->  [String : Any] {
        return ["type": type.name, "id": id]
    }
    
    let id: String
}

class NearbyMessageTextRequest : NearbyMessageContent {
    init(id: String, value: String) {
        self.value = value
        super.init(id: id, type: MessageContentType.textRequest)
    }
    
    static func fromJson(json:[String: Any]) -> NearbyMessageTextRequest? {
        if let value: String = json["value"] as? String,
           let content = NearbyMessageContent.fromJsonRaw(type: MessageContentType.textRequest, json:json) {
            return NearbyMessageTextRequest(id: content.id, value: value)
        }
        return nil;
    }
    
    override func toJson() ->  [String : Any] {
        return ["value": value].merging( super.toJson()) { (current, _) in current}
    }
    
    let value: String
}

class NearbyMessageTextResponse :NearbyMessageContent {
    
     init(id: String) {
         super.init(id: id, type: MessageContentType.textResponse)
    }
    
    static func fromJson( json: [String: Any]) -> NearbyMessageTextResponse? {
        let content = NearbyMessageContent.fromJsonRaw(type: MessageContentType.textResponse, json: json)
        if let requireContent = content {
            return NearbyMessageTextResponse(id: requireContent.id)
        }
        return nil
    }
}

class NearbyMessageFilesRequest : NearbyMessageContent {
    init(files: Array<String>, id: String) {
        self.files = files
        super.init(id: id, type: MessageContentType.filesRequest)
    }
    static func fromJson(json: [String: Any]) -> NearbyMessageFilesRequest? {
        let content = NearbyMessageContent.fromJsonRaw(type: MessageContentType.filesRequest, json: json)
        if let filesObjects: Array = json["files"] as? Array<Dictionary<String, AnyObject>> {
            let files : [String]? = filesObjects.map({ $0["path"] as? String }).compactMap({$0})
            if let requireContent = content {
                if let requireFiles = files {
                    return NearbyMessageFilesRequest(files: requireFiles, id: requireContent.id)
                }
            }
        }
        return nil;
    }
    let files: Array<String>
    
    override func toJson() ->  [String : Any] {
        return [
            "files": files.map{["path": $0]},
        ].merging( super.toJson()) { (current, _) in current}
    }
}

class NearbyMessageFilesResponse : NearbyMessageContent {
    init(id: String, response: Bool) {
        self.response = response
        super.init(id: id, type: MessageContentType.filesResponse)
    }
    static func fromJson( json: [String: Any]) -> NearbyMessageFilesResponse? {
        let message = NearbyMessageContent.fromJsonRaw(type: MessageContentType.filesResponse, json: json)
        if let requireMessage = message,
           let response = json["isAccepted"] as? Bool {
            return NearbyMessageFilesResponse(id: requireMessage.id, response: response)
        }
        return nil
    }
    override func toJson() ->  [String : Any] {
        return [
            "isAccepted": response
        ].merging( super.toJson()) { (current, _) in current}
    }
    
    let response: Bool
}


enum MessageContentType {
    case textRequest
    case textResponse
    case filesRequest
    case filesResponse
    
    static func fromString(value: String) -> MessageContentType {
        if (value == textRequest.name) {
            return textRequest
        } else if (value == textResponse.name) {
            return textResponse
        }  else if (value == filesRequest.name) {
            return filesRequest
        } else if (value == filesResponse.name) {
            return filesResponse
        } else {
            return textRequest
        }
    }
    
    var name : String {
        switch self {
        case .textRequest: return "textRequest"
        case .textResponse: return "textResponse"
        case .filesRequest: return "filesRequest"
        case .filesResponse: return "filesResponse"
        }
    }
}
