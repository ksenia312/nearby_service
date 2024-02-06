//
//  NearbyServicePluginOnReceived.swift
//  nearby_service
//
//  Created by Kseniia Nikitina on 4/2/24.
//

import Foundation
import Flutter

extension NearbyServicePlugin {
    
    @objc func onMessageReceived(notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = NearbyUserInfo.fromDictionary(userInfo: notification.userInfo) {
                print(userInfo)
                if let message = NearbyMessage.fromUserInfo(userInfo: userInfo) {
                    print(message)
                    if message.content is NearbyMessageFilesResponse {
                        print(message.content)
                        let response = message.content as! NearbyMessageFilesResponse
                        let cachedRequest = NearbyRequestsStore.instance.find(for: response.id)
                        if (response.response && cachedRequest != nil) {
                            print("send")
                            self.manager.sendFiles(
                                id: cachedRequest!.id,
                                paths: cachedRequest!.files,
                                with: message.senderPeerID.displayName
                            )
                            NearbyRequestsStore.instance.remove(for: cachedRequest!.id)
                        }
                    }
                    self.channel.invokeMethod(DART_COMMAND_MESSAGE_RECEIVED, arguments: message.toDartFormat())
                    
                } else if let command = NearbyStartCommand.fromUserInfo(userInfo: userInfo) {
                    NearbyFilesStore.instance.startReceiving(command: command)
                }
            }
        }
    }
    
    @objc func onResourceReceived(notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = NearbyUserInfo.fromDictionary(userInfo: notification.userInfo) {

                if let url = userInfo.dictionary["url"] as? URL {
                    NearbyFilesStore.instance.add(url: url)

                    if (NearbyFilesStore.instance.checkIsFull()) {

                        self.channel.invokeMethod(DART_COMMAND_RESOURCES_RECEIVED, arguments: NearbyFilesStore.instance.toDartFormat(peerID: userInfo.peerID))
                        NearbyFilesStore.instance.clear()
                    }
                }
            }
           
        }
    }
}
