//
//  CubeService.swift
//  Lucuber
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.

import Foundation
import AVOSCloud
import RealmSwift


public enum UploadFeedMode {
    case top
    case loadMore
}

extension AVQuery {
    
     enum DefaultKey: String {
        case updatedTime = "updatedAt"
        case creatTime = "createdAt"
    }
    
    class func getFormula(mode: UploadFormulaMode) -> AVQuery {
        
        switch mode {
            
        case .my:
            
            let query = AVQuery(className: DiscoverFormula.parseClassName())
            query.addAscendingOrder("name")
            query.whereKey("creator", equalTo: AVUser.current()!)
            
            query.limit = 1000
            return query
            
        case .library:
            
            let query = AVQuery(className: DiscoverFormula.parseClassName())
            query.whereKey("isLibrary", equalTo: NSNumber(booleanLiteral: true))
            query.addAscendingOrder("serialNumber")
            query.limit = 1000
            return query
            
        }
    }
    
 
    
}

func fetchFormulaWithMode(uploadingFormulaMode: UploadFormulaMode,
                                 category: Category,
                                 completion: (([Formula]) -> Void)?,
                                 failureHandler: ((NSError?) -> Void)?) {
    
    switch uploadingFormulaMode {
        
    case .my :
        
        let query = AVQuery.getFormula(mode: uploadingFormulaMode)
        
        printLog("-> 开始获取我的公式")
        query.findObjectsInBackground { formulas, error in
            
            if error != nil {
                
                failureHandler?(error as? NSError)
                let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
//                completion?(result)
                printLog("更新我的公式失败， 使用 Realm 中的我的公式")
 
            }
            
            if let formulas = formulas as? [Formula] {
                
                /// 将 Result 过滤一下, 只使用符合 category 的 formula
                completion?(formulas.filter{ $0.category == category })
                
                /// 删除 Library 中 Formula 对应的 content
                deleteMyFormulasRContentAtRealm()
                
                /// 更新数据库中的 Formula
//                saveUploadFormulasAtRealm(formulas: formulas, mode: uploadingFormulaMode, isCreatNewFormula: false)
                
                printLog("-> 成功更新我的公式")
                
            }
        }
        
    case .library:
        
        // 公式库, 如果Realm中没有数据, 则尝试从网络加载, 否则不需要从网络加载
        let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
        
        if result.isEmpty {
            
            
            failureHandler?(nil)
            NotificationCenter.default.post(name: Notification.Name.updateFormulasLibraryNotification, object: nil)
            
        } else {
            
//            completion?(result)
        }
        
    }

}


//public func fetchLibraryFormulaFormLeanCloudAndSaveToRealm(completion: (() -> Void)?, failureHandler: ((NSError) -> Void)?) {
//    
//    
//    let query = AVQuery.getFormula(mode: .library)
//    
//    query.findObjectsInBackground { formulas, error in
//        
//        if error != nil {
//            
//            failureHandler?(error as! NSError)
//        }
//        
//        if let formulas = formulas as? [Formula] {
//            
//            if let user = AVUser.current() {
//                
//                user.setNeedUpdateLibrary(need: false)
//                user.saveEventually { successed, error in
//                    
//                    if successed {
//                        printLog("更新 currentUser 的 needUploadLibrary 属性为 false")
//                        
//                    } else {
//                        printLog("更新 currentUser 的 needUploadLibrary 属性失败")
//                    }
//                }
//            }
//            
//            deleteLibraryFormalsRContentAtRealm()
//            
////            saveUploadFormulasAtRealm(formulas: formulas, mode: .library, isCreatNewFormula: false)
//            
//            completion?()
//            
//        }
//    }
//    
//}


