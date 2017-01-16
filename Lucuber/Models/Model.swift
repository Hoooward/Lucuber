

import Foundation
import AVOSCloud
import RealmSwift

public enum Rotation: String {
    
    case FR = "FR"
    case FL = "FL"
    case BL = "BL"
    case BR = "BR"

    var placeholderText: String {

        switch self {
        case .FR:
            return "图例的状态"
        case .FL:
            return "魔方整体顺时针旋转 90° 的状态"
        case .BL:
            return "魔方整体顺时针旋转 180° 的状态"
        case .BR:
            return "魔方整体顺时针旋转 270° 的状态"
        }
    }
}

public enum Category: String {
    
    case x2x2 = "二阶"
    case x3x3 = "三阶"
    case x4x4 = "四阶"
    case x5x5 = "五阶"
    case x6x6 = "六阶"
    case x7x7 = "七阶"
    case x8x8 = "八阶"
    case x9x9 = "九阶"
    case x10x10 = "十阶"
    case x11x11 = "十一阶"
    case Other = "其他"
    case SquareOne = "Square One"
    case Megaminx = "Megaminx"
    case Pyraminx = "Pyraminx"
    case RubiksClock = "魔表"
    // !! 这两个不可以用作公式类型.
    case unKnow = "未知种类"
    case all = "所有公式"
    
    var sortIndex: Int {
        
        switch self {
        case .x2x2: return 1
        case .x3x3: return 2
        case .x4x4: return 3
        case .x5x5: return 4
        case .x6x6: return 5
        case .x7x7: return 6
        case .x8x8: return 7
        case .x9x9: return 8
        case .x10x10: return 9
        case .x11x11: return 10
        case .SquareOne: return 11
        case .Megaminx: return 12
        case .Pyraminx: return 13
        case .RubiksClock: return 14
        case .Other: return 15
        case .unKnow: return 16
        case .all: return 17
        }
    }
    
    var indicatorString: String {
        
        switch self {
        case .x2x2: return "2x2x2"
        case .x3x3: return "3x3x3"
        case .x4x4: return "4x4x4"
        case .x5x5: return "5x5x5"
        case .x6x6: return "6x6x6"
        case .x7x7: return "7x7x7"
        case .x8x8: return "8x8x8"
        case .x9x9: return "9x9x9"
        case .x10x10: return "10x10x10"
        case .x11x11: return "11x11x11"
        case .SquareOne: return "SquareOne"
        case .Megaminx: return "Megaminx"
        case .Pyraminx: return "Pyraminx"
        case .RubiksClock: return "RubiksColock"
        case .Other: return "其他"
        case .unKnow: return "未知"
        case .all: return "所有"
        }
    }
    
}

public enum FormulaUserMode {
    case normal
    case card
}

/*
 之后要添加Type, 不仅仅要在 plist 文件中添加, 还要来这里添加
 case test1 = "111"
 case test2 = "222"
 case test3 = "333"
 */
public enum Type: String {
    case Cross = "Cross"
    case F2L   = "F2L"
    case PLL   = "PLL"
    case OLL   = "OLL"
    case unKnow = "unKnow"
    
    var sortIndex: Int {

        switch self {
        case .Cross: return 1
        case .F2L:   return 2
        case .PLL:   return 3
        case .OLL:   return 4
        case .unKnow: return 5
        }
    }
    
    var sectionText: String {
        
        switch self {
        case .Cross:
            return "\(self.rawValue) - 中心块与底部十字"
        case .F2L:
            return "\(self.rawValue) - 中间层"
        case .OLL:
            return "\(self.rawValue) - 顶层方向"
        case .PLL:
            return "\(self.rawValue) - 顶层排列"
            
        case .unKnow:
            return "\(self.rawValue) - 未知类型"
        }
    }
}

open class RCategory: Object {
    dynamic var name = ""
    dynamic var uploadMode = ""
    
    func convertToCategory() -> Category {
        return Category(rawValue: name)!
    }
}

// MARK: - Formula

open class Formula: Object {
    
    override open static func primaryKey() -> String? {
        return "localObjectID"
    }
    
    open dynamic var localObjectID: String = ""
    open dynamic var lcObjectID: String = ""
    
    open dynamic var name: String = ""
    // 暂时没啥用的属性
    open dynamic var imageName: String = ""
    open dynamic var imageURL: String = ""
    
