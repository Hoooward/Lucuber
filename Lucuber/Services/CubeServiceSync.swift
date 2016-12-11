//
//  CubeServiceSync.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift


/// 发送消息

//func sendText(text: String, toRecipient: String, recipientType: String, afterCreatedMessage: ((Message) -> Void)?, failureHandler: (() -> Void)?, completion: ((Bool) -> Void)?) {
//    
//    
//    guard let realm = try? Realm() else {
//        return
//    }
//    
//    // 创建新的实例
//    let message = Message()
//    
//    // 保证创建的新消息时间为最最最最新
//    if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
//        
//        if message.createdUnixTime < latestMessage.createdUnixTime {
//            message.createdUnixTime = latestMessage.createdUnixTime + 0.0005
//            //                                printLog("adjust")
//        }
//    }
//    
//    // 暂时只处理文字消息
//    message.mediaType = MessageMediaType.text.rawValue
//    // 发送的消息默认下载完成
//    message.downloadState = MessageDownloadState.downloaded.rawValue
//    message.sendState = MessageSendState.notSend.rawValue
//    // 自己发的消息默认已读
//    message.readed = true
//    
//    
//    // 添加到 Realm
//    try? realm.write {
//        realm.add(message)
//    }
//    
//    // message 的 creatUser = me
//    if let me = tryGetOrCreatMeInRealm(realm: realm) {
//        
//        try? realm.write {
//            message.creatUser = me
//        }
//    }
//    
//    
//    // 如果没有 Conversation ，创建
//    var conversation: Conversation? = nil
//    
//    try? realm.write {
//        
//        if recipientType == "User" {
//            
//            if let withFriend = userWithUserID(userID: toRecipient, inRealm: realm) {
//                conversation = withFriend.conversation
//            }
//            
//        } else {
//            
//            if let withGroup = groupWithGroupID(groupID: toRecipient, inRealm: realm) {
//                conversation = withGroup.conversation
//            }
//        }
//        
//        if conversation == nil {
//            
//            let newConversation = Conversation()
//            
//            if recipientType == "User" {
//                
//                newConversation.type = ConversationType.oneToOne.rawValue
//                
//                if let withFriend = userWithUserID(userID: toRecipient, inRealm: realm) {
//                    newConversation.withFriend = withFriend
//                }
//                
//            } else {
//                
//                newConversation.type = ConversationType.group.rawValue
//                
//                if let withGroup = groupWithGroupID(groupID: toRecipient, inRealm: realm){
//                    newConversation.withGroup = withGroup
//                }
//                
//            }
//            
//            conversation = newConversation
//            
//        }
//        
//        if let conversation = conversation {
//            
//            message.conversation = conversation
//            message.recipientID = conversation.recipiendID ?? ""
//            message.recipientType = recipientType
//            
//            // 创建日期 section
//            tryCreatDateSectionMessage(withNewMessage: message, conversation: conversation, realm: realm, completion: {
//                sectionDateMessage in
//                
//                if let sectionDateMessage = sectionDateMessage {
//                    
//                    realm.add(sectionDateMessage)
//                }
//            })
//            
//            conversation.updateUnixTime = Date().timeIntervalSince1970
//            
//            // 发送通知, Convertaion 有新的
//        }
//        
//    }
//    
//    try? realm.write {
//        message.textContent = text
//    }
//    
//    afterCreatedMessage?(message)
//    
//    
//    // 音效
//    
//    //  执行网络发送网络发送
//    
//    convertToLeanCloudMessageAndSend(message: message, failureHandler: {
//        
//        failureHandler?()
//        
//        }, completion: { _ in
//            
//            completion?(true)
//    })
//    
//}
