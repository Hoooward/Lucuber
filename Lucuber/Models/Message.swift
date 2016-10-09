//
//  Message.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud

enum MessageMediaType: Int, CustomStringConvertible {
    
    case text  = 0
    case Image = 1
    
    var description: String {
        
        switch self {
        case .text:
            return "text"
        case .Image :
            return "image"
        }
    }
    
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

public class Message: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "Message"
    }
    
    @NSManaged var textContent: String
    
    @NSManaged var creatUser: AVUser
    
    @NSManaged var compositedName: String
    
    @NSManaged var invalidated: Bool
    
//    var sendState: MessageSendState = .notSend
    var sendState: Int = MessageSendState.notSend.rawValue
    
   
    
    
    
}

public func imageMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
    
    guard !message.invalidated else {
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


























