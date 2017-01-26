//
//  DiscoverModel.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import CoreLocation
import RealmSwift

public class DiscoverScore: AVObject, AVSubclassing {
    
    public static func parseClassName() -> String {
        return "DiscoverScore"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var timertext: String
    @NSManaged var timer: Double
    @NSManaged var scramblingText: String
    
    @NSManaged var creator: AVUser?
    
    @NSManaged var isPOP: Bool
    @NSManaged var isDNF: Bool
    @NSManaged var isDeleteByCreator: Bool
    
    @NSManaged var createdUnixTime: Double
    
    @NSManaged var atGroup: String
    @NSManaged var atGroupCategory: String
    @NSManaged var atGroupcreatedUnixTime: Double
    @NSManaged var atGroupIsDeleteByCreator: Bool
    
}

public class DiscoverReport: AVObject, AVSubclassing {
    
    public static func parseClassName() -> String {
        return "DiscoverReport"
    }
    
    @NSManaged var feedID: String
    @NSManaged var userID: String
    @NSManaged var messageID: String
    @NSManaged var typeString: String
}

public class DiscoverHotKeyword: AVObject, AVSubclassing {
    
    public static func parseClassName() -> String {
        return "DiscoverHotKeyword"
    }
    
    @NSManaged var keyword: String
}

public class DiscoverCubeCategory: AVObject, AVSubclassing {
    
    public static func parseClassName() -> String {
        return "DiscoverCubeCategory"
    }
    @NSManaged var categoryString: String
}

public class DiscoverFeedback: AVObject, AVSubclassing {
    public static func parseClassName() -> String {
        return "DiscoverFeedback"
    }
    
    @NSManaged var deviceInfo: String
    @NSManaged var body: String
    @NSManaged var creator: AVUser
}

public class DiscoverFormula: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverFormula"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var name: String
    
    @NSManaged var nickName: String
    
    @NSManaged var imageName: String
    
    var localImage: UIImage?
    
    @NSManaged var imageURL: String
    
    @NSManaged var isLibrary: Bool
    
    @NSManaged var serialNumber: Int
    
    @NSManaged var rating: Int
    
    @NSManaged var favorate: Bool
    
    @NSManaged var creator: AVUser?
    
    @NSManaged var contents: [DiscoverContent]
    
    @NSManaged var category: String
    
    @NSManaged var type: String
    
    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var isFeedAttachment: Bool
    
}

public class DiscoverMessage: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverMessage"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var mediaType: Int
    @NSManaged var textContent: String
    
    @NSManaged var attachmentURLString: String
    @NSManaged var thumbnailURLString: String
    @NSManaged var localAttachmentName: String
    @NSManaged var localThumbnailName: String
    
    @NSManaged var attachmentID: String
    @NSManaged var attachmentExpiresUnixTime: TimeInterval

    @NSManaged var hidden: Bool
    @NSManaged var deletedByCreator: Bool
    @NSManaged var blockedByRecipient: Bool
    
    @NSManaged var creator: AVUser
    
    @NSManaged var recipientType: String
    @NSManaged var recipientID: String

    @NSManaged var metaData: NSData
    @NSManaged var metaDataInfo: String

}

public protocol OpenGraphInfoType {
    
    var URL: URL { get }
    
    var siteName: String { get }
    var title: String { get }
    var infoDescription: String { get }
    var thumbnailImageURLString: String { get }
}

public struct ImageAttachment {
    
    public let metadata: String?
    public let URLString: String
    
    public var image: UIImage?
    
    public var isTemporary: Bool {
        return image != nil
    }
    
    public init(metadata: String?, URLString: String, image: UIImage?) {
        self.metadata = metadata
        self.image = image
        self.URLString = URLString
    }
    
    public var thumbnailImageData: Data? {
        guard let metadata = metadata else {
            return nil
        }
        
        if let data = metadata.data(using: String.Encoding.utf8, allowLossyConversion:  false) {
            if  let result = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)), let metaDataInfo = result as? [String: Any] {
                
                if let thumbnailString = metaDataInfo[Config.MetaData.blurredThumbnailString] as? String {
                    let imageData = Data(base64Encoded: thumbnailString)
                    return imageData
                }
            }
        }
        return nil
    }
    
    public var thumbnailImage: UIImage? {
        
        if let imageData = thumbnailImageData {
            let image = UIImage(data: imageData as Data)
            return image
        }
        return nil
    }
    
}

