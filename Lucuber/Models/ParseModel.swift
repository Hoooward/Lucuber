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
   
    
    if let userID = message.creator?.lcObjcetID {
        
        let avUser = AVUser(objectId: userID)
        discoverMessage.creator = avUser
    }
    
    discoverMessage.localObjectID = message.localObjectID
    
    discoverMessage.mediaType = message.mediaType
    discoverMessage.textContent = message.textContent
 
    discoverMessage.attachmentURLString = message.attachmentURLString
    discoverMessage.thumbnailURLString = message.thumbnailURLString
//    discoverMessage.localAttachmentName = message.localAttachmentName
//    discoverMessage.localThumbnailName = message.localThumbnailName
    
    
    if let metaData = message.mediaMetaData {
        discoverMessage.metaData = metaData.data as NSData
    }
    discoverMessage.attachmentID = message.attachmentID
    discoverMessage.attachmentExpiresUnixTime = message.attachmentExpiresUnixTime
    
    discoverMessage.hidden = message.hidden
    discoverMessage.deletedByCreator = message.deletedByCreator
    discoverMessage.blockedByRecipient = message.blockedByRecipient
    
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
    
    if  newFormula.lcObjectID != "" {
        newDiscoverFormula = DiscoverFormula(className: "DiscoverFormula", objectId: newFormula.lcObjectID)
    }
    
    let acl = AVACL()
    acl.setPublicReadAccess(true)
    acl.setWriteAccess(true, for: currentUser)
    
    newDiscoverFormula.acl = acl
    
    newDiscoverFormula.localObjectID = newFormula.localObjectID
    newDiscoverFormula.name = newFormula.name
    newDiscoverFormula.imageName = newFormula.imageName
    newDiscoverFormula.localImage = newFormula.pickedLocalImage
    
    var discoverContents: [DiscoverContent] = []
    
    for content in newFormula.totalContents {
        
        var newDiscoverContent = DiscoverContent()
        
        if content.lcObjectID != "" {
           newDiscoverContent = DiscoverContent(className: "DiscoverContent", objectId: content.lcObjectID)
        }
        
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





























