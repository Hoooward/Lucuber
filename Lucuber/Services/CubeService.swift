//
//  CubeService.swift
//  Lucuber
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.

import Foundation
import AVOSCloud
import RealmSwift

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

public func pushToMasterListLeancloud(with masterList: [String], completion: (() -> Void)?, failureHandler: ((Error?) -> Void)?) {
    
    guard let currenUser = AVUser.current() else {
        return
    }
    currenUser.setMasterList(masterList)
    currenUser.saveEventually()
    
}


public func pushDataToLeancloud(with data: Data?, failureHandler: @escaping (Error?) -> Void, completion: @escaping (_ URLString: String) -> Void) {
    
    guard let data = data else {
        printLog("Data = nil")
        failureHandler(nil)
        return
    }
    
    let file = AVFile(data: data)
    file.saveInBackground { success, error in
        if success {
            completion(file.url ?? "")
        }
        if error != nil {
            failureHandler(error)
        }
    }
}




public func pushMessageImage(atPath filePath: String?, orFileData fileData: Data?, metaData: String?, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void, failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void) {
    
    createAndPushMessage(with: MessageMediaType.image, atFilePath: filePath, orFileData: fileData, metaData: metaData, text: "", toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}

public func pushMessageText(_ text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void,failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void) {
    
    createAndPushMessage(with: MessageMediaType.text, atFilePath: nil, orFileData: nil, metaData: nil, text: text, toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}

public func pushMessageAudio(atPath filePath: String?, orFileData fileData: Data?, metaData: String?, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void, failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void ) {
    
    createAndPushMessage(with: MessageMediaType.audio, atFilePath: filePath, orFileData: fileData, metaData: metaData, text: "", toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}


public func createAndPushMessage(with mediaType: MessageMediaType, atFilePath filePath: String?, orFileData fileData: Data?, metaData: String?, text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: (Message) -> Void, failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void) {
    
    // 因为 message_id 必须来自远端，线程无法切换，所以这里暂时没用 realmQueue
    // TOOD: 也许有办法
    guard let realm = try? Realm() else {
        return
    }
    // 创建新的实例
    let message = Message()
    message.localObjectID = Message.randomLocalObjectID()
    
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
    
    
    pushMessageToLeancloud(with: message, atFilePath: filePath, orFileData: fileData, metaData: metaData, toRecipient: recipientID, recipientType: recipientType, failureHandler: {
        error in
        
        failureHandler(error)
        
        let realm = message.realm
        try? realm?.write {
            message.lcObjectID = ""
            message.sendState = MessageSendState.failed.rawValue
        }
        
    }, completion: completion)
    
}

public func pushMessageToLeancloud(with message: Message, atFilePath filePath: String?, orFileData fileData: Data?, metaData: String?, toRecipient recipientID: String, recipientType: String, failureHandler: @escaping (Error?) -> Void, completion: @escaping (Bool) -> Void) {
    
    guard let mediaType = MessageMediaType(rawValue: message.mediaType) else {
        printLog("无效的 mediaType")
        return
    }
    
    // 缓存池保存待发送的 Message
    SendingMessagePool.addMessage(with: message.localObjectID)
    
    let discoverMessage = parseMessageToDisvocerModel(with: message)
    
    let messageSavedCompletion: AVBooleanResultBlock = { success, error in
        if success {
            
            let realm = message.realm
            try? realm?.write {
                message.lcObjectID = discoverMessage.objectId ?? ""
                message.sendState = MessageSendState.successed.rawValue
            }
            completion(success)
        }
        
        if error != nil { failureHandler(error) }
    }
    
    // TODO: - 暂时不处理 Location
    switch mediaType {
        
    case .text:
        discoverMessage.saveInBackground(messageSavedCompletion)
        
    case .audio, .image, .video:
        
        pushDataToLeancloud(with: fileData, failureHandler: { error in
            
            failureHandler(error)
            
        }, completion: { URLString in
            
            discoverMessage.attachmentURLString = URLString
            
            let realm = message.realm
            try? realm? .write {
                message.attachmentURLString = URLString
            }
            
            discoverMessage.saveInBackground(messageSavedCompletion)
            
            
        })
        
    default:
        break
    }
}


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
    
    
    pushToLeancloud(with: [UIImage()], quality: 0.7, completion: {
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





public enum UploadFeedMode {
    case top
    case loadMore
}

//extension AVQuery {
//    
//     enum DefaultKey: String {
//        case updatedTime = "updatedAt"
//        case creatTime = "createdAt"
//    }
//    
//    class func getFormula(mode: UploadFormulaMode) -> AVQuery {
//        
//        switch mode {
//            
//        case .my:
//            
//            let query = AVQuery(className: DiscoverFormula.parseClassName())
//            query.addAscendingOrder("name")
//            query.whereKey("creator", equalTo: AVUser.current()!)
//            
//            query.limit = 1000
//            return query
//            
//        case .library:
//            
//            let query = AVQuery(className: DiscoverFormula.parseClassName())
//            query.whereKey("isLibrary", equalTo: NSNumber(booleanLiteral: true))
//            query.addAscendingOrder("serialNumber")
//            query.limit = 1000
//            return query
//            
//        }
//    }
//    
// 
//    
//}

//func fetchFormulaWithMode(uploadingFormulaMode: UploadFormulaMode,
//                                 category: Category,
//                                 completion: (([Formula]) -> Void)?,
//                                 failureHandler: ((NSError?) -> Void)?) {
//    
//    switch uploadingFormulaMode {
//        
//    case .my :
//        
//        let query = AVQuery.getFormula(mode: uploadingFormulaMode)
//        
//        printLog("-> 开始获取我的公式")
//        query.findObjectsInBackground { formulas, error in
//            
//            if error != nil {
//                
//                failureHandler?(error as? NSError)
//                let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
////                completion?(result)
//                printLog("更新我的公式失败， 使用 Realm 中的我的公式")
// 
//            }
//            
//            if let formulas = formulas as? [Formula] {
//                
//                /// 将 Result 过滤一下, 只使用符合 category 的 formula
//                completion?(formulas.filter{ $0.category == category })
//                
//                /// 删除 Library 中 Formula 对应的 content
//                deleteMyFormulasRContentAtRealm()
//                
//                /// 更新数据库中的 Formula
////                saveUploadFormulasAtRealm(formulas: formulas, mode: uploadingFormulaMode, isCreatNewFormula: false)
//                
//                printLog("-> 成功更新我的公式")
//                
//            }
//        }
//        
//    case .library:
//        
//        // 公式库, 如果Realm中没有数据, 则尝试从网络加载, 否则不需要从网络加载
//        let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
//        
//        if result.isEmpty {
//            
//            
//            failureHandler?(nil)
//            NotificationCenter.default.post(name: Notification.Name.updateFormulasLibraryNotification, object: nil)
//            
//        } else {
//            
////            completion?(result)
//        }
//        
//    }
//
//}


//public func fetchLibraryFormulaFormLeanCloudAndSaveToRealm(completion: (() -> Void)?, failureHandler: ((NSError) -> Void)?) {
//    
//    
//    let query = AVQuery.getFormula(mode: .library)
//    
//    query.findObjectsInBackground { formulas, error in
//        
//        if error != nil {
//            
//            failureHandler?(error as! NSError)
//        }
//        
//        if let formulas = formulas as? [Formula] {
//            
//            if let user = AVUser.current() {
//                
//                user.setNeedUpdateLibrary(need: false)
//                user.saveEventually { successed, error in
//                    
//                    if successed {
//                        printLog("更新 currentUser 的 needUploadLibrary 属性为 false")
//                        
//                    } else {
//                        printLog("更新 currentUser 的 needUploadLibrary 属性失败")
//                    }
//                }
//            }
//            
//            deleteLibraryFormalsRContentAtRealm()
//            
////            saveUploadFormulasAtRealm(formulas: formulas, mode: .library, isCreatNewFormula: false)
//            
//            completion?()
//            
//        }
//    }
//    
//}


//internal func saveNewFormulaToRealmAndPushToLeanCloud(newFormula: Formula,
//                                                      completion: (() -> Void)?,
//                                                      failureHandler: ((NSError) -> Void)? ) {
//    
//    if let user = AVUser.current() {
//        
//        newFormula.creatUser = user
//        newFormula.creatUserID = user.objectId!
//        
//        let acl = AVACL()
//        acl.setPublicReadAccess(true)
//        acl.setWriteAccess(true, for: AVUser.current()!)
//        newFormula.acl = acl
//        
//        
//        newFormula.saveEventually({ (success, error) in
//            if error  == nil {
//                printLog("新公式保存到 LeanCloud 成功")
//            } else {
//                printLog("新公式保存到 LeanCloud 失败")
//            }
//        })
//        
//        saveUploadFormulasAtRealm(formulas: [newFormula], mode: nil, isCreatNewFormula: true)
//        
//        
//        completion?()
//        
//        
//    } else {
//        
//        let error = NSError(domain: "没有登录用户", code: 0, userInfo: nil)
//        failureHandler?(error)
//    }
//    
//    
//    
//}

// MARK: - Login



/// 如果已经登录,就去获取是否需要更新公式的bool值
/// 因为 getObjectInBackgroundWithId 是并发的, 应用程序一启动如果第一个视图是 Formula
/// 的话会第一时间使用 NeedUpdateLibrary 属性进行 Formula 数据加载. 即使在 LeanCloud 中 将
/// 值设为 ture 后的第一次启动, NeedUpdateLibrary 的值还是 false. 第二次启动才会更新 Libray.

public func updateCurrentUserInfo() {
    
    
    if let user = AVUser.current() {
        
        user.fetchInBackground { user, error in
            
            if let user = user as? AVUser {
                
                if user.object(forKey: "needUpdateLibrary") as! Bool {
                    
                    NotificationCenter.default.post(name: Notification.Name.updateFormulasLibraryNotification, object: nil)
                }
            }
            
                
        }
    }
    
}



/// 获取短信验证码
public func fetchMobileVerificationCode(phoneNumber: String,
                                        failureHandler: ((NSError) -> Void)?,
                                        completion: (() -> Void)? ) {
    
    AVOSCloud.requestSmsCode(withPhoneNumber: phoneNumber) { succeeded, error in
        
        if succeeded {
            
            completion?()
            
        } else {
            
            if let error = error as? NSError {
                
                failureHandler?(error)
                
            } else {
                
                let error = NSError(domain: "请求失败", code: 1100, userInfo: nil)
                
                failureHandler?(error)
            }
            
        }
    }
    
}


/// 注册登录
public func signUpOrLogin(withPhonerNumber phoneNumber: String,
                          smsCode: String,
                          failureHandler: ((NSError) -> Void)?,
                          completion: ((AVUser) -> Void)? ) {
    
    AVUser.signUpOrLoginWithMobilePhoneNumber(inBackground: phoneNumber, smsCode: smsCode) { user, error in
        
        
        if error == nil {
            
            printLog("登录成功")
            
            if let user = user {
                
                completion?(user)
                
            }
            
        } else {
            
            if let error = error as? NSError {
                
                failureHandler?(error)
                
            } else {
                
                let error = NSError(domain: "请求失败", code: 1111, userInfo: nil)
                failureHandler?(error)
            }
        }
        
    }
}



/// 上传头像
public func updateAvatar(withImageData imageData: Data,
                                      failureHandler: ((NSError?)->Void)?,
                                      completion: ((String) -> Void)? ) {
    
    let uploadFile = AVFile(data: imageData)
    
    uploadFile.saveInBackground({ succeeded, error in
        
        if succeeded {
            
            completion?(uploadFile.url!)
            
        } else {
            
            failureHandler?(error as NSError?)
        }
        
    })
    
}

/// 上传用户信息
public func updateUserInfo(nickName: String, avatarURL: String,
                                 failureHandler: ((NSError?)->Void)?,
                                 completion: (() -> Void)? ) {
    
    // TODO: - 如果保存失败， 如何处理
    if let currentUser = AVUser.current() {
        
        currentUser.setNickname(nickName)
        currentUser.setAvatorImageURL(avatarURL)
        currentUser.saveInBackground({ successed, error in
            
            if error != nil {
                
                failureHandler?(error as? NSError)
                
            } else {
                completion?()
            }
            
        })
        
    } else {
       
        let error = NSError(domain: "", code: 9999, userInfo: nil)
        
        failureHandler?(error)
        
    }
    
}


// Logout

public func logout() {
    
    AVUser.logOut()
    
//    NotificationCenter.default.post(Notification.Name.changeRootViewControllerNotification)
    
}



// Message


//
//func convertToLeanCloudMessageAndSend(message: Message, failureHandler: (() -> Void)?, completion: ((Bool) -> Void)? ) {
//    
//    let discoverMessage = parseMessageToDisvocerModel(with: message)
//    
//    discoverMessage.saveInBackground {
//        successed, error in
//        
//        if error != nil {
//            // 标记发送失败
//            guard let realm = try? Realm() else {
//                failureHandler?()
//                return
//            }
//            
//            try? realm.write {
//                message.sendStateInt = MessageSendState.failed.rawValue
//            }
//            
//            failureHandler?()
//            
//        }
//        
//        if successed {
//            printLog("发送成功")
//            
//            guard let realm = try? Realm() else {
//                
//                failureHandler?()
//                return
//            }
//            
//            try? realm.write {
//                message.sendStateInt = MessageSendState.successed.rawValue
//                message.messageID = leanCloudMessage.objectId!
//            }
//            
//            completion?(successed)
//        }
//        
//        // 通知 Cell 更改发送状态提示.
//        NotificationCenter.default.post(name: Notification.Name.updateMessageStatesNotification, object: nil)
//        
//    }
//    
//}

// Feed

//internal func fetchFeedWithCategory(category: FeedCategory,
//                                    uploadingFeedMode: UploadFeedMode,
//                                    lastFeedCreatDate: NSDate,
//                                    completion: (([Feed]) -> Void)?,
//                                    failureHandler: ((NSError) -> Void)? ) {
//    
//    let query = AVQuery(className: Feed.parseClassName())
//    query.addDescendingOrder(AVQuery.DefaultKey.updatedTime.rawValue)
//    query.limit = 10
//    
//    switch category {
//        
//    case .All:
//        // Do Noting
//        break
//        
//    case .Topic:
//        // Do Noting
//        break
//        
//    case .Formula:
//        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Formula.rawValue)
//        
//    case .Record:
//        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Record.rawValue)
//        
//    }
//    
//    switch uploadingFeedMode {
//        
//    case .top:
//        // Do Noting
//        break
//        
//    case .loadMore:
//        query.whereKey(AVQuery.DefaultKey.creatTime.rawValue, lessThan: lastFeedCreatDate)
//    }
//    
//    query.findObjectsInBackground { newFeeds, error in
//        
//        if error != nil {
//            
//            failureHandler?(error as! NSError)
//            
//        } else {
//            
//            if let newFeeds = newFeeds as? [Feed] {
//                
//                //                printLog("newFeeds.count = \(newFeeds.count)")
//                completion?(newFeeds)
//            }
//        }
//    }
//    
//}


















