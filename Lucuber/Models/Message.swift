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


public enum UserFriendState: Int {
    case Stranger       = 0   // 陌生人
    case IssuedRequest  = 1   // 已对其发出好友请求
    case Normal         = 2   // 正常状态的朋友
    case Blocked        = 3   // 被屏蔽
    case Me             = 4   // 自己
    case Yep            = 5   // Yep官方账号
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


open class Message: Object {
    
    dynamic var creator: RUser?
    dynamic var mediaTypeInt: Int = 0
    dynamic var invalidate: Bool = false
    dynamic var sendStateInt: Int = 0
    dynamic var textContent: String = ""
    
    dynamic var localObjectID: String = ""
    dynamic var lcObjectID: String = ""
    
    dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    dynamic var arrivalUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var readed: Bool = true
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
    
            message.textContent = self.textContent
            
            // 在将本地创建的新 Message 推送到 LeanCloud的时候
            // 目前只有一种可能, 消息的创建者是本机自己.
            if isfromMe {
                message.creatarUser = AVUser.current()!
                
            } else {
                
                // 如果创建消息的不是自己, 通过UserID 获取User
                
            }
            
            message.creatUserID = creatUser?.userID ?? ""
            message.mediaTypeInt = self.mediaTypeInt
            message.sendState = self.sendStateInt
            message.invalidated = self.invalidate
            message.deletedByCreator = deletedByCreator
            message.recipientType = self.recipientType
            message.recipientID = self.recipientID
    
            return message
    
        }
    
    
    /// 判断是否是当前登录用户发送的 Message
    var isfromMe: Bool {
        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
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
            return "user"
            
        case .group:
            return "group"
        }
        
    }
    
}

enum GroupType: Int {
    
    case Public = 0
    case Privcate = 1
}

open class Group: Object {
    
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
    
    dynamic var withFormula: Formula?
    
    
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

public struct Recipient {
    
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

open class Conversation: Object {
    
    public var fakeID: String? {
        
        switch type {
        case ConversationType.oneToOne.rawValue:
            if let withFriend = withFriend {
                return "user" + withFriend.lcObjcetID
            }
        case ConversationType.group.rawValue:
            if let withGroup = withGroup {
                return "group" + withGroup.groupID
            }
        default:
            return nil
        }
        
        return nil
    }
    
  
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
    
  
}

public enum MessageMediaType: Int, CustomStringConvertible {
    
    case sectionDate = 0
    case text  = 1
    case Image = 2
    
    public var description: String {
        
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
    
    @NSManaged var localObjectID: String
    
    @NSManaged var textContent: String
    
    @NSManaged var creator: AVUser
    @NSManaged var creatorObjectID: String
    
    @NSManaged var compositedName: String
    
    @NSManaged var invalidated: Bool
    
    @NSManaged var mediaTypeInt: Int
    
    @NSManaged var imageURLs: [String]
    
    @NSManaged var sendState: Int
    
    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var recipientType: String
    
    @NSManaged var recipientID: String
    
    
    override init() {
        super.init()
        
    }
    
    init(contentText: String) {
        super.init()
        
        self.textContent = contentText
        
        self.mediaTypeInt = 1
        
    }

//    func convertToMessage() -> Message {
//        
//        let message = Message()
//        
//        message.readed = true
//        message.mediaTypeInt = mediaTypeInt
//        message.invalidate = invalidated
//        message.sendStateInt = sendState
////        message.imageURLs = imageURLs
//        message.textContent = textContent
//        message.messageID = objectId
//        message.leanCloudObjectID = objectId
//        message.createdUnixTime = createdAt.timeIntervalSince1970
//        message.updatedUnixTime = updatedAt.timeIntervalSince1970
//        
//        message.deletedByCreator = deletedByCreator
//        message.recipientID = recipientID
//        message.recipientType = recipientType
//        
//        
//        
//        return message
//    }

    
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


























