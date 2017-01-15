//
//  CubeService.swift
//  Lucuber
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.

import Foundation
import AVOSCloud
import RealmSwift
import PKHUD
import CoreLocation
import Alamofire
import Kanna
import Kingfisher


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
    
    guard let currentUser = AVUser.current() else {
        return
    }
    currentUser.setMasterList(masterList)
    currentUser.saveEventually()
}


public func pushMyNicknameToLeancloud(with nickname: String, failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    guard let me = AVUser.current() else {
        failureHandler(Reason.other(nil), "没有登录")
        return
    }
    me.setNickname(nickname)
    me.saveInBackground { success, error in
        if error != nil {
            failureHandler(Reason.network(error), "设置用户昵称失败")
        }
        
        if success {
            completion?()
        }
    }
}

public func pushMyIntroductionToLeancloud(with intro: String, failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    guard let me = AVUser.current() else {
        failureHandler(Reason.other(nil), "没有登录")
        return
    }
    me.setIntroduction(intro)
    me.saveInBackground { success, error in
        if error != nil {
            failureHandler(Reason.network(error), "上传用户自我介绍失败")
        }
        
        if success {
            completion?()
        }
    }
}

public func pushMyAvatarURLStringToLeancloud(with urlString: String, failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    guard let me = AVUser.current() else {
        failureHandler(Reason.other(nil), "没有登录")
        return
    }
    
    me.setAvatorImageURL(urlString)
    me.saveInBackground { success, error in
        if error != nil {
            failureHandler(Reason.network(error), "上传头像链接失败")
        }
        
        if success {
            completion?()
        }
    }
}

public func pushMyCubeCategoryMasterListToLeancloud(with list: [String], failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    guard let me = AVUser.current() else {
        failureHandler(Reason.other(nil), "没有登录")
        return
    }
    me.setCubeCategoryMasterList(list)
    me.saveInBackground { success, error in
        if error != nil {
            failureHandler(Reason.network(error), "上传擅长魔方失败")
        }
        
        if success {
            completion?()
        }
    }
}

public func pushMySubscribeListToLeancloud(failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    guard let realm = try? Realm() else {
        return
    }
    
    guard let me = AVUser.current() else {
        failureHandler(Reason.other(nil), "没有登录")
        return
    }
    
    if let subscribeList = mySubscribeGroupsIDInRealm(realm: realm) {
        me.setSubscribeList(subscribeList)
    }
    
    me.saveInBackground { success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "上传订阅列表失败")
        }
        
        if success {
            completion?()
        }
    }
    
}

public func pushMyInfoToLeancloud(completion: (() -> Void)?, failureHandler: @escaping FailureHandler) {
    
    guard let me = AVUser.current(), let realm = try? Realm(), let meRuser = currentUser(in: realm) else {
        fatalError()
    }
    
    me.setNickname(meRuser.nickname)
    me.setMasterList(meRuser.masterList.map { $0.formulaID })
    me.setIntroduction(meRuser.introduction ?? "")
    me.setLocalObjcetID(meRuser.localObjectID)
    me.setAvatorImageURL(meRuser.avatorImageURL ?? "")
    me.setCubeCategoryMasterList(meRuser.cubeCategoryMasterList.map { $0.categoryString })
    
    if let subscribeList = mySubscribeGroupsIDInRealm(realm: realm) {
        me.setSubscribeList(subscribeList)
    }
    
    me.saveInBackground { success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "上传用户信息失败")
        }
        
        if success {
            completion?()
        }
    }
    
}
public func pushFeedbackToLeancloud(with feedback: DiscoverFeedback, completion: (() -> Void)?, failureHandler: @escaping FailureHandler) {
    
    guard let me = AVUser.current() else {
       failureHandler(Reason.other(nil), "没有封路")
        return
    }
    
    feedback.creator = me
    feedback.saveInBackground { success, error in
        
        if error != nil {
           failureHandler(Reason.network(error), "发送反馈信息失败")
        }
        
        if success {
            completion?()
        }
    }
    
}


public func pushDataToLeancloud(with data: Data?, failureHandler: @escaping FailureHandler, completion: @escaping (_ URLString: String?) -> Void) {
    
    guard let data = data else {
        failureHandler(Reason.noData, "传入的 Data 为空")
        return
    }
    
    let file = AVFile(data: data)
    
    file.saveInBackground { success, error in
        if success {
            completion(file.url)
        }
        if error != nil {
            failureHandler(Reason.network(error), "网络请求失败")
        }
    }
}