    open dynamic var favorate: Bool = false
    
    open dynamic var categoryString: String = ""
    open dynamic var typeString: String = ""
    open dynamic var creator: RUser?
    open dynamic var deletedByCreator: Bool = false
    open dynamic var rating: Int = 0
    open dynamic var isLibrary: Bool = false
    open dynamic var updateUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var isNewVersion: Bool = false
    open dynamic var isPushed: Bool = false

    // 仅存在关联一个 Feed 的可能
    open let withFeed = LinkingObjects(fromType: Feed.self, property: "withFormula")

	open var isBelongToFeed: Bool {
		if let _ = self.withFeed.first {
			return true
        }
		return false
    }

    open let totalContents = LinkingObjects(fromType: Content.self, property: "atFormula")
    
    open var contents: Results<Content> {
        let predicate = NSPredicate(format: "deleteByCreator = %@", false as CVarArg)
        return totalContents.filter(predicate)
    }
    
    open var category: Category {
        if let category = Category(rawValue: categoryString) {
            return category
        }
        return Category.unKnow
    }
    
    open var type: Type {
        if let type = Type(rawValue: typeString) {
            return type
        }
        return Type.unKnow
    }
    
    /// 上传图片时, 如果没有值, 使用之前的 URL -> 从公式到我的公式
    open var pickedLocalImage: UIImage?
    
    open var isReadyToPush: Bool {
        
        var isReady = false
        if let content = self.contents.first {
            isReady = !content.text.isDirty
        }
        
        if name.isDirty || typeString.isDirty || categoryString.isDirty {
            isReady = false
        }
        return isReady
    }
    
    open var maxContentCellHeight: CGFloat {
        
        var maxHeight: CGFloat = 0
        
        let cellHeigts: [CGFloat] =  self.contents.map{ $0.cellHeight}
        
        cellHeigts.forEach {
            if $0 > maxHeight {
                maxHeight = $0
            }
        }
        return maxHeight
    }
    
    open class func new(_ isLibrary: Bool = false, inRealm realm: Realm) -> Formula {
        
        let newFormula = Formula()
        newFormula.localObjectID = Formula.randomLocalObjectID()
        newFormula.categoryString = Category.x3x3.rawValue
        newFormula.typeString = Type.F2L.rawValue
        newFormula.rating = 3
        newFormula.favorate = false
        newFormula.deletedByCreator = false
        newFormula.isLibrary = isLibrary
        newFormula.creator = currentUser(in: realm)
        newFormula.isPushed = false
        let randomInt = arc4random_uniform(11)
        newFormula.pickedLocalImage = UIImage(named: "cube_Placehold_image_\(randomInt + 1)")!
        let _ = Content.new(with: newFormula, inRealm: realm)
        realm.add(newFormula)
        
        return newFormula
    }
    
    open func cleanBlankContent(inRealm realm: Realm) {
        realm.delete(self.contents.filter({ $0.text.isEmpty }))
    }
    
    open func cascadeDelete(inRealm realm: Realm) {
        
        self.contents.forEach {
            realm.delete($0)
        }
        realm.delete(self)
    }
    
    override open static func ignoredProperties() -> [String] {
        return ["pickedLocalImage", "category", "type"]
    }
}


open class Content: Object {
    
    override open static func primaryKey() -> String? {
        return "localObjectID"
    }
    
    open dynamic var localObjectID: String = ""
    open dynamic var lcObjectID: String = ""
    
    open dynamic var text: String = ""
    open dynamic var rotation: String = ""
    open dynamic var indicatorImageName: String = ""
    open dynamic var atFormula: Formula?
    open dynamic var atFomurlaLocalObjectID: String = ""
    
    open dynamic var creator: RUser?
    
    // 当被用户删除时, 推送
    open dynamic var deleteByCreator: Bool = false
    
    // 用户标记是否有本地数据更新, 判断是否需要推送
    open dynamic var isPushed: Bool = false
    
    open class func new(with formula: Formula, inRealm realm: Realm) -> Content {
        
        let newContent = Content()
        newContent.localObjectID = Content.randomLocalObjectID()
        newContent.rotation = Rotation.FR.rawValue
        newContent.atFormula = formula
        newContent.atFomurlaLocalObjectID = formula.localObjectID
        newContent.deleteByCreator = false
        newContent.creator = currentUser(in: realm)
        newContent.isPushed = false
        
