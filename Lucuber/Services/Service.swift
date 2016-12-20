//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import UserNotifications

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

public func userNotificationStateIsAuthorized() -> Bool {
    
    var isAuthorized = false
//    
//    if let settings = UIApplication.shared.currentUserNotificationSettings {
//        
//        switch settings.types {
//        case UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound:
//            isAuthorized = true
//        default:
//            isAuthorized = false
//        }
//    }
//    
    // TODO: - 仅处理了 iOS10
    if #available(iOS 10.0, *) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings(completionHandler: {
            setting in
            
            if setting.authorizationStatus != .authorized {
                
                isAuthorized = false
                printLog("请在设置-隐私-中开启通知")
            } else {
                isAuthorized = true
                printLog("已经可以正常接受消息")
            }
        })
    }
    
    return isAuthorized
}

public func subscribeConversationWithGroupID(_ groupID: String, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {
    
    
    let currentInstallation = AVInstallation.current()
    currentInstallation.addUniqueObject(groupID, forKey: "channels")
    currentInstallation.saveInBackground { success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "订阅该频道失败")
        }
        
        if success {
            printLog("订阅成功")
            completion()
        }
    }
}

public func unSubscribeConversationWithGroupID(_ groupID: String, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {
    
    let currentInstallation = AVInstallation.current()
    
    if let channles = currentInstallation.channels as? [String] {
        
        var resultChannles = channles
        if channles.contains(groupID) {
            if let index = channles.index(of: groupID) {
                resultChannles.remove(at: index)
            }
            currentInstallation.channels = resultChannles
            currentInstallation.saveInBackground { success, error in
                
                if error != nil {
                    failureHandler(Reason.network(error), "取消订阅频道失败")
                }
                
                if success {
                    printLog("订阅取消成功")
                    completion()
                }
                
            }
        }
        
    }
}



