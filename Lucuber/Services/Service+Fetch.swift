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

func fetchUnreadMessage(failureHandler: FailureHandler?, completion: @escaping ([String]) -> Void) {
    
    guard let realm = try? Realm() else { return }
    let _latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: false).first
    let latestMessage = lastValidMessageInRealm(realm: realm)
    
    printLog("_latestMessage: \(_latestMessage?.localObjectID), \(_latestMessage?.createdUnixTime)")
    printLog("+latestMessage: \(latestMessage?.localObjectID), \(latestMessage?.createdUnixTime)")
    printLog("*now: \(NSDate().timeIntervalSince1970)")

	let query = AVQuery(className: "DiscoverMessage")
	query.includeKey("creator")
    query.order(byAscending: "createdAt")
	// 只拿最近的100个未读消息
    query.limit = 100
    
    if let latestMessage = latestMessage {
        
        let maxCreatedUnixTime = latestMessage.createdUnixTime
        query.whereKey("createdAt", greaterThan:  NSDate(timeIntervalSince1970: maxCreatedUnixTime))
        
        fetchMessageFromLeancloud(with: query, messageAge: .new, failureHandler: failureHandler, completion: completion)
        
    } else {
        
        return
    }

}

// 不使用公共的 fetchMessageFromLeancloud 方法, 避免服务器端查询表, 减少延迟
func fetchMessageWithMessageLcID(_ messageLcID: String, failureHandler: FailureHandler, completion: @escaping ( [String]) -> Void) {

    let discoverMessage = DiscoverMessage(className: "DiscoverMessage", objectId: messageLcID)
    
    discoverMessage.fetchInBackground { message, error in
        
        if let message = message as? DiscoverMessage {

            guard let realm = try? Realm() else {
                return
            }

            var newMessageIDs = [String]()
            realm.beginWrite()

            convertDiscoverMessageToRealmMessage(discoverMessage: message, messageAge: .new, inRealm: realm, completion: { messageIDs in
                newMessageIDs.append(contentsOf: messageIDs)
            })

            try? realm.commitWrite()

			completion(newMessageIDs)
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
    query.includeKey("creator")
    query.limit = 20
    
    switch messageAge {
    case .new:
        
        if let lastMessage = lastMessage {
            printLog("从本地 Realm 获取最新的 Message 创建日期, 开始请求更新的 Message")
            let maxCreatedUnixTime = lastMessage.createdUnixTime
            query.whereKey("createdAt", greaterThan:  NSDate(timeIntervalSince1970: maxCreatedUnixTime))
            query.limit = 1000
            // 升序排列, 优先拿创建之间最小的, 保证获取全部信息(不丢失信息)
            query.order(byAscending: "createdAt")
            
        } else {
            
            printLog("本地 Realm 中没有 Message, 开始请求最新的 20 条 Message")
            // 降序排列, 优先拿创建时间最大的
            query.order(byDescending: "createdAt")
        }
        
    case .old:
        
        if let firstMessage = firstMessage {
            printLog("从本地 Realm 获取最旧的 Message 创建日期, 开始请求更旧的 Message")
            let minCreatedUnixTime = firstMessage.createdUnixTime
            query.whereKey("createdAt", lessThan: NSDate(timeIntervalSince1970: minCreatedUnixTime))
            // 降序排列, 优先拿创建时间最大的
            query.order(byDescending: "createdAt")
        }
    }

    fetchMessageFromLeancloud(with: query, messageAge: messageAge, failureHandler: failureHandler, completion:
    completion)
}

public func fetchMessageFromLeancloud(with query: AVQuery, messageAge: MessageAge, failureHandler: FailureHandler?, completion: ((_ messagesID: [String]) -> Void)?) {

    query.findObjectsInBackground {
        result, error in

        if error != nil {
            failureHandler?(Reason.network(error), "网路请求 Messages 数据失败")
        }

        var messageIDs = [String]()

        if let discoverMessages = result as? [DiscoverMessage] {

            guard let realm = try? Realm() else {
                return
            }

            printLog("共获取到 **\(discoverMessages.count)** 个新 DiscoverMessages")

            realm.beginWrite()
            if !discoverMessages.isEmpty { printLog("开始将 DiscoverMessage 转换成 Message 并存入本地") }
            
            // 重新升序排列的目的是优先在数据库中创建比较早的 Message, 这样方便后面的 Message 与其对比创建时间,才能正确生成 SectionDateCell
            
            let sortedMessages = discoverMessages.sorted(by: {one, two in
                
                one.createdAt!.timeIntervalSince1970 < two.createdAt!.timeIntervalSince1970
                
            })
            
            for message in sortedMessages {
                
                convertDiscoverMessageToRealmMessage(discoverMessage: message, messageAge: messageAge, inRealm: realm) {
                    newMessagesID in
                    
                    messageIDs += newMessagesID
                }
            }
            
            if !discoverMessages.isEmpty {
                printLog(" DiscoverMessage 转换成 Message 已完成. 生成了 **\(messageIDs.count)** 个新" +
                        " Message")
            }

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
            /*
             如果 Fetch 到的 Message 是 me 创建的, 如果 Realm 中有, 删除, 如果没有, return
             如果 Fetch 到的 Message 不是 me 创建的, 在数据库中生成对象, 因为要标记撤回.
             这样处理是因为每次的 Fetch 都会拉取当前 Conversation 的最后一个不是我创建的 Message 之后的数据
             而之后的 Message 很可能是 Me 创建的
            */
            if let discoverMessageCreatorUserID = discoverMessage.creator.objectId, let meUserID = AVUser.current()?.objectId {
                
                if discoverMessageCreatorUserID == meUserID {
                    if let message = message {
                        realm.delete(message)
                    }
                    return
                }
            }
        }

        if message == nil {

            let newMessage = Message()
            newMessage.lcObjectID = discoverMessage.objectId!
            newMessage.localObjectID = discoverMessage.localObjectID

            newMessage.createdUnixTime = (discoverMessage.createdAt?.timeIntervalSince1970)!
            if case .new = messageAge {
                if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
                    if newMessage.createdUnixTime < latestMessage.createdUnixTime {
                        // 只考虑最近的消息，过了可能混乱的时机就不再考虑
                        if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
                            printLog("before newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                            newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
                            printLog("adjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                        }
                    }
                }
            }

            realm.add(newMessage)

            message = newMessage
        }

        if let message = message {
            
            
            
            if let messageCreatorUserID = discoverMessage.creator.objectId {

                var sender = userWith(messageCreatorUserID, inRealm: realm)

                if sender == nil {

                    let newUser = getOrCreatRUserWith(discoverMessage.creator, inRealm: realm)

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
                            newGroup.includeMe = false

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
						// TODO: - 与朋友聊天
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

                        // 上面这段代码暂时无用
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

                        if let sender = message.creator, sender.isMe {
                            message.readed = true
                        }

						// 标记未读状态
                        if message.conversation == nil && message.readed == false && message.createdUnixTime > conversation.updateUnixTime {

                            if message.createdUnixTime > (Date().timeIntervalSince1970 - (60*60*12)) {
								conversation.hasUnreadMessages = true
                                conversation.updateUnixTime = Date().timeIntervalSince1970
                            }
                        }

                        message.conversation = conversation
                        message.deletedByCreator = discoverMessage.deletedByCreator
                        message.textContent = discoverMessage.textContent
                        message.mediaType = discoverMessage.mediaType
                        message.attachmentURLString = discoverMessage.attachmentURLString
                        message.thumbnailURLString = discoverMessage.thumbnailURLString
                        message.sendState = MessageSendState.successed.rawValue

                        if discoverMessage.metaData.length > 0 {

                            let newMetaData = MediaMetaData()
                            newMetaData.data = discoverMessage.metaData as Data
                            realm.add(newMetaData)

                            message.mediaMetaData = newMetaData
                        }

                        var sectionDateMessageID: String?

                        tryCreatDateSectionMessage(with: conversation, beforeMessage: message, inRealm: realm, completion: {
                            sectionDateMessage in

                            realm.add(sectionDateMessage)

                            sectionDateMessageID = sectionDateMessage.localObjectID

                        })

                        if createdNewConversation {

                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name.changedConversationNotification, object: nil)
                            }

                        }

                        if let sectionDateMessageID = sectionDateMessageID {

                            completion?([sectionDateMessageID, messageID])
                        } else {
                            completion?([messageID])
                        }

                    } else {

                        message.deletedInRealm(realm: realm)
                    }
                }
            }
        }
    }
}


