//
//  Message.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud
import RealmSwift

public enum MessageAge {
    case old
    case new
}

func tryGetOrCreatMeInRealm(realm: Realm) -> RUser? {
    
    guard
        let currentUser = AVUser.current(),
        let userID = currentUser.objectId else {
        return nil
    }
    
    if let me = userWithUserID(userID: userID, inRealm: realm) {
        return me
        
    } else {
        
        let me = currentUser.converRUserModel()
        
        try? realm.write {
            realm.add(me)
        }
        
        return me
        
    }
}

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
            
            // 创建日期 section
            tryCreatDateSectionMessage(withNewMessage: message, conversation: conversation, realm: realm, completion: {
                sectionDateMessage in
                
                if let sectionDateMessage = sectionDateMessage {
                    
                    realm.add(sectionDateMessage)
                }
            })
            
            conversation.updateUnixTime = Date().timeIntervalSince1970
            
            // 发送通知
        }
        
    }
    
    try? realm.write {
        message.textContent = text
    }
        
    afterCreatedMessage?(message)
        
    
    // 音效
    
    
    //  网络发送
    
    convertToLeanCloudMessageAndSend(message: message, failureHandler: {
        
        failureHandler?()
        
        }, completion: { _ in
            
            completion?(true)
    })
    
}


func tryCreatDateSectionMessage(withNewMessage message: Message, conversation: Conversation, realm: Realm, completion: ((Message?) -> Void)? ) {
    
    let messages = messagesOfConversation(conversation: conversation, inRealm: realm)
    
    if messages.count > 1 {
        
        guard let index = messages.index(of: message) else {
            return
        }
        
        if let prevMessage = messages[safe: (index - 1)] {
            
            if message.createdUnixTime - prevMessage.createdUnixTime > 10 {
                
                let sectionDateMessageCreatedUnixTime = message.createdUnixTime - 0.00005
                let sectionDateMessageID = "sectionDate-\(sectionDateMessageCreatedUnixTime)"
                
                if let _ = messageWithMessageID(messageID: sectionDateMessageID, inRealm: realm) {
                    
                } else {
                    
                    let newSectionDateMessage = Message()
                    newSectionDateMessage.messageID = sectionDateMessageID
                    
                    newSectionDateMessage.conversation = conversation
                    newSectionDateMessage.mediaTypeInt = MessageMediaType.sectionDate.rawValue
                    
                    newSectionDateMessage.createdUnixTime = sectionDateMessageCreatedUnixTime
                    newSectionDateMessage.arrivalUnixTime = sectionDateMessageCreatedUnixTime
                    
//                    realm.add(newSectionDateMessage)
                    
                    completion?(newSectionDateMessage)
                }
                
            } else {
                
                completion?(nil)
            }
        } else {
            
            completion?(nil)
        }
    } else {
        
        completion?(nil)
    }
}


class Message: Object {
    
    dynamic var atObjectID: String = ""
    dynamic var creatUser: RUser?
    dynamic var mediaTypeInt: Int = 0
    dynamic var invalidate: Bool = false
    dynamic var sendStateInt: Int = 0
//    dynamic var imageURLs: [String] = []
    dynamic var textContent: String = ""
    
    dynamic var messageID: String = ""
    dynamic var leanCloudObjectID: String = ""
    
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var arrivalUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var readed: Bool = false
    dynamic var downloadState: Int = MessageDownloadState.noDownload.rawValue
    
    dynamic var deletedByCreator: Bool = false
    
    dynamic var recipientType: String = ""
    dynamic var recipientID: String = ""
    
    
    dynamic var conversation: Conversation?
    
    var mediaType: MessageMediaType {
        get {
            if let mediaType =  MessageMediaType(rawValue: mediaTypeInt) {
                return mediaType
            }
            return .sectionDate
        }
        set {
            mediaTypeInt = newValue.rawValue
        }
    }
    
        func convertToLMessage() -> DiscoverMessage {
    
            let message = DiscoverMessage()
    
            message.atObjectID = self.atObjectID
            message.textContent = self.textContent
//            message.creatUser = (self.creatUser?.convertToAVUser())!
            message.creatUserID = creatUser?.userID ?? ""
//            message.imageURLs = self.imageURLs
            message.mediaTypeInt = self.mediaTypeInt
            message.sendState = self.sendStateInt
            message.invalidated = self.invalidate
            message.deletedByCreator = deletedByCreator
    
            return message
    
        }
    
    
    /// 判断是否是当前登录用户发送的 Message
    var isfromMe: Bool {
        guard let currentUser = AVUser.current(), let userID = currenUser.objectId else {
            return false
        }
        return userID == creatUser!.userID
    }
    
    
}

public enum ConversationType: Int {
    case oneToOne = 0 // 1对1
    case group = 1 // 群组对话
    
    public var nameForServer: String {
        switch self {
        case .oneToOne:
            return "User"
            
        case .group:
            return "Circle"
        }
        
    }
    
}

enum GroupType: Int {
    
    case Public = 0
    case Privcate = 1
}

class Group: Object {
    
    dynamic var groupID: String = ""
    dynamic var groupName: String = ""
    dynamic var notificationEnabled: Bool = true
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    
    dynamic var owner: RUser?
    var members = List<RUser>()
    
