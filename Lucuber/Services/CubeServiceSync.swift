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

public enum MessageAge: String {
    case old = "old"
    case new = "new"
}


public func tryPostNewMessageReceivedNotification(withMessageIDs messageIDs: [String], messageAge: MessageAge) {
    
    if !messageIDs.isEmpty {
        
        DispatchQueue.main.async {
            
            let object = [
                "messageIDs": messageIDs,
                "messageAge": messageAge.rawValue
            ] as [String : Any]
            
            NotificationCenter.default.post(name: Notification.Name.newMessageIDsReceivedNotification, object: object)
        }
        
    }
    
}

public func syncUser(withUserObjectID objectID: String, failureHandler: (() -> Void)?, completion: ((AVUser?) -> Void)? ) {
    
    let query = AVQuery(className: "_User")
    
    query.getObjectInBackground(withId: objectID, block: { (user, error) in
        
        if error != nil {
            failureHandler?()
        }
        
        completion?(user as? AVUser)
        
    })
    
}



func syncMessage(withRecipientID recipientID: String?, messageAge: MessageAge, lastMessage: Message?, firstMessage: Message?, failureHandler: (() -> Void)?, completion: ((_ messagesID: [String]) -> Void)?) {
    
    
    guard let recipientID = recipientID else {
        
        printLog("并没有 recipientID")
        failureHandler?()
        return
    }
    
    let query = AVQuery(className: "DiscoverMessage")
    query.whereKey("recipientID", equalTo: recipientID)
    
    
//    query?.countObjectsInBackground({ (count, error) in
//        
//        if error != nil {
//            printLog("获取总数失败")
//        } else {
////            printLog("服务器端移动找到 \(count) 个 Message")
//        }
//    })
  
    
    switch messageAge {
    case .new:
        
        if let lastMessage = lastMessage {
            printLog("从本地 Realm 获取最新的 Message 创建日期, 开始请求更新的 Message")
            let maxCreatedUnixTime = lastMessage.createdUnixTime
            query.whereKey("createdAt", greaterThan:  NSDate(timeIntervalSince1970: maxCreatedUnixTime))
            
        } else {
            // 如果当前 Message 为空
            printLog("本地 Realm 中没有 Message, 开始请求最新的 20 条 Message")
            query.whereKey("createdAt", lessThanOrEqualTo: NSDate())
            query.order(byDescending: "createdAt")
            
        }
        
    case .old:
        
        if let firstMessage = firstMessage {
            printLog("从本地 Realm 获取最旧的 Message 创建日期, 开始请求更旧的 Message")
            let minCreatedUnixTime = firstMessage.createdUnixTime
            query.whereKey("createdAt", lessThan: NSDate(timeIntervalSince1970: minCreatedUnixTime))
        }
    }
    
    query.limit = 20
    // 此次请求需要将完整的 creatorUser 信息获取到.
    query.includeKey("creatarUser")
    query.findObjectsInBackground {
        result, error in
        
        if error != nil {
            printLog("网络请求 Messages 数据失败")
            failureHandler?()
        }
        
        var messageIDs = [String]()
        
        if let discoverMessages = result as? [DiscoverMessage] {
            
            guard let realm = try? Realm() else {
                return
            }
            
            printLog("共获取到 **\(discoverMessages.count)** 个新 DiscoverMessages")
            
            realm.beginWrite()
            if !discoverMessages.isEmpty { printLog("开始将 DiscoverMessage 转换成 Message 并存入本地") }
            discoverMessages.forEach {
                

                // 将 DiscoverMessage 转换成 Message
                
                convertDiscoverMessageToRealmMessage(discoverMessage: $0, messageAge: messageAge, realm: realm) {
                    newMessagesID in
                    
                    messageIDs += newMessagesID
                }
                
            }
            if !discoverMessages.isEmpty { printLog(" DiscoverMessage 转换成 Message 已完成") }
            
            try? realm.commitWrite()
            
            completion?(messageIDs)
        }
    }
    
}

