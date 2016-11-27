//
//  ServicePush.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//
import UIKit
import RealmSwift
import AVOSCloud

public func pushToLeancloud(with newFormula: Formula, inRealm realm: Realm, completion: (() -> Void)?, failureHandler: ((Error?) -> Void)?) {
    
    guard
        let currentAVUser = AVUser.current(),
        let currentAVUserObjectID = currentAVUser.objectId else {
            return
    }
    
    let acl = AVACL()
    acl.setPublicReadAccess(true)
    acl.setWriteAccess(true, for: currentAVUser)
    
    var newDiscoverFormula = DiscoverFormula()
    
    if let leancloudObjectID = newFormula.lcObjectID {
        newDiscoverFormula = DiscoverFormula(className: "DiscoverFormula", objectId: leancloudObjectID)
    }
    
    
    pushToLeancloud(with: [newFormula.image], quality: 0.7, completion: {
        imagesURL in
        
        if !imagesURL.isEmpty {
            newDiscoverFormula.imageURL = imagesURL.first!
        }
        
    }, failureHandler: { error in
        printLog("上传图片失败 -> \(error)")
    })
    
    newDiscoverFormula.localObjectID = newFormula.localObjectID
    newDiscoverFormula.name = newFormula.name
    newDiscoverFormula.imageName = newFormula.imageName
    
    
    var discoverContents: [DiscoverContent] = []
    newFormula.contents.forEach { content in
        
        let newDiscoverContent = DiscoverContent()
        
        newDiscoverContent.localObjectID = content.localObjectID
        newDiscoverContent.creator = currentAVUser
        newDiscoverContent.atFormulaLocalObjectID = content.atFomurlaLocalObjectID
        newDiscoverContent.rotation = content.rotation
        newDiscoverContent.text = content.text
        newDiscoverContent.indicatorImageName = content.indicatorImageName
        newDiscoverContent.deletedByCreator = content.deleteByCreator
        
        discoverContents.append(newDiscoverContent)
    }
    
    newDiscoverFormula.contents = discoverContents
    
    newDiscoverFormula.favorate = newFormula.favorate
    newDiscoverFormula.category = newFormula.categoryString
    newDiscoverFormula.type = newFormula.typeString
    newDiscoverFormula.creator = currentAVUser
    newDiscoverFormula.deletedByCreator = newFormula.deletedByCreator
    newDiscoverFormula.rating = newFormula.rating
    newDiscoverFormula.isLibrary = newFormula.isLibrary
    
    
    AVObject.saveAll(inBackground: discoverContents, block: {
        
        success, error in
        
        
        if error != nil {
            
            failureHandler?(error as? NSError)
        }
        
        if success {
            
         
            
            newDiscoverFormula.saveInBackground({ success, error in
                
                if error != nil {
                    
                    failureHandler?(error as? NSError)
                }
                
                if success {
                    
                    printLog("newDiscoverFormula push 成功")
                    
                    try? realm.write {
                        
                        if discoverContents.count == newFormula.contents.count {
                            
                            for index in 0..<discoverContents.count {
                                if let lcObjectID = discoverContents[index].objectId {
                                    newFormula.contents[index].lcObjectID = lcObjectID
                                }
                            }
                        }
                        
                        if let currentUser = userWith(currentAVUserObjectID, inRealm: realm) {
                            newFormula.creator = currentUser
                        }
                        newFormula.imageURL = newDiscoverFormula.imageURL
                        newFormula.lcObjectID = newDiscoverFormula.objectId
                        appendRCategory(with: newFormula, uploadMode: .my, inRealm: realm)
                    }
                    
                    
                    completion?()
                }
                
                
            })
        }
        
    })
    
    
    
}

public func pushToDataLeancloud(with images: [UIImage], quality: CGFloat, completion: (([String]) -> Void)?, failureHandler: ((NSError?) -> Void)?) {
    
    guard !images.isEmpty else {
        return
    }
    
    var imagesURL = [String]()
    images.forEach { image in
        
        if let data = UIImageJPEGRepresentation(image, quality) {
            let uploadFile = AVFile(data: data)
            
            var error: NSError?
            if uploadFile.save(&error) {
                if let url = uploadFile.url {
                    imagesURL.append(url)
                }
            } else {
                failureHandler?(error)
            }
        }
    }
    
    completion?(imagesURL)
}

public func pushToMasterListLeancloud(with masterList: [String], completion: (() -> Void)?, failureHandler: ((Error?) -> Void)?) {
    
    guard let currenUser = AVUser.current() else {
        return
    }
    currenUser.setMasterList(masterList)
    currenUser.saveEventually()
    
}