        realm.add(newContent)
        
        return newContent
    }
    
    open var cellHeight: CGFloat {
        
        var height: CGFloat = 50
        
        if text.characters.count > 0 {
            
            let attributesText = text.setAttributesFitDetailLayout(style: .center)
            let screenWidth = UIScreen.main.bounds.width
            let rect = attributesText.boundingRect(with: CGSize(width: screenWidth - 38 - 38 , height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            height = rect.size.height + 30
        }
        return height
        
        
    }

    
}


// MARK: - User

open class Preferences: Object {
    // 未登录用户在登录成功时, 将其设置为 0.9
    dynamic var dateVersion: String = ""
}

open class Avatar: Object {
    
    open dynamic var avatarUrlString: String = ""
    open dynamic var avatarFileName: String = ""
    open dynamic var roundMini: Data = Data() // 60
    open dynamic var roundNano: Data = Data() // 40
    
    open let users = LinkingObjects(fromType: RUser.self, property: "avatar")
    open var user: RUser? {
        return users.first
    }
}

open class FormulaMaster: Object {
    /// localobjectID
    open dynamic var formulaID: String = ""
    open dynamic var atRUser: RUser?
}

open class CubeCategoryMaster: Object {
    open dynamic var categoryString = ""
    open dynamic var atRUser: RUser?
}

open class SubscribeFeed: Object {
    open dynamic var feedID: String = ""
    open dynamic var atRUser: RUser?
}

open class RUser: Object {
    
//    open dynamic var friendState: String = ""
    
    open dynamic var lcObjcetID: String = ""
    open dynamic var localObjectID: String = ""
    open dynamic var nickname: String = ""
    open dynamic var username: String = ""
    open dynamic var avatorImageURL: String?
    open dynamic var introduction: String?
    
    open let masterList = LinkingObjects(fromType: FormulaMaster.self, property: "atRUser")
    open let cubeCategoryMasterList = LinkingObjects(fromType: CubeCategoryMaster.self, property: "atRUser")
    open let subscribeList = LinkingObjects(fromType: SubscribeFeed.self, property: "atRUser")
    
    open let createdFeeds = LinkingObjects(fromType: Feed.self, property: "creator")
    open let messages = LinkingObjects(fromType: Message.self, property: "creator")
    open let conversations = LinkingObjects(fromType: Conversation.self, property: "withFriend")
    
    open var conversation: Conversation? {
        return conversations.first
    }
    
    open let scoreGroups = LinkingObjects(fromType: ScoreGroup.self, property: "creator")

    open let ownedGroups = LinkingObjects(fromType: Group.self, property: "owner")
    open let belongsToGroups = LinkingObjects(fromType: Group.self, property: "members")
    
    open override static func indexedProperties() -> [String] {
        return ["localObjectID"]
    }
    
    open var isMe: Bool {
        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
            return false
        }
        return userID == self.lcObjcetID
    }
    
    // TODO: - 之后需要使用的属性
    open dynamic var blogURLString: String = ""
    open dynamic var blogTitle: String = ""
    open dynamic var avatar: Avatar?
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var lastSignInUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open var mentionedUsername: String? {
        if username.isEmpty {
            return nil
        } else {
            return "@\(username)"
        }
    }
    
    open var compositedName: String {
        if username.isEmpty {
            return nickname
        } else {
            return "\(nickname) @\(username)"
        }
    }
    
    open func cascadeDeleteInRealm(realm: Realm) {
        
        if let avatar = avatar {
            if !avatar.avatarFileName.isEmpty {
                FileManager.deleteAvatarImage(with: avatar.avatarFileName)
            }
            realm.delete(avatar)
        }
        
        if !masterList.isEmpty {
            realm.delete(masterList)
        }
        realm.delete(self)
    }
}

public enum UserFriendState: Int {
    case stranger       = 0   // 陌生人
    case issuedRequest  = 1   // 已对其发出好友请求
    case normal         = 2   // 正常状态的朋友
    case blocked        = 3   // 被屏蔽
    case me             = 4   // 自己
    case Lucuber        = 5   // Lucuber官方账号
}

public enum MessageMediaType: Int, CustomStringConvertible {
    
