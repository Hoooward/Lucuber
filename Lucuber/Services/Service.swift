//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import UserNotifications

// MARK: - User
public func fetchMyInfoAndDoFutherAction(_ action: (() -> Void)?) {
    
    guard let realm = try? Realm() else {
        return
    }
    if let meID = AVUser.current()?.objectId {
        
        let query = AVQuery(className: "_User")
        query.whereKey("objectId", equalTo: meID)
        
        query.findObjectsInBackground {
            users, error in
            
            if error != nil {
                printLog("更新本地当前用户失败")
                action?()
            }
            
            if let user = users?.first as? AVUser {
                
                try? realm.write {
                    _ = getOrCreatRUserWith(user, inRealm: realm)
                }
                
                NotificationCenter.default.post(name: Config.NotificationName.newMyInfo, object: nil)
                
                action?()
            }
        }
    }
}

// MARK: - Formula
public func fetchMyFormulasAndDoFutherAction(_ action: (() -> Void)?) {
    
    fetchDiscoverFormula(with: .my, categoty: nil, failureHandler: { reason, errorMessage in
        defaultFailureHandler(reason, errorMessage)
        action?()
    }, completion: { _ in
        
        UserDefaults.setIsSyncedMyFormulas(true)
        NotificationCenter.default.post(name: Config.NotificationName.updateMyFormulas, object: nil)
        action?()
    })
}

// MARK: - Score
public func fetchMyScoresAndFutherAction(_ action: (()-> Void)?) {
    
    fetchDiscoverScores(failureHandler: { reason, errorMessage in
        defaultFailureHandler(reason, errorMessage)
        action?()
    }, completion: {
        
        UserDefaults.setIsSyncedMyScores(true)
        NotificationCenter.default.post(name: Config.NotificationName.updateMyScores, object: nil)
        action?()
    })
    
}

public func fetchNeedUpdateLibraryFormulasAndDoFutherAction(_ action: (() -> Void)?) {
    let currentVersion = UserDefaults.dataVersion()
    
    fetchPreferences(failureHandler: {reason, errorMessage in
        defaultFailureHandler(reason, errorMessage)
        action?()
    }, completion: { newVersion in
        
        if currentVersion == newVersion {
            action?()
            return
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let viewController = appDelegate.window?.rootViewController {
            
            CubeAlert.confirmOrCancel(title: "公式库有更新", message: "是否需要现在更新? 不会消耗太多流量哦哦~", confirmTitle: "恩, 就是现在", cancelTitles: "取消", inViewController: viewController, confirmAction: {
                
                updateLibraryDate(failureHandeler: {
                    reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                    
                }, completion: {
                    
                    UserDefaults.setDataVersion(newVersion)
                    NotificationCenter.default.post(name: Config.NotificationName.updateLibraryFormulas, object: nil)
                    
                })
                
            }, cancelAction: {
                
            })
        }
        
        action?()
    })
}

public func pushNewFormulaAndScoreToLeancloudAndFutherAction(_ action: (() -> Void)?) {
    
    guard let realm = try? Realm() else {
        return
    }
    
    if let currentUser = currentUser(in: realm) {
        
        let updateMyInformationGroup = DispatchGroup()
        
        let list: [String] = currentUser.masterList.map({$0.formulaID})
        
        if !list.isEmpty {
            
            updateMyInformationGroup.enter()
            printLog("开始上传掌握公式列表")
            
            pushToMasterListLeancloud(with: list, completion: {
                updateMyInformationGroup.leave()
                printLog("上传掌握公式列表成功")
                
            }, failureHandler: { _, _ in
                printLog("上传掌握公式列表失败")
                updateMyInformationGroup.leave()
            })
        }
        
        let unPusheFormula = unPushedFormula(with: currentUser, inRealm: realm)
        
        if !unPusheFormula.isEmpty {
            
            for formula in unPusheFormula {
                
                updateMyInformationGroup.enter()
                printLog("开始上传需要更新的 Formula, 名称: \(formula.name)")
                
                pushFormulaToLeancloud(with: formula, failureHandler: {
                    _, _ in
                    printLog("上传需要更新的 Formula, 名称: \(formula.name) 失败")
                    updateMyInformationGroup.leave()
                    
                }, completion: {
                    _ in
                    
                    printLog("上传需要更新的 Formula, 名称: \(formula.name) 成功")
                    updateMyInformationGroup.leave()
                    
                    try? realm.write {
                        formula.isPushed = true
                        formula.contents.forEach { $0.isPushed = true }
                    }
                })
            }
        }
        
        let unPushedScore = unPushedScoreWithRUser(currentUser, inRealm: realm)
        
        if !unPushedScore.isEmpty {
            
            for score in unPushedScore {
                updateMyInformationGroup.enter()
                printLog("开始上传复原成绩 Score , 名称: \(score.timer)")
                
                pushMyScoreToLeancloud(with: score, failureHandler: {_, _ in
                    printLog("开始上传复原成绩 Score , 名称: \(score.timer) 失败")
                    updateMyInformationGroup.leave()
                }, completion: { discoverScore in
                    printLog("开始上传复原成绩 Score , 名称: \(score.timer) 成功")
                    updateMyInformationGroup.leave()
                    
                    try? realm.write {
                        score.lcObjectId = discoverScore.objectId ?? ""
                        score.isPushed = true
                    }
                })
            }
        }
        
        updateMyInformationGroup.notify(queue: DispatchQueue.main, execute: {
            printLog("上传所有新数据 Formula & Score 完成")
            action?()
        })
        
    } else {
        action?()
    }
}

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