public func pushDatasToLeancloud(with datas: [Data]?, failureHandler: @escaping FailureHandler, completion: @escaping (_ URLsString: [String]?) -> Void) {
    
    guard let datas = datas else {
        failureHandler(Reason.noData, "传入的 Data 为空")
        return
    }
    
    let files = datas.map { AVFile(data: $0) }
    
    
    var URLs: [String] = []
    
    let uploadFileGroup = DispatchGroup()
    
    for file in files {
        
        uploadFileGroup.enter()
        
        file.saveInBackground { success, error in
           
            if error != nil {
                
//                failureHandler(Reason.network(error), "上传图片失败")
                uploadFileGroup.leave()
            }
            
            if success {
                
                if let url = file.url {
                    URLs.append(url)
                }
                
                uploadFileGroup.leave()
            }
        }
    }
    
    uploadFileGroup.notify(queue: DispatchQueue.main, execute: {
        
        if URLs.count != files.count {
            failureHandler(Reason.network(nil), "有部分图片上传失败")
        } else {
            completion(URLs)
        }
    })
    
}


public func resendMessage(message: Message, failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void) {
    
    var recipientID: String?
    var recipientType: String?
    
    if let conversation = message.conversation {
        if conversation.type == ConversationType.oneToOne.rawValue {
            recipientID = conversation.withFriend?.lcObjcetID
            recipientType = ConversationType.oneToOne.nameForServer
            
        } else if conversation.type == ConversationType.group.rawValue {
            recipientID = conversation.withGroup?.groupID
            recipientType = ConversationType.group.nameForServer
        }
    }
    
    if let recipientID = recipientID,
        let recipientType = recipientType,
        let messageMediaType = MessageMediaType(rawValue: message.mediaType) {
        
        // 发送之前先修改发送状态
        DispatchQueue.main.async {
            let realm = message.realm
            try? realm?.write {
                message.sendState = MessageSendState.notSend.rawValue
            }
            
            NotificationCenter.default.post(name: Notification.Name.updateMessageStatesNotification, object: nil)
        }
        
        let resendFailureHandler: FailureHandler = { reason, errorMessage in
            
            failureHandler(reason, errorMessage)
            
            DispatchQueue.main.async {

                let realm = message.realm
                
                let _ = try? realm?.write {
                    message.sendState = MessageSendState.failed.rawValue
                }
                
               NotificationCenter.default.post(name: Notification.Name.updateMessageStatesNotification, object: nil)
            }
        }
        
        switch messageMediaType {
        case .text:
            
            pushMessageToLeancloud(with: message, atFilePath: nil, orFileData: nil, metaData: nil, toRecipient: recipientID, recipientType: recipientType, failureHandler: resendFailureHandler, completion: completion)
            
        case .image:
            
            let filePath = FileManager.cubeMessageImageURL(with: message.localThumbnailName)?.path ?? ""
            var fileData = Data()
            if let image = UIImage(contentsOfFile: filePath) {
               fileData = UIImageJPEGRepresentation(image, 0.95)!
            }
            
            pushMessageToLeancloud(with: message, atFilePath: filePath, orFileData: fileData, metaData: nil, toRecipient: recipientID, recipientType: recipientType, failureHandler: resendFailureHandler, completion: completion)
        default:
            break
        }
        
    
    }
}