    //文本消息	-1
    //图像消息	-2
    //音频消息	-3
    //视频消息	-4
    //位置消息	-5
    //文件消息	-6
    
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
        case .sectionDate:
            return nil
        case .text:
            return nil
        case .image :
            return "图片"
        case .audio:
            return "声音"
        case .video:
            return "视频"
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

// MARK: - Message

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
    
    open var recalledTextContent: String {
        let nickname = creator?.nickname ?? ""
        return String(format: "%@ 撤回了一条消息", nickname)
    }
    
    open var blockedTextContent: String {
        let nickname = creator?.nickname ?? ""
        return String(format: NSLocalizedString("Ooops! You've been blocked.", comment: ""), nickname)
    }
    
    open var nicknameWithtextContent: String {
        if let nickname = creator?.nickname {
            return nickname + ": " + textContent
        } else {
            return textContent
        }
    }
    
    open var thumbnailImage: UIImage? {
        
        switch mediaType {
        case MessageMediaType.image.rawValue:
            if let imageURL = FileManager.cubeMessageImageURL(with: localAttachmentName) {
                return UIImage(contentsOfFile: imageURL.path)
            }
        case MessageMediaType.video.rawValue:
            if let imageURL = FileManager.cubeMessageImageURL(with: localThumbnailName) {
                return UIImage(contentsOfFile: imageURL.path)
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
    open dynamic var readed: Bool = false
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
    
    
    open dynamic var recipientType: String = ""
    open dynamic var recipientID: String = ""
    
    
    /// 判断是否是当前登录用户发送的 Message
    var isfromMe: Bool {
        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
            return false
        }
        return userID == creator!.lcObjcetID
    }
    
}

open class MediaMetaData: Object {
    open dynamic var data: Data = Data()
    
    open var dataString: String? {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
    }
}

// MARK: - Feed

public enum FeedSortStyle: String {
    
    case distance = "distance"
    case time = "time"
    case match = "default"
    case recommended = "recommended"
    
    public var name: String {
        switch self {
        case .distance:
            return NSLocalizedString("Nearby", comment: "")
        case .time:
            return NSLocalizedString("Time", comment: "")
        case .match:
            return NSLocalizedString("Match", comment: "")
        case .recommended:
            return NSLocalizedString("Recommended", comment: "")
        }
    }
    
    public var nameWithArrow: String {
        return name + " ▾"
    }
    
    public var needPageFeedID: Bool {
        switch self {
        case .distance:
            return true
        case .time:
            return true
        case .match:
            return false
        case .recommended:
            return true
        }
    }
}

public enum FeedCategory: String {
    
    case text = "text"
    case url = "web_page"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case location = "location"
    case formula = "formula"
    case record = "record"
    
    case AppleMusic = "apple_music"
    case AppleMovie = "apple_movie"
    case AppleEBook = "apple_ebook"
    
    
    public var title: String {
        
        switch self {
        case .formula:
            return "公式"
        case .record:
            return "成绩"
        default:
            return "话题"
        }
    }
    
    public var needBackgroundUpload: Bool {
        switch self {
        case .image:
            return true
        case .audio:
            return true
        case .formula:
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

//public enum FeedCategory: String {
//    case all = "所有"
//    case formula = "公式"
//    case record = "成绩"
//    case topic = "话题"
//}

open class Attachment: Object {
    
    //dynamic var kind: String = ""
    open dynamic var metadata: String = ""
    open dynamic var URLString: String = ""
}

open class FeedAudio: Object {
    open dynamic var feedID: String = ""
    open dynamic var URLString: String = ""
    open dynamic var metadata: NSData = NSData()
    open dynamic var fileName: String = ""
}

open class FeedLocation: Object {
    
    //    public dynamic var name: String = ""
    //    public dynamic var coordinate: Coordinate?
}


open class OpenGraphInfo: Object {
    
    open dynamic var URLString: String = ""
    open dynamic var siteName: String = ""
    open dynamic var title: String = ""
    open dynamic var infoDescription: String = ""
    open dynamic var thumbnailImageURLString: String = ""
    
//    open let messages = LinkingObjects(fromType: Message.self, property: "openGraphInfo")
    open let feeds = LinkingObjects(fromType: Feed.self, property: "openGraphInfo")
    
    open override class func primaryKey() -> String? {
        return "URLString"
    }
    
    open override class func indexedProperties() -> [String] {
        return ["URLString"]
    }
    
    public convenience init(URLString: String, siteName: String, title: String, infoDescription: String, thumbnailImageURLString: String) {
        self.init()
        
        self.URLString = URLString
        self.siteName = siteName
        self.title = title
        self.infoDescription = infoDescription
        self.thumbnailImageURLString = thumbnailImageURLString
    }
    
    open class func withURLString(URLString: String, inRealm realm: Realm) -> OpenGraphInfo? {
        return realm.objects(OpenGraphInfo.self).filter("URLString = %@", URLString).first
    }
}

open class Feed: Object {
    
    open dynamic var lcObjectID: String = ""
    open dynamic var allowComment: Bool = true
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    open dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var creator: RUser?
    //    dynamic var distance: Double = 0
    open dynamic var messagesCount: Int = 0
    open dynamic var body: String = ""
    open dynamic var categoryString: String = FeedCategory.text.rawValue
    
    open var attachments = List<Attachment>()
    open dynamic var audio: FeedAudio?
    open dynamic var location: FeedLocation?
    open dynamic var withFormula: Formula?
    open dynamic var openGraphInfo: OpenGraphInfo?
    
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

public enum GroupType: Int {
    
    case Public = 0
    case Private = 1
}

open class Group: Object {
    
    open dynamic var groupID: String = ""
    open dynamic var groupName: String = ""
    open dynamic var notificationEnabled: Bool = false
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open dynamic var owner: RUser?
    open var members = List<RUser>()
    
    open dynamic var groupType: Int = GroupType.Public.rawValue
    
    open dynamic var withFeed: Feed?
    open dynamic var withFormula: Formula?
    
    open dynamic var includeMe: Bool = false
    
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
        
        let users = messages.flatMap({ $0.creator }).filter({ !$0.username.isEmpty && !$0.isMe })
        
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
    
    open dynamic var type: Int = ConversationType.group.rawValue
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
        return latestValidMessage.className
        
//        if let mediaType = MessageMediaType(rawValue: latestValidMessage.mediaType), let placeholder = mediaType.placeholder {
//            return placeholder
//        } else {
//            return latestValidMessage.textContent
//        }
    }
    
    open var needDetectMention: Bool {
        return type == ConversationType.group.rawValue
    }
}


protocol RandomID {
    static func randomLocalObjectID() -> String
}

extension RandomID where Self: Object {
    
}

extension Formula: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Formula_" + String.random()
    }
}

extension Content: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Content_" + String.random()
    }
}

extension RUser: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "RUser_" + String.random()
    }
}

