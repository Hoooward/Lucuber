//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

// MARK: - Message

public func deleteMessageFromServer(message: Message, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {

    let messageID = message.lcObjectID

    guard !messageID.isEmpty else  {
        failureHandler(Reason.noData, "要删除的 MessageID 为空")
        return
    }

    let discoverMessage = DiscoverMessage(className: "DiscoverMessage", objectId: messageID)

    discoverMessage.setValue(true, forKey: "deletedByCreator")
    
    discoverMessage.saveInBackground {
        success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "删除 Message 失败")
        }
        if success {
            completion()
        }
    }
}



