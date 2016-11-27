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

public func pushToLeancloud(with images: [UIImage], quality: CGFloat, completion: (([String]) -> Void)?, failureHandler: ((NSError?) -> Void)?) {
    
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

public func pushToLeancloud(with masterList: [String], completion: (() -> Void)?, failureHandler: ((Error?) -> Void)?) {
    
    guard let currenUser = AVUser.current() else {
        return
    }
    currenUser.setMasterList(masterList)
    currenUser.saveEventually()
    
}



func createAndPushMessage(with mediaType: MessageMediaType, text: String, toRecipient: String, recipientType: String, afterCreatedMessage: ((Message) -> Void)?, failureHandler: (() -> Void)?, completion: ((Bool) -> Void)?) {
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