open class DiscoverFeed: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverFeed"
    }
    
    @NSManaged var localObjectID: String
    @NSManaged var allowComment: Bool
    @NSManaged var creator: AVUser?
    @NSManaged var messagesCount: Int
//    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var body: String
    @NSManaged var categoryString: String
    
    var category: FeedCategory {
        if let category = FeedCategory(rawValue: categoryString) {
            return category
        }
        return FeedCategory.text
    }
    
    @NSManaged var deleted: Bool
    @NSManaged var withFormula: DiscoverFormula?

    @NSManaged var highlightedKeywordsBody: String
 
    public struct OpenGraphInfo: OpenGraphInfoType {
        
        public let URL: URL
        
        public let siteName: String
        public let title: String
        public let infoDescription: String
        public let thumbnailImageURLString: String
    }
    
    public enum Attachment {
        case images([ImageAttachment])
        case audio(AudioInfo)
        case location(LocationInfo)
        case URL(OpenGraphInfo)
        case formula(DiscoverFormula)
    }
    
    @NSManaged var attachmentsInfo: NSDictionary
    
    func parseAttachmentsInfo() {
        
        if let info = attachmentsInfo as? [String: [String]] ,let urls: [String] = info["urls"] {
            
            var attachments: [ImageAttachment] = []
            urls.forEach { URL in
                let attachment = ImageAttachment(metadata: nil, URLString: URL, image: nil)
                attachments.append(attachment)
            }
           
            self.attachment = .images(attachments)
        }
        
        if let info = attachmentsInfo as? [String: String] {
            
            if
                let URLString = info["url"] ,
                let URL = URL(string: URLString),
                let siteName = info["siteName"] ,
                let title = info["title"] ,
                let infoDescription = info["description"] ,
                let thumbnailImageURLString = info["image_url"]  {
                
                let openGraph = OpenGraphInfo(URL: URL, siteName: siteName, title: title, infoDescription: infoDescription, thumbnailImageURLString: thumbnailImageURLString)
                
                self.attachment = .URL(openGraph)
                
            }
        }
        
        if let formula = withFormula {
            self.attachment = .formula(formula)
        }
    }
    
    public var attachment: Attachment? = nil
        
    public var imageAttachments: [ImageAttachment]? {
        
        if let attachment = attachment {
            
            switch attachment {
            case .images(let attachments):
                return attachments
            default:
                return nil
            }
        }
        return nil
    }
    
    public var imageAttachmentsCount: Int {
        return imageAttachments?.count ?? 0
    }

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var distance: Double
    
    @NSManaged var groupID: String
    @NSManaged var recommended: Bool
    
    public var uploadingErrorMessage: String? = nil
    
    public var timeString: String {
        return createdAt?.timeAgo ?? ""
    }
    
    public var timeAndDistanceString: String {
        var distanceString: String?
        
        if distance < 1 {
            distanceString = "附近"
        } else {
            distanceString = ""
        }
        
        if let distanceString = distanceString {
            return timeString + "  .  " + distanceString
        } else {
            return timeString
        }
    }
    
    public var hasMapImage: Bool {
        
        if let category = FeedCategory(rawValue: categoryString) {
            
            switch category {
            case .location:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    public struct AudioInfo {
        public let feedID: String
        public let URLString: String
        public let metaData: NSData
        public let duration: TimeInterval
        public let sampleValues: [CGFloat]
    }
    
    public struct LocationInfo {
        public let name: String
        public let latitude: CLLocationDegrees
        public let longitude: CLLocationDegrees
        
        public var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

extension DiscoverFeed {

    var hasAttachments: Bool {
        return category != .text
    }
    
    var openGraphInfo: OpenGraphInfoType? {

        if let attachment = self.attachment {
            if case let .URL(openGraphInfo) = attachment {
                return openGraphInfo
            }
        }
        return nil
    }
    
    var formulaInfo: DiscoverFormula? {
        
        if let attachment = self.attachment {
            if case let .formula(discoverFormula) = attachment {
                return discoverFormula
            }
        }
        return nil
    }
}

open class DiscoverContent: AVObject, AVSubclassing {
    public class func parseClassName() -> String {
        return "DiscoverContent"
    }
    
    @NSManaged var localObjectID: String
    @NSManaged var text: String
    @NSManaged var rotation: String
    @NSManaged var indicatorImageName: String
    @NSManaged var atFormulaLocalObjectID: String
    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var creator: AVUser
    
}

public class DiscoverPreferences: AVObject, AVSubclassing {
    public class func parseClassName() -> String {
        return "DiscoverPreferences"
    }
    @NSManaged var version: String
}
