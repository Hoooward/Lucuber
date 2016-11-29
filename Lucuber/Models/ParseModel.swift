//
//  ParseModel.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

public struct ImageAttachment {
    //后面可以尝试将小头像以二进制序列方式存储
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
    
    public var thumbnailImageData: NSData? {
        guard (metadata?.characters.count)! > 0 else {
            return nil
        }
        
        //        if let data = metadata?.data(using: String.Encoding.utf8, allowLossyConversion:  false) {
        //            if  let metadataInfo = encodeJSON(data) {
        //                if let thumbnailString = metadataInfo["thumbnail"] as? String {
        //                    let imageData = NSData(base64EncodedString: thumbnailString, options: NSDataBase64DecodingOptions(rawValue: 0))
        //                    return imageData
        //                }
        //            }
        //        }
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


public func parseMessageToDisvocerModel(with message: Message) -> DiscoverMessage {
    
    let discoverMessage = DiscoverMessage()
   
    
    if let userID = message.creator?.lcObjcetID {
        
        let avUser = AVUser(objectId: userID)
        discoverMessage.creator = avUser
    }
    
    discoverMessage.localObjectID = message.localObjectID
    
    discoverMessage.mediaType = message.mediaType
    discoverMessage.textContent = message.textContent
 
    discoverMessage.attachmentURLString = message.attachmentURLString
    discoverMessage.thumbnailURLString = message.thumbnailURLString
    discoverMessage.localAttachmentName = message.localAttachmentName
    discoverMessage.localthumbnailName = message.localThumbnailName
    
    discoverMessage.attachmentID = message.attachmentID
    discoverMessage.attachmentExpiresUnixTime = message.attachmentExpiresUnixTime
    
    if let data = message.mediaMetaData?.data {
        discoverMessage.mediaMetaData = data
    }
    
    discoverMessage.hidden = message.hidden
    discoverMessage.deletedByCreator = message.deletedByCreator
    discoverMessage.bolckedByRecipient = message.blockedByRecipient
    
    // TODO: - 暂时不将 Conversatioon 的数据上传到服务器, 仅本地构建.
    // discvoerMessage.conversation  .
    
    discoverMessage.recipientID = message.recipientID
    discoverMessage.recipientType = message.recipientType
    
    return discoverMessage
}

public func parseFormulaToDisvocerModel(with newFormula: Formula) -> DiscoverFormula? {
    
    guard let currentUser = AVUser.current() else {
        return nil
    }
    
    var newDiscoverFormula = DiscoverFormula()
    
    if let leancloudObjectID = newFormula.lcObjectID {
        newDiscoverFormula = DiscoverFormula(className: "DiscoverFormula", objectId: leancloudObjectID)
    }
    
    let acl = AVACL()
    acl.setPublicReadAccess(true)
    acl.setWriteAccess(true, for: currentUser)
    
    newDiscoverFormula.acl = acl
    
    newDiscoverFormula.localObjectID = newFormula.localObjectID
    newDiscoverFormula.name = newFormula.name
    newDiscoverFormula.imageName = newFormula.imageName
    
    var discoverContents: [DiscoverContent] = []
    
    for content in newFormula.contents {
        
        let newDiscoverContent = DiscoverContent()
        newDiscoverContent.localObjectID = content.localObjectID
        newDiscoverContent.creator = currentUser
        newDiscoverContent.atFormulaLocalObjectID = content.atFomurlaLocalObjectID
        newDiscoverContent.rotation = content.rotation
        newDiscoverContent.text = content.text
        newDiscoverContent.indicatorImageName = content.indicatorImageName
        newDiscoverContent.deletedByCreator = content.deleteByCreator
        
        discoverContents.append(newDiscoverContent)
    }
    
    newDiscoverFormula.contents = discoverContents
    
    newDiscoverFormula.favorate = newFormula.favorate
    newDiscoverFormula.category = newFormula.categoryString
    newDiscoverFormula.type = newFormula.typeString
    newDiscoverFormula.creator = currentUser
    newDiscoverFormula.deletedByCreator = newFormula.deletedByCreator
    newDiscoverFormula.rating = newFormula.rating
    newDiscoverFormula.isLibrary = newFormula.isLibrary
    
    return newDiscoverFormula
}





