func syncFormula(with uploadMode: UploadFormulaMode, categoty: Category, completion: (([DiscoverFormula]) -> Void)?, failureHandler:((Error?) -> Void)?) {
    
    switch uploadMode {
        
    case .my:
        
        let query = AVQuery.getFormula(mode: uploadMode)
        
        printLog( "开始从LeanCloud中获取我的公式")
        
        query.findObjectsInBackground {
            newFormulas, error in
            
            if error != nil {
                
                failureHandler?(error)
                
            }
            
            if let newFormulas = newFormulas as? [DiscoverFormula] {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                
                realm.beginWrite()
                if !newFormulas.isEmpty {
                    printLog("共下载到\(newFormulas.count)个公式 " )
                    printLog("开始将 DiscoverFormula 转换成 Formula 并存入本地 Realm")
                }
                
                newFormulas.forEach {
                    
                    convertDiscoverFormulaToFormula(discoverFormula: $0, realm: realm, completion: { formulas in
                        printLog(formulas.contentss)
                        
                    })
                }
                
                if !newFormulas.isEmpty { printLog("DiscoverFormula 转换 Formula 完成") }
                
                try? realm.commitWrite()
                
                completion?(newFormulas)
                
            }
            
        }
        
    case .library:
        
        break
        
    }
}

func convertDiscoverFormulaToFormula(discoverFormula: DiscoverFormula, realm: Realm, completion: ((Formula) -> Void)?) {
    
    if let lcObjectID = discoverFormula.objectId {
        
        // 尝试从数据库中查找是否已经有存在的 Formula
        var formula = formulaWith(objectID: lcObjectID, inRealm: realm)
        
        let deleted = discoverFormula.deletedByCreator
        
        if deleted {
            if
                let discoverFormulaCreatorID = discoverFormula.creator?.objectId,
                let myID = AVUser.current()?.objectId {
                
                if discoverFormulaCreatorID == myID {
                    
                    if let formula = formula {
                        realm.delete(formula)
                    }
                }
            }
        }
        
        if formula == nil {
            
            let newFormula = Formula()
            newFormula.lcObjectID = discoverFormula.objectId!
            newFormula.localObjectID = discoverFormula.localObjectID
            
            newFormula.name = discoverFormula.name
            
            newFormula.categoryString = discoverFormula.category
            newFormula.typeString = discoverFormula.type
            
            newFormula.imageName = discoverFormula.imageName
            
            newFormula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
            
            // 如果 discoverFormula 有 imageURL , 用户自己上传了 Image
            if discoverFormula.imageURL != "" {
                
                newFormula.imageURL = discoverFormula.imageURL
            }
            
            // content 还并未进行本地处理
            newFormula.contentsString = discoverFormula.contents
            
            newFormula.contentsString.forEach {
                
                let stringArray = $0.components(separatedBy: "--")
                
                if stringArray.count == 2 {
                    let content = Content()
                    let rotation = stringArray[0]
                    let text = stringArray[1]
                    
                    content.atFormula = newFormula
                    content.rotation = rotation
                    content.text = text
                    
                    realm.add(content)
                }
                
            }
            
            realm.add(newFormula)
            formula = newFormula
            
        }
        
        if let formula = formula {
            
            if let creatorID = discoverFormula.creator?.objectId {
                
                var creator = userWithUserID(userID: creatorID, inRealm: realm)
                
                if creator == nil {
                    
                    let newUser = discoverFormula.creator?.converRUserModel()
                    
                    
                    realm.add(newUser!)
                    
                    creator = newUser
                    
                }
                
                if let creator = creator {
                    
                    formula.creator = creator
                    
                }
            }
            
            completion?(formula)
        }
        
        
        
        
        
    }
    
    
}

