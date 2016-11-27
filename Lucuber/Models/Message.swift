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

public struct Recipient {
    let type: ConversationType
    let ID: String
}

public enum UserFriendState: Int {
    case Stranger       = 0   // 陌生人
    case IssuedRequest  = 1   // 已对其发出好友请求
    case Normal         = 2   // 正常状态的朋友
    case Blocked        = 3   // 被屏蔽
    case Me             = 4   // 自己
    case Yep            = 5   // Yep官方账号
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
    
//    public var fileExtension: FileExtension? {
//        switch self {
//        case .image:
//            return .jpeg
//        case .video:
//            return .mp4
//        case .audio:
//            return .m4a
//        default:
//            return nil // TODO: more
//        }
//    }
    
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
    open dynamic var attachmentID: String = ""
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
//            if let imageFileURL = FileManager.cubeMessageImageURL(with: localAttachmentName) {
//                return UIImage(contentsOfFile: imageFileURL.path)
//            }
            return nil
        case MessageMediaType.video.rawValue:
//            if let imageFileURL = FileManager.cubeMessageImageURL(with: localThumbnailName) {
//                return UIImage(contentsOfFile: imageFileURL.path)
//            }
            return nil
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
            
        case MessageMediaType.image.rawValue: break
//            FileManager.removeMessageImageFile(with: localAttachmentName)
            
        case MessageMediaType.audio.rawValue: break
//            FileManager.removeMessageAudioFile(with: localAttachmentName)
            
        case MessageMediaType.video.rawValue: break
//            FileManager.removeMessageVideoFiles(with: localAttachmentName, thumbnailName: localThumbnailName)
            
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
    
    
    open dynamic var recipientType: String = ""
    open dynamic var recipientID: String = ""
    
    
    
//    func convertToLMessage() -> DiscoverMessage {
//        
//        let message = DiscoverMessage()
//        
//        message.textContent = self.textContent
//        
//        // 在将本地创建的新 Message 推送到 LeanCloud的时候
//        // 目前只有一种可能, 消息的创建者是本机自己.
//        if isfromMe {
//            message.creatarUser = AVUser.current()!
//            
//        } else {
//            
//            // 如果创建消息的不是自己, 通过UserID 获取User
//            
//        }
//        
//        message.creatUserID = creatUser?.userID ?? ""
//        message.mediaTypeInt = self.mediaTypeInt
//        message.sendState = self.sendStateInt
//        message.invalidated = self.invalidate
//        message.deletedByCreator = deletedByCreator
//        message.recipientType = self.recipientType
//        message.recipientID = self.recipientID
//        
//        return message
//        
//    }
    
    
    /// 判断是否是当前登录用户发送的 Message
//    var isfromMe: Bool {
//        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
//            return false
//        }
//        return userID == creator!.lcObjcetID
//    }
    
    
}

// Feed
public enum FeedKind: String {
    
    case text = "text"
    case url = "web_page"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case location = "location"
    
    case AppleMusic = "apple_music"
    case AppleMovie = "apple_movie"
    case AppleEBook = "apple_ebook"
    
    
    public var needBackgroundUpload: Bool {
        switch self {
        case .image:
            return true
        case .audio:
            return true
        default:
            return false
        }
    }
    
    public var needParseOpenGraph: Bool {
        switch self {
        case .text:
            return true
        default:
            return false
        }
    }
}

public enum FeedCategory: String {
    case all = "所有"
    case formula = "公式"
    case record = "成绩"
    case topic = "话题"
}

open class Attachment: Object {
    
    //dynamic var kind: String = ""
    public dynamic var metadata: String = ""
    public dynamic var URLString: String = ""
}

open class FeedAudio: Object {
    public dynamic var feedID: String = ""
    public dynamic var URLString: String = ""
    public dynamic var metadata: Data = Data()
    public dynamic var fileName: String = ""
}

open class FeedLocation: Object {
    
//    public dynamic var name: String = ""
//    public dynamic var coordinate: Coordinate?
}

open class Feed: Object {
    
    open dynamic var feedID: String = ""
    open dynamic var allowComment: Bool = true
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var creator: RUser?
//    dynamic var distance: Double = 0 
    open dynamic var messagesCount: Int = 0
    open dynamic var body: String = ""
    open dynamic var kind: String = FeedKind.text.rawValue
    
    open var attachments = List<Attachment>()
    open dynamic var audio: FeedAudio?
    open dynamic var location: FeedLocation?
    open dynamic var withFormula: Formula?
    
