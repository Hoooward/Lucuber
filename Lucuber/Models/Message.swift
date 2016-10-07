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

class Message: AVObject, AVSubclassing {
    
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



