// MARK: - User


public func fetchSubscribeConversation(_ future: (() -> Void)?) {
    
    guard let me = AVUser.current() else {
        return
    }
    
    if let list = me.subscribeList() {
        
        let feeds: [DiscoverFeed] = list.map { DiscoverFeed(className: "DiscoverFeed", objectId: $0)}
        
        DiscoverFeed.fetchAll(inBackground: feeds, block: { result, error in
            
            if error != nil {
                defaultFailureHandler(Reason.network(error), "获取订阅 Feeds 失败")
            }
            
            if let feeds = result as? [DiscoverFeed] {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                realm.beginWrite()
                for feed in feeds {
                    
                    printLog(feed)
                    let groupID = feed.objectId!
                    
                    var group = groupWith(groupID, inRealm: realm)
                    
                    if group == nil {
                        
                        let newGroup = Group()
                        newGroup.groupID = groupID
                        
                        realm.add(newGroup)
                        
                        group = newGroup
                    }
                    
                    guard let feedGroup = group else {
                        return
                    }
                    
                    feedGroup.includeMe = true
                    feedGroup.groupType = GroupType.Public.rawValue
                    
                    if feedGroup.conversation == nil {
                        
                        let newConversation = Conversation()
                        
                        newConversation.type = ConversationType.group.rawValue
                        newConversation.withGroup = feedGroup
                        
                        realm.add(newConversation)
                    }
                
                    saveFeedWithDiscoverFeed(feed, group: feedGroup, inRealm: realm)
                }
                try? realm.commitWrite()
                
                UserDefaults.setIsSyncedSubscribeConversations(true)
                future?()
            }
        })
    }
}

