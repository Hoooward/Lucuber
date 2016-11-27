//
//  DiscoverModel.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud

public class DiscoverFormula: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverFormula"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var name: String
    
    @NSManaged var nickName: String
    
    @NSManaged var imageName: String
    
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
    @NSManaged var localthumbnailName: String
    
    @NSManaged var attachmentID: String
    @NSManaged var attachmentExpiresUnixTime: TimeInterval
    
    @NSManaged var mediaMetaData: Data
    
    @NSManaged var hidden: Bool
    @NSManaged var deletedByCreator: Bool
    @NSManaged var bolckedByRecipient: Bool
    
    @NSManaged var creator: AVUser
    
    @NSManaged var recipientType: String
    
    @NSManaged var recipientID: String
    
    
   
    
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