    open dynamic var deleted: Bool = false // 被管理员或创建者删除
    
    open dynamic var group: Group?
    
    
    open func cascadeDelete(inRealm realm: Realm) {
        
        // 删除所有与 Feed 关联的 Attachment
        
        attachments.forEach { realm.delete($0) }
        
        // TODO: - 删除Formula
        
        if let formula = withFormula {
            formula.cascadeDelete(inRealm: realm)
        }
        
        realm.delete(self)
        
    }
    
    
    
}

enum GroupType: Int {
    
    case Public = 0
    case Privcate = 1
}

open class Group: Object {
    
    open dynamic var groupID: String = ""
    open dynamic var groupName: String = ""
    open dynamic var notificationEnabled: Bool = true
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    
    open dynamic var owner: RUser?
    open var members = List<RUser>()
    
    open dynamic var groupType: Int = GroupType.Privcate.rawValue
    
    open dynamic var withFeed: Feed?
    open dynamic var withFormula: Formula?
    
    open dynamic var incloudMe: Bool = false
    
    open let conversations = LinkingObjects(fromType: Conversation.self, property: "withGroup")
    
    open var conversation: Conversation? {
        return conversations.first
    }
    
    open func cascadeDelete(inRealm realm: Realm) {
        
        withFeed?.cascadeDelete(inRealm: realm)
        
        if let conversation = conversation {
            realm.delete(conversation)
            
            DispatchQueue.main.async {
                
//                NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.changedConversation, object: nil)
            }
            
        }
        
        realm.delete(self)
    }
    
    
}

open class Draft: Object {
    
//    open dynamic var messageToolbarState: Int = MessageToolbarState.normal.rawValue
    open dynamic var text: String = ""
    
}

public enum ConversationType: Int {
    case oneToOne = 0 // onetoone
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

public func ==(lhs: UsernamePrefixMatchedUser, rhs: UsernamePrefixMatchedUser) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct UsernamePrefixMatchedUser {
    
    public let localObjectID: String
    public let username: String
    public let nickname: String
    public let avatorURLString: String?
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
    
    open var fakeID: String? {
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
  
    open var recipiendID: String? {
        
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
    
    open var mentionInitUsers: [UsernamePrefixMatchedUser] {
        
        let users = messages.flatMap({ $0.creator }).filter({ !$0.username.isEmpty && !$0.isMe() })
        
        let usernamePrefixMatchedUser = users.map({
            UsernamePrefixMatchedUser(
                localObjectID: $0.localObjectID,
                username: $0.username,
                nickname: $0.nickname,
                avatorURLString: $0.avatorImageURL,
                lastSignInUnixTime: $0.lastSignInUnixTime)
        })
        
        let uniqueSortedUsers = Array(Set(usernamePrefixMatchedUser)).sorted(by: {
            $0.lastSignInUnixTime > $1.lastSignInUnixTime
        })
        
        return uniqueSortedUsers
    }
    
    open dynamic var type: Int = ConversationType.oneToOne.rawValue
    open dynamic var updateUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var withFriend: RUser?
    open dynamic var withGroup: Group?
    
    open dynamic var draft: Draft?
    
    open let messages = LinkingObjects(fromType: Message.self, property: "conversation")
    
    open dynamic var unreadMessageCount: Int = 0
    open dynamic var hasUnreadMessages: Bool = false
    open dynamic var mentionedMe: Bool = false
    open dynamic var lastMentionedMeUnixTime: TimeInterval = Date().timeIntervalSince1970 - 60*60*12
    
    open var latestValidMessage: Message? {
        return messages.filter({ ($0.hidden == false) && ($0.isIndicator == false && ($0.mediaType != MessageMediaType.sectionDate.rawValue)) }).sorted(by: { $0.createdUnixTime > $1.createdUnixTime }).first
    }
  
    open var latestMessageTextContentOrPlaceholder: String? {
        
        guard let latestValidMessage = latestValidMessage else {
            return nil
        }
        
        if let mediaType = MessageMediaType(rawValue: latestValidMessage.mediaType), let placeholder = mediaType.placeholder {
            return placeholder
        } else {
            return latestValidMessage.textContent
        }
    }
    
    open var needDetectMention: Bool {
        return type == ConversationType.group.rawValue
    }
}







func imageMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
    
//    guard !message.invalidate else {
//        return nil
//    }
    
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


