public func pushMessageImage(atPath filePath: String?, orFileData fileData: Data?, metaData: Data?, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void, failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void) {
    
    createAndPushMessage(with: MessageMediaType.image, atFilePath: filePath, orFileData: fileData, metaData: metaData, text: "", toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}

public func pushMessageText(_ text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void,failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void) {
    
    createAndPushMessage(with: MessageMediaType.text, atFilePath: nil, orFileData: nil, metaData: nil, text: text, toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}

public func pushMessageAudio(atPath filePath: String?, orFileData fileData: Data?, metaData: Data?, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: @escaping (Message) -> Void, failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void ) {
    
    createAndPushMessage(with: MessageMediaType.audio, atFilePath: filePath, orFileData: fileData, metaData: metaData, text: "", toRecipient: recipientID, recipientType: recipientType, afterCreatedMessage: afterCreatedMessage, failureHandler: failureHandler, completion: completion)
}


public func createAndPushMessage(with mediaType: MessageMediaType, atFilePath filePath: String?, orFileData fileData: Data?, metaData: Data?, text: String, toRecipient recipientID: String, recipientType: String, afterCreatedMessage: (Message) -> Void, failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void) {
    
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
    
    // 将 media 的图片信息保存
    if let metaData = metaData {

        let newMetaData = MediaMetaData()
        newMetaData.data = metaData

        try? realm.write {
            realm.add(newMetaData)
            message.mediaMetaData = newMetaData
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
        reason, errorMessage in
        
        failureHandler(reason, errorMessage)
        
        let realm = message.realm
        try? realm?.write {
            message.lcObjectID = ""
            message.sendState = MessageSendState.failed.rawValue
        }
        
    }, completion: completion)
    
}

public func pushMessageToLeancloud(with message: Message, atFilePath filePath: String?, orFileData fileData: Data?, metaData: Data?, toRecipient recipientID: String, recipientType: String, failureHandler: @escaping FailureHandler, completion: @escaping (Bool) -> Void) {
    
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


                // 重新设置服务器端的创建时间会导致与push 之前创建的 SectionDate Cell 时间

//                if let createdAt = discoverMessage.createdAt {
//                    message.createdUnixTime = createdAt.timeIntervalSince1970
//
//                }
            }
            NotificationCenter.default.post(name: Notification.Name.updateMessageStatesNotification, object: nil)
            
            pushNewMessageNotificationToAPNs(with: message)

            completion(success)
        }
        
        if error != nil { failureHandler(Reason.network(error), "网络请求失败") }
    }
    
    // TODO: - 暂时不处理 Location
    switch mediaType {
        
    case .text:
        discoverMessage.saveInBackground(messageSavedCompletion)
        
    case .audio, .image, .video:
        
        pushDataToLeancloud(with: fileData, failureHandler: { reason, errorMessage in
            
            failureHandler(reason, errorMessage)
            
        }, completion: { URLString in
            
            if let URLString = URLString {
                
                discoverMessage.attachmentURLString = URLString
                let realm = message.realm
                try? realm? .write {
                    message.attachmentURLString = URLString
                }
                discoverMessage.saveInBackground(messageSavedCompletion)
            }
        })
        
    default:
        break
    }
}


public func pushNewMessageNotificationToAPNs(with message: Message) {

    let dict: [String: Any] = [
            "alert": "你订阅的话题有新的消息",
            "type": AppDelegate.RemoteNotificationType.message.rawValue,
            "messageID": message.lcObjectID,
    ]

    AVPush.setProductionMode(false)
    let push = AVPush()
    push.setChannel(message.recipientID)

    push.setData(dict)
    push.sendInBackground()
}

