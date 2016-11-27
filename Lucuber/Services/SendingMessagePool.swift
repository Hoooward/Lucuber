//
//  SendingMessagePool.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class SendingMessagePool {
    
    private static var shared = SendingMessagePool()
    
    var cacheMessageID = Set<String>()
    public class func containsMessage(with messageID: String) -> Bool {
        return shared.cacheMessageID.contains(messageID)
    }
    
    public class func addMessage(with messageID: String) {
        shared.cacheMessageID.insert(messageID)
    }
    
    public class func removeMessage(with messageID: String) {
        shared.cacheMessageID.remove(messageID)
    }
    
}