extension Message: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Message_" + String.random()
    }
}

extension Feed: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Feed" + String.random()
    }
}

extension ScoreGroup: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "ScoreGroup" + String.random()
    }
}

extension Score: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Score" + String.random()
    }
}

open class SubscribeViewShown: Object {
    
    open dynamic var groupID: String = ""
    
    open override class func primaryKey() -> String? {
        return "groupID"
    }
    
    open override class func indexedProperties() -> [String] {
        return ["groupID"]
    }
    
    public convenience init(groupID: String) {
        self.init()
        self.groupID = groupID
    }
    
    open class func canShow(groupID: String) -> Bool {
        guard let realm = try? Realm() else {
            return false
        }
        return realm.objects(SubscribeViewShown.self).filter("groupID = %@", groupID).isEmpty
    }
    
}

let defaultScoreGroupLocalObjectId: String = "defaultScoreGroup"

open class Score: Object {
    
    open dynamic var localObjectId: String = ""
    open dynamic var lcObjectId: String = ""
    
    open dynamic var timertext: String = ""
    open dynamic var timer: TimeInterval = 0
    
    open dynamic var creator: RUser?
    open dynamic var category: String = ""
    
    open dynamic var isPOP: Bool = false
    open dynamic var isDNF: Bool = false
    open dynamic var isDeleteByCreator: Bool = false
    
    open dynamic var scramblingText: String = ""
    open dynamic var atGroup: ScoreGroup?
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    var realTimerString: String {
        return String(format: "%.3f", timer)
    }
}

open class ScoreGroup: Object {
    
    open dynamic var lcObjectId: String = ""
    open dynamic var localObjectId: String = ""
    open dynamic var category: String = ""
    open dynamic var creator: RUser?
    open dynamic var isDeleteByCreator: Bool = false
    