func convertDiscoverMessageToRealmMessage(discoverMessage: DiscoverMessage, messageAge: MessageAge, realm: Realm, completion: ((_ newSectionMessageIDs: [String]) -> Void)?) {
    
   
    if let messageID = discoverMessage.objectId {
        
        // 尝试从数据库中取得与 ID 对应的 Message
        var message = messageWithMessageID(messageID: messageID, inRealm: realm)
        
        // 判断 Message 是否被作者删除
        let deleted = discoverMessage.deletedByCreator
        
        if deleted {
           if
            let discoverMessageCreatorUserID = discoverMessage.creatarUser.objectId,
            let meUserID = AVUser.current()?.objectId {
            
            if discoverMessageCreatorUserID == meUserID {
                
                if let message = message {
                    
                    realm.delete(message)
                }
            }
            
            }
        }
        
        if message == nil {
            
            // 如果本地没有这个 Message , 创建一个新的
            let newMessage = Message()
            newMessage.messageID = discoverMessage.objectId!
            newMessage.textContent = discoverMessage.textContent
            newMessage.mediaTypeInt = discoverMessage.mediaTypeInt
            // 全部标记为已读
            newMessage.sendStateInt = MessageSendState.read.rawValue
            
            newMessage.createdUnixTime = (discoverMessage.createdAt?.timeIntervalSince1970)!
            if case .new = messageAge {
                if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
                    if newMessage.createdUnixTime < latestMessage.createdUnixTime {
                        // 只考虑最近的消息，过了可能混乱的时机就不再考虑
                        if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
                            printLog("xbefore newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                            newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
                            printLog("xadjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                        }
                    }
                }
            }
            
            realm.add(newMessage)
            
            message = newMessage
        }
        
        if let message = message {
           
            // 创建本地不存在的 User
            if let messageCreatorUserID = discoverMessage.creatarUser.objectId {
                
                var sender = userWithUserID(userID: messageCreatorUserID, inRealm: realm)
                
                if sender == nil {
                   
                    let newUser = discoverMessage.creatarUser.converRUserModel()
                    
                    printLog(discoverMessage.creatarUser)
                    // TODO: 如果需要标记 newUser 为陌生人
                    
                    realm.add(newUser)
                    
                    sender = newUser
                    
                }
                
                if let sender = sender {
                    
                    message.creatUser = sender
                    message.recipientID = discoverMessage.recipientID
                    message.recipientType = discoverMessage.recipientType
                    // 判断 message 来自 group 还是 user
                    var senderFromGroup: Group? = nil
                    
                    if discoverMessage.recipientType == "group" {
                        
                        senderFromGroup = groupWithGroupID(groupID: discoverMessage.recipientID, inRealm: realm)
                        
                        // 如果没有在本地找到对应的 Group 创建它#0	0x00000001093889bd in convertDiscoverMessageToRealmMessage(discoverMessage : DiscoverMessage, messageAge : MessageAge, realm : Realm, completion : ([String]) -> ()?) -> () at /Users/tychooo/Desktop/Lucuber2/Lucuber/Services/CubeServiceSync.swift:189

                        if senderFromGroup == nil {
                           
                            let newGroup = Group()
                            newGroup.groupID = discoverMessage.recipientID
                            newGroup.incloudMe = true
                            
                            realm.add(newGroup)
                            
                            // TODO: - Group 需要后续完善, 可能需要同步到Leancloud.
                            
                            senderFromGroup = newGroup
                        }
                    }
                    
                    
                    var conversation: Conversation?
                    
                    var conversationWithUser: RUser?
                    
                    if let senderFromGroup = senderFromGroup {
                        conversation = senderFromGroup.conversation
                        
                    } else {
                        // 如果这个消息的发送者不是我自己
                        if let meUserID = AVUser.current()?.objectId, meUserID != sender.userID {
                            conversation = sender.conversation
                            conversationWithUser = sender
                            
                        } else {
                            
                            if discoverMessage.recipientID.isEmpty {
                                realm.delete(message)
                                return
                            }
                            
                            if let user = userWithUserID(userID: discoverMessage.recipientID, inRealm: realm) {
                                conversation = user.conversation
                                conversationWithUser = user
                                
                            } else {
                                
                                var newUser = RUser()
                                
                                newUser.userID = discoverMessage.recipientID
                                
                                realm.add(newUser)
                                
                                
                                syncUser(withUserObjectID: discoverMessage.recipientID, failureHandler: {
                                    printLog("获取新用户失败")
                                    }, completion: { user in
                                        
                                        guard let realm = try? Realm() else { return }
                                        
                                        if let user = user {
                                            
                                            try? realm.write {
                                                newUser = user.converRUserModel()
                                            }
                                        }
                                })
                            }
                            
                        }
                        
                    }
                        var createdNewConversation = false
                        
                        if conversation == nil {
                            
                            let newConversation = Conversation()
                            
                            if let senderFromGroup = senderFromGroup {
                                newConversation.type = ConversationType.group.rawValue
                                newConversation.withGroup = senderFromGroup
                            } else {
                                newConversation.type = ConversationType.oneToOne.rawValue
                                newConversation.withFriend = conversationWithUser
                            }
                            
                            realm.add(newConversation)
                            
                            conversation = newConversation
                            
                            createdNewConversation = true
                        }
                        
                        if let conversation = conversation {
                            
                            // TODO :- 同步已读
                            
                            //                                        if message.conversation == nil &&
                            //
                            
                            message.conversation = conversation
                            
                            var sectionDateMessageID: String?
                            
                            tryCreatDateSectionMessage(withNewMessage: message, conversation: conversation, realm: realm, completion: {
                                sectionDateMesage in
                                if let sectionDateMessage = sectionDateMesage {
                                    
                                    realm.add(sectionDateMessage)
                                }
                                
                                sectionDateMessageID = sectionDateMesage?.messageID
                                
                            })
                            
                            if createdNewConversation {
                                // 发送创建新的 Conversation 通知
                            }
                            
                            if let sectionDateMessageID = sectionDateMessageID {
                                
                                completion?([sectionDateMessageID, messageID])
                            } else {
                                completion?([messageID])
                            }
                        }
                        
                    }
                    
            }
            
        }
    
    }
}



/// 发送消息

func sendText(text: String, toRecipient: String, recipientType: String, afterCreatedMessage: ((Message) -> Void)?, failureHandler: (() -> Void)?, completion: ((Bool) -> Void)?) {
    
    
    guard let realm = try? Realm() else {
        return
    }
    
    // 创建新的实例
    let message = Message()
    
    // 保证创建的新消息时间为最最最最新
    if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
        
        if message.createdUnixTime < latestMessage.createdUnixTime {
            message.createdUnixTime = latestMessage.createdUnixTime + 0.0005
            //                                printLog("adjust")
        }
    }
    
    // 暂时只处理文字消息
    message.mediaTypeInt = MessageMediaType.text.rawValue
    // 发送的消息默认下载完成
    message.downloadState = MessageDownloadState.downloaded.rawValue
    message.sendStateInt = MessageSendState.notSend.rawValue
    // 自己发的消息默认已读
    message.readed = true
    
    
    // 添加到 Realm
    try? realm.write {
        realm.add(message)
    }
    
    // message 的 creatUser = me
    if let me = tryGetOrCreatMeInRealm(realm: realm) {
        
        try? realm.write {
            message.creatUser = me
        }
    }
    
    
    // 如果没有 Conversation ，创建
    var conversation: Conversation? = nil
    
    try? realm.write {
        
        if recipientType == "User" {
            
            if let withFriend = userWithUserID(userID: toRecipient, inRealm: realm) {
                conversation = withFriend.conversation
            }
            
        } else {
            
            if let withGroup = groupWithGroupID(groupID: toRecipient, inRealm: realm) {
                conversation = withGroup.conversation
            }
        }
        
        if conversation == nil {
            
            let newConversation = Conversation()
            
            if recipientType == "User" {
                
                newConversation.type = ConversationType.oneToOne.rawValue
                
                if let withFriend = userWithUserID(userID: toRecipient, inRealm: realm) {
                    newConversation.withFriend = withFriend
                }
                
            } else {
                
                newConversation.type = ConversationType.group.rawValue
                
                if let withGroup = groupWithGroupID(groupID: toRecipient, inRealm: realm){
                    newConversation.withGroup = withGroup
                }
                
            }
            
            conversation = newConversation
            
        }
        
        if let conversation = conversation {
            
            message.conversation = conversation
            message.recipientID = conversation.recipiendID ?? ""
            message.recipientType = recipientType
            
            // 创建日期 section
            tryCreatDateSectionMessage(withNewMessage: message, conversation: conversation, realm: realm, completion: {
                sectionDateMessage in
                
                if let sectionDateMessage = sectionDateMessage {
                    
                    realm.add(sectionDateMessage)
                }
            })
            
            conversation.updateUnixTime = Date().timeIntervalSince1970
            
            // 发送通知, Convertaion 有新的
        }
        
    }
    
    try? realm.write {
        message.textContent = text
    }
    
    afterCreatedMessage?(message)
    
    
    // 音效
    
    //  执行网络发送网络发送
    
    convertToLeanCloudMessageAndSend(message: message, failureHandler: {
        
        failureHandler?()
        
        }, completion: { _ in
            
            completion?(true)
    })
    
}