public func pushFormulaToLeancloud(with newFormula: Formula, failureHandler: @escaping FailureHandler , completion: ((DiscoverFormula) -> Void)?) {
    
    guard let newDiscoverFormula = parseFormulaToDisvocerModel(with: newFormula) else  {
        failureHandler(Reason.other(nil), "模型转换失败")
        return
    }
    
    let saveAllObject: AVBooleanResultBlock = { success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "推送 Formula 的 contents 失败.")
        }
        
        if success {
            
            newDiscoverFormula.saveInBackground({ success, error in
                
                if error != nil {
                    failureHandler(Reason.network(error), "推送 Formula 失败")
                }
                
                if success {
                    
                    guard let realm = newFormula.realm else {
                        failureHandler(Reason.other(nil), "上传成功, 但以无法找到 newFormula 对应的 realm")
                        return }
                    
                    try? realm.write {
                        
                        if newDiscoverFormula.contents.count == newFormula.contents.count {
                            
                            for index in 0..<newDiscoverFormula.contents.count {
                                if let lcObjectID = newDiscoverFormula.contents[index].objectId {
                                    newFormula.contents[index].lcObjectID = lcObjectID
                                }
                            }
                        }
                        
                        newFormula.isPushed = true
                        newFormula.lcObjectID = newDiscoverFormula.objectId!
                        createOrUpdateRCategory(with: newFormula, uploadMode: .my, inRealm: realm)
                    }
                    
                    completion?(newDiscoverFormula)
                }
                
            })
        }
    }
    
    var newImageData: Data?
    var newResizeImage: UIImage?
    
    if let newImage = newFormula.pickedLocalImage {
        
        newResizeImage = newImage.resizeTo(targetSize: CGSize(width: 600, height: 600), quality: CGInterpolationQuality.medium)!
        newImageData = UIImagePNGRepresentation(newResizeImage!)
    }
    
    if let localImageURL = FileManager.cubeFormulaLocalImageURL(with: newFormula.localObjectID) {
        
        if let image = UIImage(contentsOfFile: localImageURL.path) {
            
            newResizeImage = image
            newImageData = UIImagePNGRepresentation(newResizeImage!)
        }
        
    }
    
    // 有新图片, 先上传图片
    if let newImageData = newImageData {
        
        pushDataToLeancloud(with: newImageData, failureHandler: {
            reason, errorMessage in
            
            failureHandler(reason, errorMessage)
            
        }, completion: { imageURLString in
            
            if let imageURLString = imageURLString {
                
                printLog(imageURLString)
                newDiscoverFormula.imageURL = imageURLString
                
                let realm = newFormula.realm
                try? realm?.write {
                    newFormula.imageURL = imageURLString
                }
                
                if let newResizeImage = newResizeImage {
//
                    let originalKey = CubeImageCache.attachmentOriginKeyWithURLString(URLString: imageURLString)
                    let originalData = UIImageJPEGRepresentation(newResizeImage, 1.0)
                    
                    ImageCache.default.store(newResizeImage, original: originalData, forKey: originalKey, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: true, completionHandler: nil)
                    
                    FileManager.removeFormulaLocalImageData(with: newFormula.localObjectID)
                }
                
            } else {
               
                printLog("URLString 为空")
            }
            
            
            AVObject.saveAll(inBackground: newDiscoverFormula.contents, block: saveAllObject)
            
        })
        
    // 没有新图片, 一定有老图片
    } else {
        
        newDiscoverFormula.imageURL = newFormula.imageURL
        AVObject.saveAll(inBackground: newDiscoverFormula.contents, block: saveAllObject)
        
    }
    
}

public func pushCurrentUserUpdateInformation() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    func pushDeletedByCreatorFormulaInfomation(nextMission: @escaping () -> Void) {
        // Leancloud 断标记删除的内容
        if let currentUser = currentUser(in: realm) {
            
            let deletedFormula = deleteByCreatorFormula(with: currentUser, inRealm: realm)
            var discoverFormulas = [DiscoverFormula]()
            
            // 如果不为空, 转换模型
            if !deletedFormula.isEmpty {
                
                for formula in deletedFormula {
                    
                    if formula.lcObjectID == "" {
                        
                        try? realm.write {
                            realm.delete(formula)
                        }
                        
                    } else {
                        
                        let discoverFormula = DiscoverFormula(className: "DiscoverFormula", objectId: formula.lcObjectID)
                        
                        discoverFormula.setValue(true, forKey: "deletedByCreator")
                        
                        discoverFormulas.append(discoverFormula)
                    }
                }
                
            // 如果为空执行下一个任务
            } else {
                nextMission()
            }
            
            if !discoverFormulas.isEmpty {
                
                AVObject.saveAll(inBackground: discoverFormulas, block: { success, error in
                    
                    
                    if error != nil {
                        defaultFailureHandler(Reason.network(error), "删除公式推送失败")
                        nextMission()
                    }
                    
                    if success {
                        printLog("删除公式推送成功, 共删除 \(discoverFormulas.count) 个公式")
                        try? realm.write {
                            realm.delete(deletedFormula)
                        }
                        nextMission()
                    }
                    
                })
            }
        }
    }
    
    
    func pushDeletedByCreatorContentInformation() {
        
        if let currentUser = currentUser(in: realm) {
            let deletedContents = deleteByCreatorRContent(with: currentUser, inRealm: realm)
            
            var discoverContents = [DiscoverContent]()
            if !deletedContents.isEmpty {
                
                for content in deletedContents {
                    
                    if content.lcObjectID == "" {
                        try? realm.write {
                            realm.delete(content)
                        }
                        
                    } else {
                        
                        let discoverContent = DiscoverContent(className: "DiscoverContent", objectId: content.lcObjectID)
                        discoverContent.setValue(true, forKey: "deletedByCreator")
                        discoverContents.append(discoverContent)
                    }
                }
            } else {
                
                HUD.flash(.label("上传新公式成功"), delay: 2.0)
                NotificationCenter.default.post(name: NSNotification.Name.afterUploadUserInformationNotification, object: nil)
            }
            
            if !discoverContents.isEmpty {
                
                AVObject.saveAll(inBackground: discoverContents, block: { success, error in
                    
                    if error != nil {
                        defaultFailureHandler(Reason.network(error), "删除公式Content推送失败")
                        HUD.flash(.label("上传新公式失败"), delay: 2.0)
                    }
                    
                    if success {
                        
                        printLog("删除公式Content信息推送成功, 共删除 \(discoverContents.count) 个Content")
                        try? realm.write {
                            realm.delete(deletedContents)
                        }
                        HUD.flash(.label("上传新公式成功"), delay: 2.0)
                        NotificationCenter.default.post(name: NSNotification.Name.afterUploadUserInformationNotification, object: nil)
                    }
                })
            }
        }
        
    }
    HUD.show(.label("正在上传新公式数据"))
    
    if let currentUser = currentUser(in: realm) {
        // 更新用户修改的公式
       
        pushMyInfoToLeancloud(completion: {
            printLog("上传用户信息成功")
        }, failureHandler: { reason, errorMessage in
            defaultFailureHandler(reason, errorMessage)
            
        })
        
        let unPusheFormula = unPushedFormula(with: currentUser, inRealm: realm)
        
        if !unPusheFormula.isEmpty {
            
            for formula in unPusheFormula {
                
                pushFormulaToLeancloud(with: formula, failureHandler: {
                    reason, errorMessage in
                    
                    defaultFailureHandler(reason, errorMessage)
                    HUD.flash(.label("上传新公式失败"), delay: 2.0)
                    
                }, completion: {
                    _ in
                    
                    pushDeletedByCreatorFormulaInfomation {
                        pushDeletedByCreatorContentInformation()
                    }
                    
//                    NotificationCenter.default.post(name: NSNotification.Name.afterUploadUserInformationNotification, object: nil)
//                    printLog("更新公式信息到Leancloud成功")
                })
            }
        } else {
            
            pushDeletedByCreatorFormulaInfomation {
                pushDeletedByCreatorContentInformation()
            }
        }
    }

}



