//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import UserNotifications

// MARK: - Report

public enum ReportReason {
    
    case porno
    case advertising
    case scams
    case other(String)
    
    var type: Int {
        switch self {
        case .porno:
            return 0
        case .advertising:
            return 1
        case .scams:
            return 2
        case .other:
            return 3
        }
    }
    
    var describe: String {
        switch self {
        case .porno:
            return "色情"
        case .advertising:
            return "广告"
        case .scams:
            return "诈骗"
        case .other:
            return "其他"
        }
    }
}

public func reportFeedWithFeedID(_ feedID: String, forReason reason: ReportReason, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {
    
    let discoverReport = DiscoverReport()
    discoverReport.feedID = feedID
    
    var typeString = ""
    
    switch reason {
    case .porno, .advertising, .scams:
        typeString = reason.describe
        
    case .other(let content):
        typeString = content
    }
    
    discoverReport.typeString = typeString
    
    discoverReport.saveInBackground({ success, error in
        
        if error != nil {
           failureHandler(Reason.network(error), "上传举报信息失败")
        }
        
        if success {
            completion()
        }
    })
}

// MARK: - Message
public func deleteMessageFromServer(messageID: String, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {


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

// MARK: - APNs
public func userNotificationStateIsAuthorized() -> Bool {
    
    var isAuthorized = false
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

public func updateMySubscribeInfoAndPushToLeancloud(with group: Group, failureHandler: @escaping FailureHandler, completion: (() -> Void)?) {
    
    let oldincludeMe: Bool = group.includeMe
    let subscribeFeedID = group.groupID
    
    var newSubscribeList = [String]()
    if let oldMySubscribeList = AVUser.current()?.subscribeList() {
        newSubscribeList = oldMySubscribeList
    }
    
    if !oldincludeMe {
        if newSubscribeList.contains(subscribeFeedID) {
            
        } else {
            newSubscribeList.append(subscribeFeedID)
        }
    } else {
        if newSubscribeList.contains(subscribeFeedID) {
            if let index = newSubscribeList.index(of: subscribeFeedID) {
                newSubscribeList.remove(at: index)
            }
        } else {
            
        }
    }
    
    pushMySubscribeListToLeancloud(with: newSubscribeList, failureHandler: failureHandler, completion: completion)
}



public func subscribeConversationWithGroupID(_ groupID: String, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {
    
    
    let currentInstallation = AVInstallation.current()
    currentInstallation.addUniqueObject(groupID, forKey: "channels")
    
    currentInstallation.saveInBackground { success, error in
        
        if error != nil {
            failureHandler(Reason.network(error), "开启话题通知失败,请检查网络连接")
        }
        
        if success {
            printLog("订阅成功")
            completion()
        }
    }
}

public func unSubscribeConversationWithGroupID(_ groupID: String, failureHandler: @escaping FailureHandler, completion: @escaping () -> Void) {
    
    
    let currentInstallation = AVInstallation.current()
    
    if let oldChannles = currentInstallation.channels as? [String] {
        
        var newChannles = oldChannles
        if newChannles.contains(groupID) {
            if let index = newChannles.index(of: groupID) {
                newChannles.remove(at: index)
            }
            currentInstallation.channels = newChannles
            currentInstallation.saveInBackground { success, error in
                
                if error != nil {
                    currentInstallation.channels = oldChannles
                    failureHandler(Reason.network(error), "关闭话题通知失败,请检查网络连接")
                }
                
                if success {
                    printLog("订阅取消成功")
                    completion()
                }
                
            }
        }
        
    }
}



