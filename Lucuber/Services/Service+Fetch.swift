//
//  ServiceSync.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import PKHUD


// MARK: - Message


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

func fetchMessage(withRecipientID recipientID: String?, messageAge: MessageAge, lastMessage: Message?, firstMessage: Message?, failureHandler: @escaping FailureHandler, completion: ((_ messagesID: [String]) -> Void)?) {
    
    guard let recipientID = recipientID else {
        failureHandler(Reason.network(nil), "recipientID 无效")
        return
    }
    let query = AVQuery(className: "DiscoverMessage")
    query.whereKey("recipientID", equalTo: recipientID)
    
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
    
    query.order(byAscending: "createdAt")
    query.limit = 20
    // 此次请求需要将完整的 creatorUser 信息获取到.
    query.includeKey("creator")
    query.findObjectsInBackground {
        result, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "网路请求 Messages 数据失败")
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
                
                convertDiscoverMessageToRealmMessage(discoverMessage: $0, messageAge: messageAge, inRealm: realm) {
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

func convertDiscoverMessageToRealmMessage(discoverMessage: DiscoverMessage, messageAge: MessageAge, inRealm realm: Realm, completion: ((_ newSectionMessageIDs: [String]) -> Void)?) {


    if  !discoverMessage.localObjectID.isEmpty {

        let messageID = discoverMessage.localObjectID
        // 尝试从数据库中取得与 ID 对应的 Message
        var message = messageWith(messageID, inRealm: realm)

        // 判断 Message 是否被作者删除
        let deleted = discoverMessage.deletedByCreator

        if deleted {
           if
            let discoverMessageCreatorUserID = discoverMessage.creator.objectId,
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
            newMessage.lcObjectID = discoverMessage.objectId!
            newMessage.localObjectID = discoverMessage.localObjectID
            newMessage.textContent = discoverMessage.textContent
            newMessage.mediaType = discoverMessage.mediaType
            
            let metaDataInfo = discoverMessage.metaDataInfo
            
            if !metaDataInfo.isEmpty {
                
                if let data = Data.init(base64Encoded: metaDataInfo) {
                    
                    let newMetaData = MediaMetaData()
                    newMetaData.data = data
                    realm.add(newMetaData)
                    
                    newMessage.mediaMetaData = newMetaData
                }
            }
            
            // 全部标记为已读
            newMessage.sendState = MessageSendState.read.rawValue

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
            if let messageCreatorUserID = discoverMessage.creator.objectId {

                var sender = userWith(messageCreatorUserID, inRealm: realm)

                if sender == nil {

                    let newUser = getOrCreatRUserWith(discoverMessage.creator, inRealm: realm)

//                    printLog(discoverMessage.creatarUser)
                    // TODO: 如果需要标记 newUser 为陌生人

                    sender = newUser
                }

                if let sender = sender {

                    message.creator = sender
                    message.recipientID = discoverMessage.recipientID
                    message.recipientType = discoverMessage.recipientType
                    // 判断 message 来自 group 还是 user
                    var senderFromGroup: Group? = nil

                    if discoverMessage.recipientType == "group" {

                        senderFromGroup = groupWith(discoverMessage.recipientID, inRealm: realm)

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
                        if let meUserID = AVUser.current()?.objectId, meUserID != sender.lcObjcetID {
                            conversation = sender.conversation
                            conversationWithUser = sender

                        } else {

                            if discoverMessage.recipientID.isEmpty {
                                realm.delete(message)
                                return
                            }

                            if let user = userWith(discoverMessage.recipientID, inRealm: realm) {
                                conversation = user.conversation
                                conversationWithUser = user

                            } else {

                                let newUser = RUser()

                                newUser.lcObjcetID = discoverMessage.recipientID

                                realm.add(newUser)
                                
                                fetchUser(with: discoverMessage.recipientID, failureHandeler: {
                                    reason, errorMessage in
                                        defaultFailureHandler(reason, errorMessage)
                                }, completion: {  user in
                                    
                                    guard let realm = try? Realm() else { return }
                                        try? realm.write {
                                            _ = getOrCreatRUserWith(user, inRealm: realm)
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

                            tryCreatDateSectionMessage(with: conversation, beforeMessage: message, inRealm: realm, completion: {
                                sectionDateMesage in

                                realm.add(sectionDateMesage)

                                sectionDateMessageID = sectionDateMesage.localObjectID

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


// MARK: - User

public func fetchUser(with userObjectID: String, failureHandeler: @escaping FailureHandler, completion: @escaping (AVUser) -> Void ) {
    
    let query = AVQuery(className: "_User")
    query.whereKey("objectId", equalTo: userObjectID)
    
    query.findObjectsInBackground {
        users, error in
        if error != nil {
            failureHandeler(Reason.network(error), "获取用户失败")
        }
        if let user = users?.first as? AVUser {
            completion(user)
        }
    }
    
}

public enum UploadFormulaMode: String {
    case my = "My"
    case library = "Library"
}


public func updateLibraryDate(failureHandeler: @escaping FailureHandler, completion: (() -> Void)?) {
    
    HUD.show(.label("更新公式库..."))
    
    fetchDiscoverFormula(with: UploadFormulaMode.library, categoty: nil, failureHandler: { reason, errorMessage in
        
        HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 1.5)
        failureHandeler(reason, errorMessage)
        
    }, completion: { _ in
        
        HUD.flash(.label("更新成功"), delay: 1.5)
        completion?()
        
    })
}

public func fetchPreferences(failureHandler: @escaping FailureHandler, completion:@escaping ((String) -> Void)){
    
    let query = AVQuery(className: DiscoverPreferences.parseClassName())
    query.getFirstObjectInBackground { (references, error) in
        
        if error != nil { failureHandler(Reason.network(error), "同步数据库版本号失败") }
        
        if let references = references as? DiscoverPreferences {
            completion(references.version)
        }
    }
}

public func fetchDiscoverFormula(with uploadMode: UploadFormulaMode, categoty: Category?, failureHandler: @escaping FailureHandler, completion: (([Formula]) -> Void)?) {
    
    
    let query = AVQuery(className: DiscoverFormula.parseClassName())
    query.includeKey("creator")
    query.includeKey("contents")
    query.limit = 1000
    
    switch uploadMode {
        
    case .my:
        
        guard let currentUser = AVUser.current() else {
            printLog("当前没有登录用户, 获取我的公式失败")
            return
        }
        query.whereKey("creator", equalTo: currentUser)
        query.addAscendingOrder("name")
        
    case .library:
        query.whereKey("isLibrary", equalTo: NSNumber(booleanLiteral: true))
        query.addAscendingOrder("serialNumber")
    }
    
    printLog( "开始从LeanCloud中获取我的公式")
    query.findObjectsInBackground {
        newDiscoverFormulas, error in
        
        if error != nil {
            
            failureHandler(Reason.network(error), "syncFormula 请求失败")
            
        }
        
        if let newDiscoverFormulas = newDiscoverFormulas as? [DiscoverFormula] {
            
            guard let realm = try? Realm() else {
                return
            }
            
            realm.beginWrite()
            if !newDiscoverFormulas.isEmpty {
                printLog("共下载到\(newDiscoverFormulas.count)个公式 " )
                printLog("开始将 DiscoverFormula 转换成 Formula 并存入本地 Realm")
            }
            
            var newFormulas: [Formula] = []
            
            for discoverFormula in newDiscoverFormulas {
                
                convertDiscoverFormulaToFormula(discoverFormula: discoverFormula, uploadMode: uploadMode, withFeed: nil, inRealm: realm, completion: { formulas in
                    
                    newFormulas.append(formulas)
                })
            }
            
            
            if !newDiscoverFormulas.isEmpty { printLog("DiscoverFormula 转换 Formula 完成") }
            
            try? realm.commitWrite()
            
            completion?(newFormulas)
            
        }
        
    }
    
}


public func convertDiscoverFormulaToFormula(discoverFormula: DiscoverFormula, uploadMode: UploadFormulaMode, withFeed feed: Feed?, inRealm realm: Realm, completion: ((Formula) -> Void)?) {
    
    // 尝试从数据库中查找是否已经有存在的 Formula
    var formula = formulaWith(objectID: discoverFormula.localObjectID, inRealm: realm)
    
    let deleted = discoverFormula.deletedByCreator
    
    if deleted {
        if
            let discoverFormulaCreatorID = discoverFormula.creator?.objectId,
            let myID = AVUser.current()?.objectId {
            
            if discoverFormulaCreatorID == myID {
                
                if let formula = formula {
                    realm.delete(formula)
                }
                return
            }
            
        }
    }
    
    if formula == nil {
        
        let newFormula = Formula()
        newFormula.lcObjectID = discoverFormula.objectId!
        newFormula.localObjectID = discoverFormula.localObjectID
        newFormula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
        newFormula.isNewVersion = true
        realm.add(newFormula)
        formula = newFormula
        
    }
    
    if let formula = formula {
        
        if let discoverFormulaCreator = discoverFormula.creator {
            
            var user = userWith(discoverFormulaCreator.objectId!, inRealm: realm)
            
            if user == nil {
                let newUser = RUser()
                newUser.lcObjcetID = discoverFormulaCreator.objectId!
                
                realm.add(newUser)
                user = newUser
            }
            
            if let user = user {
                
                user.localObjectID = discoverFormulaCreator.localObjectID() ?? ""
                user.avatorImageURL = discoverFormulaCreator.avatorImageURL()
                user.nickname = discoverFormulaCreator.nickname() ?? ""
                user.username = discoverFormulaCreator.username ?? ""
                user.introduction = discoverFormulaCreator.introduction() ?? ""
                
                let oldMasterList: [String] = user.masterList.map({ $0.formulaID })
                
                if let newMasterList = discoverFormulaCreator.masterList() {
                    
                    if oldMasterList != newMasterList {
                       
                        realm.delete(user.masterList)
                        
                        let newRMasterList = newMasterList.map({ FormulaMaster(value: [$0, user]) })
                        
                        realm.add(newRMasterList)
                        
                    }
                }
                
                formula.creator = user
            }
        }
        
        formula.isPushed = true
        formula.isLibrary = discoverFormula.isLibrary
        formula.name = discoverFormula.name
        formula.imageName = discoverFormula.imageName
        formula.imageURL = discoverFormula.imageURL
        formula.categoryString = discoverFormula.category
        formula.typeString = discoverFormula.type
        formula.rating = discoverFormula.rating
        
        if formula.updateUnixTime != discoverFormula.updatedAt!.timeIntervalSince1970 {
            formula.isNewVersion = true
        }
        
        formula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
        formula.createdUnixTime = discoverFormula.createdAt!.timeIntervalSince1970
        
        // 如果 discoverFormula 有 imageURL , 用户自己上传了 Image
        
        formula.imageURL = discoverFormula.imageURL
        
        
        for discoverContent in discoverFormula.contents {
            
            var content = contentWith(discoverContent.localObjectID, inRealm: realm)
            
            if discoverContent.deletedByCreator {
                
//                if
//                    let currentUserID = AVUser.current()?.objectId ,
//                    let discoverContentCreaterID = discoverContent.creator.objectId {
//                    
//                    if currentUserID == discoverContentCreaterID {
//                        
//                        if let content = content {
//                            realm.delete(content)
//                        }
//                    }
//                }
//                
//                if discoverFormula.isLibrary {
//                    if let content = content {
//                        realm.delete(content)
//                        content = nil
//                    }
//                }
                
                if let content = content {
                    realm.delete(content)
                }
                
                continue
            }
            
            if content == nil {
                
                let newContent = Content()
                newContent.localObjectID = discoverContent.localObjectID
                newContent.lcObjectID = discoverContent.objectId!
                realm.add(newContent)
                content = newContent
            }
            
            if let content = content {
                
                content.creator = formula.creator
                content.atFormula = formula
                content.atFomurlaLocalObjectID = discoverContent.atFormulaLocalObjectID
                
                content.rotation = discoverContent.rotation
                content.text = discoverContent.text
                content.indicatorImageName = discoverContent.indicatorImageName
                
            }
        }
        
        if feed == nil {
            createOrUpdateRCategory(with: formula, uploadMode: uploadMode, inRealm: realm)
        }
        
        completion?(formula)
    }
}

internal func fetchDiscoverFeed(with kind: FeedCategory, feedSortStyle: FeedSortStyle, uploadingFeedMode: UploadFeedMode, lastFeedCreatDate: Date, failureHandler: @escaping FailureHandler, completion: (([DiscoverFeed]) -> Void)?) {
                                                                                                                           
    let query = AVQuery(className: DiscoverFeed.parseClassName())
    
    query.limit = 20
    query.includeKey("withFormula")
    query.includeKey("withFormula.contents")
    query.includeKey("creator")
//    query.addDescendingOrder("createAt")
    query.order(byDescending: "createdAt")
    
    switch kind {
        
    case .text:
        break
        
    case .image:
        break
        
    case .url:
        break
        
    case .audio:
        break
        
    case .location:
        break
        
    case .video:
        break
        
    case .formula:
        query.whereKey("categoryString", equalTo: FeedCategory.formula.rawValue)
        
    case .record:
        query.whereKey("categoryString", equalTo: FeedCategory.record.rawValue)
        
    default:
        break
    }
    
    switch uploadingFeedMode {
        
    case .top:
        // Do Noting
        break
    case .loadMore:
        query.whereKey("createAt", lessThan: lastFeedCreatDate)
    }
    
    query.findObjectsInBackground { newFeeds, error in
        
        if error != nil {
            
            failureHandler(Reason.network(error), "请求 Feed 失败")
            
        } else {
            
            if let newFeeds = newFeeds as? [DiscoverFeed] {
 
                newFeeds.forEach {
                    $0.parseAttachmentsInfo()
                }
                
                
                
                completion?(newFeeds)
            }
        }
    }
    
}

public func saveFeedWithDiscoverFeed(_ feedData: DiscoverFeed, group: Group, inRealm realm: Realm) {
    
    var _feed = feedWith(feedData.objectId!, inRealm: realm)
    
    if _feed == nil {
        
        let newFeed = Feed()
        newFeed.lcObjectID = feedData.objectId!
        newFeed.allowComment = feedData.allowComment
        newFeed.createdUnixTime = feedData.createdAt!.timeIntervalSince1970
        newFeed.updatedUnixTime = feedData.updatedAt?.timeIntervalSince1970 ?? 0
        newFeed.creator = getOrCreatRUserWith(feedData.creator, inRealm: realm)
        newFeed.body = feedData.body
        
        realm.add(newFeed)
        
        _feed = newFeed
        
    } else {
        
        #if DEBUG
            if _feed?.group == nil {
                printLog("feed have not with group, it may old (not deleted with conversation before)")
            }
        #endif
    }
    
    guard let feed = _feed else {
        return
    }
    
    feed.categoryString = feedData.categoryString
    feed.deleted = false
    
    feed.group = group
    group.withFeed = feed
    group.groupType = GroupType.Public.rawValue
    
//    feed.distance = feedData.distance
    
    feed.messagesCount = feedData.messagesCount
    
    if let attachment = feedData.attachment {
        
        switch attachment {
            
        case .images(let attachments):
            
            guard feed.attachments.isEmpty else {
                break
            }
            
            feed.attachments.removeAll()
            
            let localAttachments = attachments.map { (discoverAttachment) -> Attachment in
                let newAttachment = Attachment()
                newAttachment.metadata = discoverAttachment.metadata ?? ""
                newAttachment.URLString = discoverAttachment.URLString
                return newAttachment
            }
            
            feed.attachments.append(contentsOf: localAttachments)
            
        case .formula(let discoverFormula):
            
            guard feed.withFormula == nil else {
                break
            }
            
            convertDiscoverFormulaToFormula(discoverFormula: discoverFormula, uploadMode: .library, withFeed: feed, inRealm: realm, completion: {
                
                formula in
                feed.withFormula = formula
            })
            
        case .URL(let info):
            
            guard feed.openGraphInfo == nil else {
                break
            }
            
            let openGraphInfo = OpenGraphInfo(URLString: info.URL.absoluteString, siteName: info.siteName, title: info.title, infoDescription: info.infoDescription, thumbnailImageURLString: info.thumbnailImageURLString)
            
            realm.add(openGraphInfo, update: true)
            
            feed.openGraphInfo = openGraphInfo
            
        default:
            break
        }
    }
}


//public func convertDiscoverMessageToMessage(discoverMessage: DiscoverMessage, messageAge: MessageAge, inRealm realm: Realm, completion: (([String]) -> Void)?) {
//    
//    // 暂时使用同一线程的 Realm, 因为 Message 的 lcObjcetID 来自远端, 所以可能需要使用一个独立的线程
//    
//    guard let messageID = discoverMessage.objectId else {
//        return
//    }
//    
//    var message = messageWith(messageID, inRealm: realm)
//    
//    let deleted = discoverMessage.deletedByCreator
//    
//    if deleted {
//        if
//            let discoverMessageCreatorID = discoverMessage.creator.objectId,
//            let currentUserID = AVUser.current()?.objectId {
//            
//            if discoverMessageCreatorID == currentUserID {
//                
//                if let message = message {
//                    realm.delete(message)
//                }
//            }
//            
//        }
//    }
//    
//    if message == nil {
//        
//        let newMessage = Message()
//        newMessage.lcObjectID = discoverMessage.objectId!
//        newMessage.localObjectID = discoverMessage.localObjectID
//        
//        newMessage.textContent = discoverMessage.textContent
//        newMessage.mediaTypeInt = discoverMessage.mediaTypeInt
//        
//        newMessage.sendStateInt = MessageSendState.read.rawValue
//        
//        newMessage.createdUnixTime = (discoverMessage.createdAt?.timeIntervalSince1970)!
//        
//        if case .new = messageAge {
//           
//            if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
//                if newMessage.createdUnixTime < latestMessage.createdUnixTime {
//                    // 只考虑最近的消息，过了可能混乱的时机就不再考虑
//                    if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
//                        printLog("xbefore newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                        newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
//                        printLog("xadjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                    }
//                }
//            }
//        }
//        
//        realm.add(newMessage)
//        message = newMessage
//    }
//    
//    if let message = message {
//        
//        let sender = appendRUser(with: discoverMessage.creator, inRealm: realm)
//        
//        
//        message.creator = sender
//        message.recipientID = discoverMessage.recipientID
//        message.recipientType = discoverMessage.recipientType
//        
//        var senderFormGroup: Group? = nil
//        
//        if discoverMessage.recipientType == "group" {
//            
//            senderFormGroup = groupWith(discoverMessage.recipientID, inRealm: realm)
//            
//            if senderFormGroup == nil {
//                
//                let newGroup = Group()
//                newGroup.groupID = discoverMessage.recipientID
//                newGroup.incloudMe = true
//                
//                realm.add(newGroup)
//                
//                senderFormGroup = newGroup
//            }
//        }
//        
//        var conversation: Conversation?
//        
//        var conversationWithUser: RUser?
//        
//        if let senderFormGroup = senderFormGroup {
//            
//            conversation = senderFormGroup.conversation
//            
//        } else {
//           
//            
//        }
//        
//        
//    }
//}