public enum UploadFeedMode {
    case top
    case loadMore
}

public func openGraphWithURL(_ URL: URL, failureHandler: FailureHandler?, completion: @escaping (OpenGraph) -> Void) {
    
    Alamofire.request(URL.absoluteString).responseString { (response) in
        
        let error = response.result.error
        
        guard error == nil else {
            
            failureHandler?(Reason.network(error), "网络错误")
            
            return
        }
        
        if let HTMLString = response.result.value {
            
            var finalURL = URL
            if let _finalURL = response.response?.url {
                finalURL = _finalURL
            }
            
        
            if let openGraph = OpenGraph.fromHTMLString(HTMLString, forURL: finalURL) {
                completion(openGraph)
            }
            
            return
        }
        
    }
    
}

public typealias JSONDictionary = [String: Any]

public func createFeedWithCategory(_ category: FeedCategory, message: String, attachments: JSONDictionary?, withFormula formula: DiscoverFormula?, coordinate: CLLocationCoordinate2D? , allowComment: Bool, failureHandler: FailureHandler?, completion: ((DiscoverFeed) -> Void)?) {
    
    guard let currentUser = AVUser.current() else {
        defaultFailureHandler(Reason.noSuccess, "没有登录")
        return
    }
    
    let newDiscoverFeed = DiscoverFeed()
    
    newDiscoverFeed.localObjectID = Feed.randomLocalObjectID()
    newDiscoverFeed.categoryString = category.rawValue
    newDiscoverFeed.messagesCount = 0
    newDiscoverFeed.body = message
    newDiscoverFeed.creator = currentUser
    newDiscoverFeed.allowComment = allowComment
    newDiscoverFeed.distance = 0
    newDiscoverFeed.highlightedKeywordsBody = ""
    
    if let coordinate = coordinate {
        newDiscoverFeed.latitude = coordinate.latitude
        newDiscoverFeed.longitude = coordinate.longitude
    }
    
    switch category {
    case .formula:
        guard let formula = formula else {
            break
        }
        newDiscoverFeed.withFormula = formula
        
    case .url:
        guard let attachments = attachments as? [String: String] else {
            break
        }
        newDiscoverFeed.attachmentsInfo = attachments as NSDictionary
        
    case .image:
        guard let attachments = attachments as? [String: [String]] else {
            break
        }
        newDiscoverFeed.attachmentsInfo = attachments as NSDictionary

    default:
        break
    }

    newDiscoverFeed.saveInBackground {
        success, error in

        if error != nil {
            failureHandler?(Reason.network(error), "发送 Feed 失败")
        }

        if success {
            completion?(newDiscoverFeed)
        }
    }

}


