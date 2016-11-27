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
   
    discoverMessage.localObjectID = Message.randomLocalObjectID()
    
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






