public func pushMessageToLeancloud(with message: Message, atFilePath filePath: String, orFileData fileData: Data?, metaData: String?, toRecipient recipientID: String, recipientType: String, failureHandler: (Error?) -> Void, completion: (Bool) -> Void) {

    guard let mediaType = MessageMediaType(rawValue: message.mediaType) else {
        printLog("无效的 mediaType")
        return
    }
    
    // 缓存池保存待发送的 Message
    SendingMessagePool.addMessage(with: message.localObjectID)
    
    let discoverMessage = parseMessageToDisvocerModel(with: message)
    
    
    let messageSaveInbackground: AVBooleanResultBlock = { success, error in
     
        if success {
            DispatchQueue.main.async {
                let realm = message.realm
                try? realm?.write {
                    message.lcObjectID = discoverMessage.objectId ?? ""
                    message.sendState = MessageSendState.successed.rawValue
                }
            }
            
        }
        
        if error != nil {
            
            DispatchQueue.main.async {
                let realm = message.realm
                try? realm?.write {
                    message.lcObjectID = ""
                    message.sendState = MessageSendState.failed.rawValue
                }
            }
        }
    }
    
    // TODO: - 暂时不处理 Location
    switch mediaType {
        
    case .text:
        discoverMessage.saveInBackground(messageSaveInbackground)
        
    default:
        break
    }
}

public func pushMessageImage(atPath filePath: String?, orFileData fileData: Data?, metaData: String?, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void, failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void) {
    
    createAndPushMessage(with: MessageMediaType.image, atFilePath: filePath, orFileData: fileData, metaData: metaData, text: "", toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}

public func pushMessageText(_ text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void,failureHandler: @escaping (Error?) -> Void, g completion: @escaping (Bool) -> Void) {
    
    
}


public func createAndPushMessage(with mediaType: MessageMediaType, atFilePath filePath: String?, orFileData fileData: Data?, metaData: String?, text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: ((Message) -> Void), failureHandler: ((Error) -> Void)?, completion: (Bool) -> Void) {
    
    // 因为 message_id 必须来自远端，线程无法切换，所以这里暂时没用 realmQueue 
    // TOOD: 也许有办法
    guard let realm = try? Realm() else {
        return
    }
    
    // 创建新的实例
    let message = Message()
    
    // 保证创建的新消息时间为最最最最新
    if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
        
        if message.createdUnixTime < latestMessage.createdUnixTime {
            message.createdUnixTime = latestMessage.createdUnixTime + 0.0005
        }
    }
    
    message.mediaType = mediaType.rawValue
    message.downloadState = MessageDownloadState.downloaded.rawValue
//    message.sendStateInt = MessageSendState.notSend.rawValue
    message.readed = true
    
    
    // 添加到 Realm
    try? realm.write {
        realm.add(message)
    }
    
    
    if let me = currentUser(in: realm) {
        try? realm.write {
            message.creator = me
        }
    }
    
    
    // 如果没有 Conversation ，创建
    var conversation: Conversation? = nil
    
    try? realm.write {
        
        if recipientType == "user" {
            
            if let withFriend = userWith(recipientID, inRealm: realm) {
                conversation = withFriend.conversation
            }
            
        } else {
            
            if let withGroup = groupWith(recipientID, inRealm: realm) {
                conversation = withGroup.conversation
            }
        }
        
        if conversation == nil {
            
            let newConversation = Conversation()
            
            if recipientType == "user" {
                
                newConversation.type = ConversationType.oneToOne.rawValue
                
                if let withFriend = userWith(recipientID, inRealm: realm) {
                    newConversation.withFriend = withFriend
                }
                
            } else {
                
                newConversation.type = ConversationType.group.rawValue
                
                if let withGroup = groupWith(recipientID, inRealm: realm) {
                    newConversation.withGroup = withGroup
                }
            }
            
            conversation = newConversation
        }
        
        if let conversation = conversation {
            
            message.conversation = conversation
            
            tryCreatDateSectionMessage(with: conversation, beforeMessage: message, inRealm: realm) {
                sectionDateMessage in
                realm.add(sectionDateMessage)
            }
            
            conversation.updateUnixTime = Date().timeIntervalSince1970
            
            DispatchQueue.main.async {
                
            }
            
            message.recipientID = recipientID
            message.recipientType = recipientType
            
           
            // 发送通知, Convertaion 有新的
        }
        
    }
    
    // TODO: - 处理 Location
    
    try? realm.write {
        message.textContent = text
    }
    
    afterCreatedMessage(message)
    
    
    // TODO: - 音效处理
    
    
    // push 到远端
    convertToLeanCloudMessageAndSend(message: message, failureHandler: {
        
        failureHandler?()
        
    }, completion: { _ in
        
        completion?(true)
    })

    
    
}