    open let timerList = LinkingObjects(fromType: Score.self, property: "atGroup")
    
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    open func cascadeDelete(inRealm realm: Realm) {
        timerList.forEach {
            realm.delete($0)
        }
        realm.delete(self)
    }
    
    open var popCount: Int {
        let predicate = NSPredicate(format: "isPOP == %@", true as CVarArg)
        let list = timerList.filter(predicate)
        return list.isEmpty ? 0 : list.count
    }
    
    open var popCountString: String {
        return "\(popCount)"
    }
    
    open var dnfCount: Int {
        let predicate = NSPredicate(format: "isDNF == %@", true as CVarArg)
        let list = timerList.filter(predicate)
        return list.isEmpty ? 0 : list.count
    }
    
    open var dnfCountString: String {
        return "\(dnfCount)"
    }
    
    open var fastestTimer: Score? {
        let predicate = NSPredicate(format: "isDNF == %@", false as CVarArg)
        return timerList.filter(predicate).sorted(byProperty: "timer", ascending: true).first
    }
    
    open var fastestTimerString: String {
        guard let score = fastestTimer else {
            return "00:00:00"
        }
        return score.timertext
    }
    
    open var realFastestTimerString: String {
        guard let score = fastestTimer else {
            return "0.000"
        }
        return score.realTimerString
    }
    
    open var slowliestTimer: Score? {
        
        let predicate = NSPredicate(format: "isDNF == %@", true as CVarArg)
        let dnfList = timerList.filter(predicate).sorted(byProperty: "timer", ascending: true)
        
        if dnfList.isEmpty {
            return timerList.sorted(byProperty: "timer", ascending: true).last
        } else {
            return dnfList.last
        }
    }
    
    open var slowliestTimerString: String {
        guard let score = slowliestTimer else {
            return "0.000"
        }
        return score.isDNF ? "DNF" : score.timertext
    }
    
    open var realSlowliestTimerString: String {
        guard let score = slowliestTimer else {
            return "0.000"
        }
        return score.isDNF ? "DNF" : score.realTimerString
    }
    
    open var fiveStepsAverageString: String {
        guard timerList.count >= 5 else {
            return "0.000"
        }
        
        var timerListArray: [Score] = timerList.sorted(byProperty: "createdUnixTime", ascending: false).map { $0 }
        // 拿到前 5 个 score 中的 dnf
        let frontFiveValidScore = timerListArray[0..<5]
        
        let dnfList = frontFiveValidScore.filter { $0.isDNF == true }
        
        switch dnfList.count {
            
        case 0, 1:
            return calculateAverageString(array: frontFiveValidScore.map { $0 })
            
        default:
            return "DNF \(dnfList.count) 次"
        }
    }
    
    open var tenStepsAverageString: String {
        
        guard timerList.count >= 10 else {
            return "0.000"
        }
        
        var timerListArray: [Score] = timerList.sorted(byProperty: "createdUnixTime", ascending: false).map { $0 }
        // 拿到前 10 个 score 中的 dnf
        let frontTenValidScore = timerListArray[0..<10]
        
        let dnfList = frontTenValidScore.filter { $0.isDNF == true }
        
        switch dnfList.count {
            
        case 0, 1:
            return calculateAverageString(array: frontTenValidScore.map { $0 })
            
        default:
            return "DNF \(dnfList.count) 次"
        }
        
    }
    
    open var totalAverageString: String {
        
        guard !timerList.isEmpty else {
           return "0.000"
        }
        let predicate = NSPredicate(format: "isPOP = false AND isDNF = false")
        return calculateAverageString(array: timerList.filter(predicate).map { $0 })
    }
    
    open var totalSubString: String {
        
        guard !timerList.isEmpty else {
            return "00.0"
        }
        
        let predicate = NSPredicate(format: "isPOP = false AND isDNF = false")
        let lastScore = timerList.filter(predicate).sorted(byProperty: "timer", ascending: true).last
        
        if let lastScore = lastScore {
            return "\(ceil(lastScore.timer))"
        } else {
            return "00.0"
        }
    }
    
