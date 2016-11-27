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






