public func fetchCubeCategorys(failureHandler: @escaping FailureHandler, completion: (([DiscoverCubeCategory]) -> Void)?) {
    
    let query = AVQuery(className: "DiscoverCubeCategory")
    query.addAscendingOrder("createdAt")
    
    query.findObjectsInBackground { result, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "获取所有魔方类型失败")
        }
        
        if let result = result as? [DiscoverCubeCategory] {
            completion?(result)
        }
    }
}

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

public func fetchMyInfoAndDoFutherAction(_ action: (() -> Void)?) {
    
    guard let realm = try? Realm() else {
        return
    }
    if let meID = AVUser.current()?.objectId {
        
        let query = AVQuery(className: "_User")
        query.whereKey("objectId", equalTo: meID)
        
        query.findObjectsInBackground {
            users, _ in
         
            if let user = users?.first as? AVUser {
                
                try? realm.write {
                    _ = getOrCreatRUserWith(user, inRealm: realm)
                }
                
                NotificationCenter.default.post(name: Config.NotificationName.newMyInfo, object: nil)
                
                action?()
            }
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

public func fetchHotKeyWords(completion: @escaping (([String]) -> Void)) {
   
    let query = AVQuery(className: DiscoverHotKeyword.parseClassName())
    query.findObjectsInBackground({ result, error in
        
        if let result = result as? [DiscoverHotKeyword] {
            completion(result.map { $0.keyword})
        }
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

// MARK: - Formula

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
            if let user = getOrCreatRUserWith(discoverFormulaCreator, inRealm: realm) {
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
        
        if let updateAt = discoverFormula.updatedAt {
            if formula.updateUnixTime != updateAt.timeIntervalSince1970 {
                formula.isNewVersion = true
            }
            formula.updateUnixTime = updateAt.timeIntervalSince1970
        }
        
        if let createdAt = discoverFormula.createdAt {
            formula.createdUnixTime = createdAt.timeIntervalSince1970
            
        }
        
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

public enum SearchFeedsMode {
    case `init`
    case loadMore
}
public func fetchDiscoverFeedWithKeyword(_ keyword: String, category: Category?, userID: String?, mode: SearchFeedsMode, lastFeedCreatDate: Date, failureHandler: @escaping FailureHandler, completion: (([DiscoverFeed]) -> Void)? ) {
    
    func creatBasicQuery() -> AVQuery {
        let query = AVQuery(className: DiscoverFeed.parseClassName())
        query.limit = 30
        query.includeKey("withFormula")
        query.includeKey("withFormula.contents")
        query.includeKey("withFormula.creator")
        query.includeKey("creator")
        query.order(byDescending: "createdAt")
        return query
    }
    
    let bodyQuery = AVQuery(className: DiscoverFeed.parseClassName())
    bodyQuery.whereKey("body", contains: keyword)
    
    let nicknameQuery = AVQuery(className: DiscoverFeed.parseClassName())
    nicknameQuery.whereKey("creator.nickname", contains: keyword)
    
    let formulaCateogyQuery = AVQuery(className: DiscoverFeed.parseClassName())
    formulaCateogyQuery.whereKey("withFormula.category", contains: keyword)
    
    let query = AVQuery(className: DiscoverFeed.parseClassName())
    query.limit = 30
    query.includeKey("withFormula")
    query.includeKey("withFormula.contents")
    query.includeKey("withFormula.creator")
    query.includeKey("creator")
    query.order(byDescending: "createdAt")
    query.whereKey("body", contains: keyword)
    
    switch mode {
        
    case .init:
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
                    printLog($0)
                    $0.parseAttachmentsInfo()
                }
                
                completion?(newFeeds)
            }
        }
    }
    
    
}


internal func fetchDiscoverFeed(with kind: FeedCategory?, feedSortStyle: FeedSortStyle, uploadingFeedMode: UploadFeedMode, lastFeedCreatDate: Date, failureHandler: @escaping FailureHandler, completion: (([DiscoverFeed]) -> Void)?) {
                                                                                                                           
    let query = AVQuery(className: DiscoverFeed.parseClassName())
    
    if let kind = kind {
        switch kind {
            
        case .formula:
            query.whereKey("categoryString", equalTo: FeedCategory.formula.rawValue)
            
        default:
            break
        }
    }
    
    query.limit = 30
    query.includeKey("withFormula")
    query.includeKey("withFormula.contents")
    query.includeKey("withFormula.creator")
    query.includeKey("creator")
    query.order(byDescending: "createdAt")
    
    
   
    
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
                    printLog($0)
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