//internal func saveNewFormulaToRealmAndPushToLeanCloud(newFormula: Formula,
//                                                      completion: (() -> Void)?,
//                                                      failureHandler: ((NSError) -> Void)? ) {
//    
//    if let user = AVUser.current() {
//        
//        newFormula.creatUser = user
//        newFormula.creatUserID = user.objectId!
//        
//        let acl = AVACL()
//        acl.setPublicReadAccess(true)
//        acl.setWriteAccess(true, for: AVUser.current()!)
//        newFormula.acl = acl
//        
//        
//        newFormula.saveEventually({ (success, error) in
//            if error  == nil {
//                printLog("新公式保存到 LeanCloud 成功")
//            } else {
//                printLog("新公式保存到 LeanCloud 失败")
//            }
//        })
//        
//        saveUploadFormulasAtRealm(formulas: [newFormula], mode: nil, isCreatNewFormula: true)
//        
//        
//        completion?()
//        
//        
//    } else {
//        
//        let error = NSError(domain: "没有登录用户", code: 0, userInfo: nil)
//        failureHandler?(error)
//    }
//    
//    
//    
//}

// MARK: - Login

func validateMobile(mobile: String,
                    checkType: LoginType,
                    failureHandler: ((NSError?) -> Void)?,
                    completion: (() -> Void)?) {
    
    
    
    let query = AVQuery(className: "_User")
    query.whereKey("mobilePhoneNumber", equalTo: mobile)
    
    query.findObjectsInBackground {
        
        users, error in
        
        switch checkType {
            
        case .register:
            
            if error == nil {
                
                if let findUsers = users {
                    
                    // 有找个一个存在的用户
                    if let user = findUsers.first as? AVUser,
                       let _ = user.nickname() {
                        
                        // 账户已经注册。且有昵称
                        let error = NSError(domain: "", code: Config.ErrorCode.registered, userInfo: nil)
                        failureHandler?(error)
                        
                    } else {
                        completion?()
                        
                    }
                    
                } else {
                    completion?()
                }
                
            } else {
               
                failureHandler?(error as? NSError)
            }
            
            
        case .login:
            
            if error == nil {
                
                if let finUserss = users {
                    
                    if
                        let user = finUserss.first as? AVUser,
                        let _ = user.nickname() {
                        
                        completion?()
                        
                    } else {
                       
                        failureHandler?(error as? NSError)
                    }
                }
                
            } else {
                
                 failureHandler?(error as? NSError)
                
            }
        }

    }
    
}

/// 如果已经登录,就去获取是否需要更新公式的bool值
/// 因为 getObjectInBackgroundWithId 是并发的, 应用程序一启动如果第一个视图是 Formula
/// 的话会第一时间使用 NeedUpdateLibrary 属性进行 Formula 数据加载. 即使在 LeanCloud 中 将
/// 值设为 ture 后的第一次启动, NeedUpdateLibrary 的值还是 false. 第二次启动才会更新 Libray.

public func updateCurrentUserInfo() {
    
    
    if let user = AVUser.current() {
        
        user.fetchInBackground { user, error in
            
            if let user = user as? AVUser {
                
                if user.object(forKey: "needUpdateLibrary") as! Bool {
                    
                    NotificationCenter.default.post(name: Notification.Name.updateFormulasLibraryNotification, object: nil)
                }
            }
            
                
        }
    }
    
}



/// 获取短信验证码
public func fetchMobileVerificationCode(phoneNumber: String,
                                        failureHandler: ((NSError) -> Void)?,
                                        completion: (() -> Void)? ) {
    
    AVOSCloud.requestSmsCode(withPhoneNumber: phoneNumber) { succeeded, error in
        
        if succeeded {
            
            completion?()
            
        } else {
            
            if let error = error as? NSError {
                
                failureHandler?(error)
                
            } else {
                
                let error = NSError(domain: "请求失败", code: 1100, userInfo: nil)
                
                failureHandler?(error)
            }
            
        }
    }
    
}


/// 注册登录
public func signUpOrLogin(withPhonerNumber phoneNumber: String,
                          smsCode: String,
                          failureHandler: ((NSError) -> Void)?,
                          completion: ((AVUser) -> Void)? ) {
    
    AVUser.signUpOrLoginWithMobilePhoneNumber(inBackground: phoneNumber, smsCode: smsCode) { user, error in
        
        
        if error == nil {
            
            printLog("登录成功")
            
            if let user = user {
                
                completion?(user)
                
            }
            
        } else {
            
            if let error = error as? NSError {
                
                failureHandler?(error)
                
            } else {
                
                let error = NSError(domain: "请求失败", code: 1111, userInfo: nil)
                failureHandler?(error)
            }
        }
        
    }
}



