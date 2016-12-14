//
//  Server.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud
import AVOSCloudIM

public func loginAdmin() {
    
    AVUser.logInWithUsername(inBackground: "admain", password: "h1Y2775852", block: { user, error in
        
        if let user = user  {
            printLog("当前已登录管理员账户, id: \(user.objectId)")
        }
        
        if error != nil {
            printLog(error)
        }
        
    })
    
}

class CustomMessage: AVIMTypedMessage, AVIMTypedMessageSubclassing {
    
    public static func classMediaType() -> AVIMMessageMediaType {
        return kAVIMMessageMediaTypeNone
    }
    
    var deletedByCreator: Bool = false
    var disc: String = "dsasd"
    var creator: AVUser?
    
  
}