public func pushCubeCategory() {
    
    let categorys = [
        "二阶",
        "三阶",
        "四阶",
        "五阶",
        "六阶",
        "七阶",
        "八阶",
        "九阶",
        "十一阶",
        
        "镜面魔方",
        "金字塔魔方",
        "魔粽",
        "魔球",
        "五魔方",
        "菊花五魔方",
        "亚历山大之星",
        "直升机魔方",
        "移棱魔方",
        "空心魔方",
        "唯棱魔方",
        "斜转魔方",
        "钻石魔方",
        "齿轮魔方",
        "Square One",
        "Super Square One",
        "Square Two",
        "魔粽齿轮",
        "花瓣转角魔方",
        "六角异形魔方",
        "路障魔方",
        "八轴八面魔方",
        "百慕大三阶",
        "空心唯棱魔方",
        "唯角魔方",
        "魔中魔",
        "魔刃",
        "鲁比克360",
        "魔板",
        "大师魔板",
        "魔表",
        "扭计蛇",
        "113连体",
        "Tuttminx",
        "Futtminx",
        
        
        
        "3x3x1",
        "3x3x2",
        "3x3x4",
        "3x3x5",
        "3x3x6",
        "3x3x7",
        "3x3x8",
        "3x3x9",
        "2x2x1",
        "2x2x3",
        "2x2x4",
        "4x4x5",
        "4x4x6",
        "5x5x4",
        "2x3x4",
        "3x4x5",
        ]
    
    var cubeCategorys: [DiscoverCubeCategory] = []
    
    categorys.forEach { string in
        
        let newCategory = DiscoverCubeCategory()
        newCategory.categoryString = string
        cubeCategorys.append(newCategory)
    }
    
    AVObject.saveAll(cubeCategorys)
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

// MARK: - Register

public func fetchValidateMobile(mobile: String, checkType: LoginType, failureHandler: @escaping FailureHandler, completion: @escaping (() -> Void)) {
    
    let query = AVQuery(className: "_User")
    query.whereKey("mobilePhoneNumber", equalTo: mobile)
    
    query.findObjectsInBackground { users, error in
        
        switch checkType {
            
        case .register:
            
            if let resultUsers = users {
                
                if let user = resultUsers.first as? AVUser, let _ = user.nickname() {
                    
                    failureHandler(Reason.noSuccess, "您输入的手机号码已经注册, 请返回登录")
                    
                } else { completion() }
                
            } else { completion() }
            
            if error != nil {
                
                failureHandler(Reason.network(error), "网络请求失败, 请稍后再试")
            }
            
            
        case .login:
            
            if let resultUsers = users {
               
                if let user = resultUsers.first as? AVUser, let _ = user.nickname() {
                    completion()
                    
                } else {
                   
                    failureHandler(Reason.noSuccess, "您输入的手机号码尚未注册, 请返回注册")
                }
            }
            if error != nil {
                
                failureHandler(Reason.network(error), "网络请求失败, 请稍后再试")
            }
        }
    }
}


/// 获取短信验证码
public func fetchMobileVerificationCode(phoneNumber: String, failureHandler: @escaping FailureHandler, completion: (() -> Void)? ) {
    
    AVOSCloud.requestSmsCode(withPhoneNumber: phoneNumber) { success, error in
        if success { completion?() }
        if error != nil { failureHandler(Reason.other(error as? NSError), nil) }
    }
}


/// 注册登录
public func signUpOrLogin(with phoneNumber: String, smsCode: String,  failureHandler: @escaping FailureHandler, completion: ((AVUser) -> Void)? ) {
    
    AVUser.signUpOrLoginWithMobilePhoneNumber(inBackground: phoneNumber, smsCode: smsCode) { user, error in
        
        if let user = user { completion?(user) }
        if error != nil { failureHandler(Reason.other(error as? NSError), nil) }
    }
}


/// Logout
public func logout() {
    AVUser.logOut()
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




