    open var excludeFastestAndSlowliestOnAverage: String {
        
        guard timerList.count >= 3 else {
            return "0.000"
        }
        
        /*
        let predicate = NSPredicate(format: "isDNF == %@", true as CVarArg)
        let dnfList = timerList.filter(predicate).sorted(byProperty: "timer", ascending: true)
        
        var list: [Score] = timerList.sorted(byProperty: "timer", ascending: true).map { $0 }
        
        list.removeFirst()
        
        if dnfList.isEmpty {
            list.removeLast()
            
        } else {
            // 删除所有 DNF 的数据
            var dnfIndexs = [Int]()
            
            dnfList.forEach {
                if let index = list.index(of: $0) {
                   dnfIndexs.append(index)
                }
            }
            printLog(dnfIndexs)
            printLog(list)
            
            for index in dnfIndexs {
                printLog(index)
                list.remove(at: index)
                
            }
        }
        return calculateAverageString(array: list)
         */
        
        let dnfPredicate = NSPredicate(format: "isDNF == %@", true as CVarArg)
        let dnfList = timerList.filter(dnfPredicate).sorted(byProperty: "timer", ascending: true)
        
        let predicate = NSPredicate(format: "isDNF == %@", false as CVarArg)
        let list: [Score] = timerList.filter(predicate).sorted(byProperty: "timer", ascending: true).map { $0 }
        
        guard list.count >= 3 else {
            return "DNF \(dnfList.count) 次"
        }
        
        return calculateAverageString(array: list)
        
    }
    
    private func calculateAverageString(array: [Score]) -> String {
        /*
        let total = array.map { $0.timer }.reduce(0) { total, num in total + num } / Double(array.count)
         */
        
        let timers = array.map { $0.timer }
        
        var total: Double = 0
        
        for timer in timers {
            total += timer
        }
        
        return String(format: "%.3f", total / Double(timers.count))
    }
    

    
    public enum DateStyle {
        case full
        case short
    }
    
    open func dateSectionString(with style: DateStyle) -> String {
        
        let timerListArray: [Score] = timerList.sorted(byProperty: "createdUnixTime", ascending: true).map { $0 }
        
        if var firstScoreCreatedUnixTime = timerListArray.first?.createdUnixTime,
            let lastScoreScretedUnixtime = timerListArray.last?.createdUnixTime {
            
            if firstScoreCreatedUnixTime < self.createdUnixTime {
                firstScoreCreatedUnixTime = self.createdUnixTime
            }
            
            let firstString = Config.timeSectionFormatter().string(from: Date(timeIntervalSince1970: firstScoreCreatedUnixTime))
            let lastString = Config.timeSectionFormatter().string(from: Date(timeIntervalSince1970: lastScoreScretedUnixtime))
            
            switch style {
            case .full:
                return firstString + " - " + lastString
                
            case .short:
                return lastString
            }
        }
        
        return Config.timeSectionFormatter().string(from: Date(timeIntervalSince1970: self.createdUnixTime))
    }
}

// MARK: - Group

public func scoreGroupWith(_ localObjectId: String, inRealm realm: Realm) -> ScoreGroup? {
    let predicate = NSPredicate(format: "localObjectId = %@", localObjectId)
    return realm.objects(ScoreGroup.self).filter(predicate).first
}

public func scoreGroupWith(user: RUser?, inRealm realm: Realm) -> Results<ScoreGroup> {
    guard let user = user else { fatalError() }
    
    let predicate = NSPredicate(format: "creator == %@", user)
    let result = realm.objects(ScoreGroup.self).filter(predicate).sorted(byProperty: "createdUnixTime", ascending: false)
    
    if result.first == nil {
        try? realm.write {
            let newGroup = ScoreGroup()
            newGroup.localObjectId = ScoreGroup.randomLocalObjectID()
            newGroup.category = "三阶"
            newGroup.creator = currentUser(in: realm)
            realm.add(newGroup)
        }
    }
    return realm.objects(ScoreGroup.self).filter(predicate).sorted(byProperty: "createdUnixTime", ascending: false)
}


public func getOrCreatedMyLastScoreGroup(inRealm realm: Realm) -> ScoreGroup {
    
    var group = scoreGroupWith(user: currentUser(in: realm), inRealm: realm).first
    
    if group == nil {
        
        try? realm.write {
            let newGroup = ScoreGroup()
            newGroup.localObjectId = ScoreGroup.randomLocalObjectID()
            newGroup.category = "三阶"
            newGroup.creator = currentUser(in: realm)
            realm.add(newGroup)
            
            group = newGroup
        }
    }
    
    return group!
}