/// 上传头像
public func updateAvatar(withImageData imageData: Data,
                                      failureHandler: ((NSError?)->Void)?,
                                      completion: ((String) -> Void)? ) {
    
    let uploadFile = AVFile(data: imageData)
    
    uploadFile.saveInBackground({ succeeded, error in
        
        if succeeded {
            
            completion?(uploadFile.url!)
            
        } else {
            
            failureHandler?(error as NSError?)
        }
        
    })
    
}

/// 上传用户信息
public func updateUserInfo(nickName: String, avatarURL: String,
                                 failureHandler: ((NSError?)->Void)?,
                                 completion: (() -> Void)? ) {
    
    // TODO: - 如果保存失败， 如何处理
    if let currentUser = AVUser.current() {
        
        currentUser.setNickname(nickName)
        currentUser.setAvatorImageURL(avatarURL)
        currentUser.saveInBackground({ successed, error in
            
            if error != nil {
                
                failureHandler?(error as? NSError)
                
            } else {
                completion?()
            }
            
        })
        
    } else {
       
        let error = NSError(domain: "", code: 9999, userInfo: nil)
        
        failureHandler?(error)
        
    }
    
}


// Logout

public func logout() {
    
    AVUser.logOut()
    
//    NotificationCenter.default.post(Notification.Name.changeRootViewControllerNotification)
    
}



// Message



func convertToLeanCloudMessageAndSend(message: Message, failureHandler: (() -> Void)?, completion: ((Bool) -> Void)? ) {
    
    let discoverMessage = parseMessageToDisvocerModel(with: message)
    
    discoverMessage.saveInBackground {
        successed, error in
        
        if error != nil {
            // 标记发送失败
            guard let realm = try? Realm() else {
                failureHandler?()
                return
            }
            
            try? realm.write {
                message.sendStateInt = MessageSendState.failed.rawValue
            }
            
            failureHandler?()
            
        }
        
        if successed {
            printLog("发送成功")
            
            guard let realm = try? Realm() else {
                
                failureHandler?()
                return
            }
            
            try? realm.write {
                message.sendStateInt = MessageSendState.successed.rawValue
                message.messageID = leanCloudMessage.objectId!
            }
            
            completion?(successed)
        }
        
        // 通知 Cell 更改发送状态提示.
        NotificationCenter.default.post(name: Notification.Name.updateMessageStatesNotification, object: nil)
        
    }
    
}

// Feed

internal func fetchFeedWithCategory(category: FeedCategory,
                                    uploadingFeedMode: UploadFeedMode,
                                    lastFeedCreatDate: NSDate,
                                    completion: (([Feed]) -> Void)?,
                                    failureHandler: ((NSError) -> Void)? ) {
    
    let query = AVQuery(className: Feed.parseClassName())
    query.addDescendingOrder(AVQuery.DefaultKey.updatedTime.rawValue)
    query.limit = 10
    
    switch category {
        
    case .All:
        // Do Noting
        break
        
    case .Topic:
        // Do Noting
        break
        
    case .Formula:
        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Formula.rawValue)
        
    case .Record:
        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Record.rawValue)
        
    }
    
    switch uploadingFeedMode {
        
    case .top:
        // Do Noting
        break
        
    case .loadMore:
        query.whereKey(AVQuery.DefaultKey.creatTime.rawValue, lessThan: lastFeedCreatDate)
    }
    
    query.findObjectsInBackground { newFeeds, error in
        
        if error != nil {
            
            failureHandler?(error as! NSError)
            
        } else {
            
            if let newFeeds = newFeeds as? [Feed] {
                
                //                printLog("newFeeds.count = \(newFeeds.count)")
                completion?(newFeeds)
            }
        }
    }
    
}


