    dynamic var groupType: Int = GroupType.Privcate.rawValue
    
    //    dynamic var withFeed: Feed
    
    dynamic var incloudMe: Bool = false
    
    let conversations = LinkingObjects(fromType: Conversation.self, property: "withGroup")
    
    var conversation: Conversation? {
        return conversations.first
    }
    
    dynamic var withFormula: RFormula?
    
    
    //    // 级联删除关联的数据对象
    //
    //    public func cascadeDeleteInRealm(realm: Realm) {
    //
    //        withFeed?.cascadeDeleteInRealm(realm)
    //
    //        if let conversation = conversation {
    //            realm.delete(conversation)
    //
    //            dispatch_async(dispatch_get_main_queue()) {
    //                NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.changedConversation, object: nil)
    //            }
    //        }
    //
    //        realm.delete(self)
    //    }
    
    
}

class Draft: Object {
    
}

struct Recipient {
    
    let type: ConversationType
    let ID: String
    
//    func conversationInReal(realm: Realm) -> Conversation? {
//        
//        switch type {
//            
//        case .oneToOne:
//            
//            break
//            
//        case .group:
//            
//            break
//        }
//    }
}

public class Conversation: Object {
    
  
    public var recipiendID: String? {
        
        switch type {
            
        case ConversationType.oneToOne.rawValue:
            if let withFriend = withFriend {
                return withFriend.userID
            }
            
        case ConversationType.group.rawValue:
            if let withGroup = withGroup {
                return withGroup.groupID
            }
            
        default:
            return nil
        }
        
        return nil
    }
    
    dynamic var type: Int = ConversationType.oneToOne.rawValue
    dynamic var updateUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var withFriend: RUser?
    dynamic var withGroup: Group?
    
    dynamic var draft: Draft?
    
    let messages = LinkingObjects(fromType: Message.self, property: "conversation")
    
    dynamic var unreadMessageCount: Int = 0
    dynamic var hasUnreadMessages: Bool = false
    dynamic var mentionedMe: Bool = false
    dynamic var lastMentionedMeUnixTime: TimeInterval = Date().timeIntervalSince1970 - 60*60*12
    
    //    var latestValidMessage: RMessage? {
    //        
    //        return messages.filter {
    //            
    //            $0
    //        }
    //    }
}

enum MessageMediaType: Int, CustomStringConvertible {
    
    case sectionDate = 0
    case text  = 1
    case Image = 2
    
    var description: String {
        
        switch self {
        case .sectionDate:
            return "sectionDate"
        case .text:
            return "text"
        case .Image :
            return "image"
        }
    }
    
}

enum MessageDownloadState: Int {
    case noDownload     = 0 // 未下载
    case downloading    = 1 // 下载中
    case downloaded     = 2 // 已下载
}

enum MessageSendState: Int, CustomStringConvertible {
    
    case notSend = 0
    case failed = 1
    case successed = 2
    case read = 3

    
    var description: String {
        
        switch self {
        case .notSend:
            return "notSend"
        case .failed:
            return "failed"
        case .successed:
            return "successed"
        case .read:
            return "read"
        }
    }
}

public class DiscoverMessage: AVObject, AVSubclassing {
    
    
    public class func parseClassName() -> String {
        return "DiscoverMessage"
    }
    
    @NSManaged var textContent: String
    
    @NSManaged var creatUser: AVUser
    
    @NSManaged var creatUserID: String
    
    @NSManaged var compositedName: String
    
    @NSManaged var invalidated: Bool
    
    @NSManaged var mediaTypeInt: Int
    
    //    @NSManaged var messageID: String
    
    @NSManaged var atObjectID: String
    
    @NSManaged var imageURLs: [String]
    
    @NSManaged var sendState: Int
    
    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var recipientType: String
    
    @NSManaged var recipientID: String
    
    override init() {
        super.init()
        
    }
    
    init(contentText: String, creatUser: AVUser) {
        super.init()
        
        self.textContent = contentText
        self.creatUser = creatUser
        
        self.mediaTypeInt = 1
        
    }

    func convertToMessage() -> Message {
        
        let message = Message()
        
        message.readed = true
        message.atObjectID = atObjectID
        message.mediaTypeInt = mediaTypeInt
        message.invalidate = invalidated
        message.sendStateInt = sendState
        message.creatUser = creatUser.converRUserModel()
//        message.imageURLs = imageURLs
        message.textContent = textContent
        message.messageID = objectId
        message.leanCloudObjectID = objectId
        message.createdUnixTime = createdAt.timeIntervalSince1970
        message.updatedUnixTime = updatedAt.timeIntervalSince1970
        
        message.deletedByCreator = deletedByCreator
        message.recipientID = recipientID
        message.recipientType = recipientType
        
        
        
        return message
    }

    
}


func imageMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
    
    guard !message.invalidate else {
        return nil
    }
    
//    if let mediaMetaData = message.mediaMetaData {
//        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
//            if let
//                width = metaDataInfo[YepConfig.MetaData.imageWidth] as? CGFloat,
//                height = metaDataInfo[YepConfig.MetaData.imageHeight] as? CGFloat {
//                return (width, height)
//            }
//        }
//    }
    
    return (100, 100)
}


























