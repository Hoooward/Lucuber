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

public class MediaMetaData: Object {
    public dynamic var data: Data = Data()
    
    public var string: String? {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
    }
}

public class Message: Object {
    
//    public dynamic var openGraphDetected: Bool = false
//    public dynamic var openGraphInfo: OpenGraphInfo?
//    
//    public dynamic var coordinate: Coordinate?
    
    open dynamic var localObjectID: String = ""
    open dynamic var lcObjectID: String = ""
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var arrivalUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var mediaType: Int = 0
    open dynamic var textContent: String = ""
    
    
    
    open dynamic var attachmentURLString: String = ""
    open dynamic var localAttachmentName: String = ""
    open dynamic var thumbnailURLString: String = ""
    open dynamic var localThumbnailName: String = ""
    open dynamic var acctchmentID: String = ""
    
    open dynamic var attachmentExpiresUnixTime: TimeInterval = Date().timeIntervalSince1970 + (6 * 60 * 60 * 24) // 6天，过期时间s3为7天，客户端防止误差减去1天
    
    open var imageKey: String {
        return "image-\(self.localObjectID)-\(self.localAttachmentName)-\(self.thumbnailURLString)"
    }
    
    open var nicknameWithtextContent: String {
        if let nickname = creator?.nickname {
            return nickname + textContent
        } else {
            return textContent
        }
    }
    
    open var thumbnailImage: UIImage? {
        
        switch mediaType {
        case MessageMediaType.image.rawValue:
            if let imageFileURL = FileManager.cubeMessageImageURL(with: localAttachmentName) {
                return UIImage(contentsOfFile: imageFileURL.path)
            }
        case MessageMediaType.video.rawValue:
            if let imageFileURL = FileManager.cubeMessageImageURL(with: localThumbnailName) {
                return UIImage(contentsOfFile: imageFileURL.path)
            }
        default:
            return nil
        }
        return nil
    }
    
    open dynamic var mediaMetaData: MediaMetaData?
    
    //  public dynamic var socialWork: MessageSocialWork? github
    
    open dynamic var downloadState: Int = MessageDownloadState.noDownload.rawValue
    
    open dynamic var sendState: Int = MessageSendState.notSend.rawValue
    open dynamic var readed: Bool = true
    open dynamic var mediaPlayed: Bool = false
    open dynamic var hidden: Bool = false // 隐藏对方消息, 不再显示
    open dynamic var deletedByCreator: Bool = false
    open dynamic var blockedByRecipient: Bool = false
    
    open var isIndicator: Bool {
        return deletedByCreator || blockedByRecipient
    }
    
    open dynamic var creator: RUser?
    open dynamic var conversation: Conversation?
    
    open var isReal: Bool {
        
        if mediaType == MessageMediaType.sectionDate.rawValue {
            return false
        }
        return true
    }
    
    
    open func deleteAttachment(inRealm realm: Realm) {
        
        if let mediaMetaData = mediaMetaData {
            realm.delete(mediaMetaData)
        }
        
        switch mediaType {
            
        case MessageMediaType.image.rawValue:
            FileManager.removeMessageImageFile(with: localAttachmentName)
            
        case MessageMediaType.audio.rawValue:
            FileManager.removeMessageAudioFile(with: localAttachmentName)
            
        case MessageMediaType.video.rawValue:
            FileManager.removeMessageVideoFiles(with: localAttachmentName, thumbnailName: localThumbnailName)
            
        default:
            break
            // TODO: - 删除之后可能会添加的其他附件
        }
        
    }
    
    open func deletedInRealm(realm: Realm) {
        deleteAttachment(inRealm: realm)
        realm.delete(self)
    }
    
    open func updateForDeletedFromServerInRealm(realm: Realm) {
        deletedByCreator = true
        
        deleteAttachment(inRealm: realm)
        
        sendState = MessageSendState.read.rawValue
        readed = true
        textContent = ""
        mediaType = MessageMediaType.text.rawValue
    }
    
    
    
    
    
    open dynamic var invalidate: Bool = false
    
    
    
    
    open dynamic var recipientType: String = ""
    open dynamic var recipientID: String = ""
    
    
    
    
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

open class Draft: Object {
    
    open dynamic var messageToolbarState: Int = MessageToolbarState.normal.rawValue
    open dynamic var text: String = ""
    
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

public func ==(lhs: UsernamePrefixMatchedUser, rhs: UsernamePrefixMatchedUser) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct UsernamePrefixMatchedUser {
    public let localObjectID: String
    public let username: String
    public let nickname: String
    public let avatarURLString: String?
    public let lastSignInUnixTime: TimeInterval
    
    public var mentionUsername: String {
        return "@" + username
    }
}

extension UsernamePrefixMatchedUser: Hashable {
    
    public var hashValue: Int {
        return localObjectID.hashValue
    }
}

open class Conversation: Object {
    
    public var fakeID: String? {
        switch type {
        case ConversationType.oneToOne.rawValue:
            if let withFriend = withFriend {
                return "user" + withFriend.localObjectID
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
                return withFriend.localObjectID
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
    
    public var mentionInitUsers: [UsernamePrefixMatchedUser] {
        
        let users = messages.flatMap({ $0.fromFriend }).filter({ !$0.username.isEmpty && !$0.isMe })
        
        let usernamePrefixMatchedUser = users.map({
            UsernamePrefixMatchedUser(
                userID: $0.userID,
                username: $0.username,
                nickname: $0.nickname,
                avatarURLString: $0.avatarURLString,
                lastSignInUnixTime: $0.lastSignInUnixTime)
        })
        
        let uniqueSortedUsers = Array(Set(usernamePrefixMatchedUser)).sort({
            $0.lastSignInUnixTime > $1.lastSignInUnixTime
        })
        
        return uniqueSortedUsers
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
    
    public var latestValidMessage: Message? {
        return messages.filter({ ($0.hidden == false) && ($0.isIndicator == false && ($0.mediaType != MessageMediaType.sectionDate.rawValue)) }).sort({ $0.createdUnixTime > $1.createdUnixTime }).first
    }
  
    public var latestMessageTextContentOrPlaceholder: String? {
        
        guard let latestValidMessage = latestValidMessage else {
            return nil
        }
        
        if let mediaType = MessageMediaType(rawValue: latestValidMessage.mediaType), let placeholder = mediaType.placeholder {
            return placeholder
        } else {
            return latestValidMessage.textContent
        }
    }
    
    public var needDetectMention: Bool {
        return type == ConversationType.Group.rawValue
    }
}






public enum MessageMediaType: Int, CustomStringConvertible {
    
    case sectionDate = 0
    case text  = 1
    case image = 2
    case audio = 3
    case video = 4
    
    public var description: String {
        
        switch self {
        case .sectionDate:
            return "sectionDate"
        case .text:
            return "text"
        case .image :
            return "image"
        case .audio:
            return "audio"
        case .video:
            return "video"
        }
    }
    
    public var placeholder: String? {
        switch self {
        case .text:
            return nil
        case .image:
            return "[Image]"
        case .audio:
            return "[Audio]"
        case .video:
            return "[Video]"
        default:
            return "All messages read."
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


























