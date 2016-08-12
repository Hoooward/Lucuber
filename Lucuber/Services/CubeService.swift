//
//  CubeService.swift
//  Lucuber
//
//  Created by Howard on 7/27/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation


extension AVQuery {
    
    enum DefaultKey: String {
        case UpdatedTime = "updatedAt"
        case CreatTime = "createdAt"
    }
    
    class var getFeeds: AVQuery {
        
        let query = AVQuery(className: Feed.parseClassName())
        query.addDescendingOrder(DefaultKey.UpdatedTime.rawValue)
        return query
        
    }
    
    class func getFormula(mode: UploadFormulaMode) -> AVQuery {
        
        switch mode {
        case .My:
            let query = AVQuery(className: Formula.parseClassName())
            query.addAscendingOrder("name")
            query.whereKey("creatUser", equalTo: AVUser.currentUser())
            query.limit = 1000
            return query
            
        case .Library:
            let query = AVQuery(className: Formula.parseClassName())
            query.whereKey("isLibraryFormula", equalTo: NSNumber(bool: true))
            query.addAscendingOrder("serialNumber")
            query.limit = 1000
            return query
        }
    }
    
}




public enum UploadFormulaMode: String {
    case My = "My"
    case Library = "Library"
}


public enum UploadFeedMode {
    case Top
    case LoadMore
}



internal func fetchFormulaWithMode(uploadingFormulaMode: UploadFormulaMode,
                                   category: Category,
                                   completion: (([Formula]) -> Void)?,
                                   failureHandler: ((NSError) -> Void)? ) {
    
    
    let task: (() -> Void) = {
        
        let needUpdate = UserDefaults.needUpdateLibrary()
        
        if needUpdate {
            
            let query = AVQuery.getFormula(uploadingFormulaMode)

            
            /// 直接请求所有的公式, 不区分类型或种类, 因为要更新 Realm
            query.findObjectsInBackgroundWithBlock { (formulas, error) in
                
                if error != nil {
                    
                    failureHandler?(error)
                }
                
                if let formulas = formulas as? [Formula] {
                    
                    /// 更新 needUpdateLibrary
                    UserDefaults.setNeedUpdateLibrary(false)
                    
                    if let user = AVUser.currentUser() {
                        
                        user.setNeedUpdateLibrary(false)
                        
                        user.saveInBackgroundWithBlock({ (sessuce, error) in
                            printLog("更新用户成功")
                        })
                    }
                    
                 
                    /// 将 Result 过滤一下, 只使用符合 category 的 formula
                    completion?(formulas.filter{$0.category == category})
                    
                    /// 删除 Library 中 Formula 对应的 content
                    deleteLibraryFormulasRContentAtRealm()
                    
                    /// 更新数据库中的 Formula
                    saveUploadFormulasAtRealm(formulas, mode: uploadingFormulaMode, isCreatNewFormula: false)
                   
                }
            }
            
        } else {
            
            let result = getFormulsFormRealmWithMode(uploadingFormulaMode, category: category)
            
            completion?(result)
            
        }

    }
    
    switch uploadingFormulaMode {
        
    case .My:
        
        // 我的公式, 如果Realm中没有数据, 则尝试从网络加载, 否则不需要从网络加载
        let result = getFormulsFormRealmWithMode(uploadingFormulaMode, category: category)
        
        result.isEmpty ? task() : completion?(result)

    case .Library:
        
        task()
        
    }

    
}


internal func fetchFeedWithCategory(category: FeedCategory,
                                     uploadingFeedMode: UploadFeedMode,
                                     lastFeedCreatDate: NSDate,
                                     completion: ([Feed] -> Void)?,
                                     failureHandler: ((NSError) -> Void)? ) {
    
    let query = AVQuery.getFeeds
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
        
    case .Top:
        // Do Noting
        break
        
    case .LoadMore:
        query.whereKey(AVQuery.DefaultKey.CreatTime.rawValue, lessThan: lastFeedCreatDate)
    }
    
    query.findObjectsInBackgroundWithBlock { newFeeds, error in
        
        if error != nil {
            
            failureHandler?(error)
            
        } else {
            
            if let newFeeds = newFeeds as? [Feed] {
                
//                printLog("newFeeds.count = \(newFeeds.count)")
                completion?(newFeeds)
            }
        }
    }
    
}


internal func saveNewFormulaToRealmAndPushToLeanCloud(newFormula: Formula,
                                                      completion: (() -> Void)?,
                                                      failureHandler: ((NSError) -> Void)? ) {
    
    
        if let user = AVUser.currentUser() {
            
            newFormula.creatUser = user
            newFormula.creatUserID = user.objectId
            
            let acl = AVACL()
            acl.setPublicReadAccess(true)
            acl.setWriteAccess(true, forUser: AVUser.currentUser())
            newFormula.ACL = acl
            
            
            newFormula.saveEventually({ (success, error) in
                if error  == nil {
                    printLog("新公式保存到 LeanCloud 成功")
                } else {
                    printLog("新公式保存到 LeanCloud 失败")
                }
            })
            
            saveUploadFormulasAtRealm([newFormula], mode: nil, isCreatNewFormula: true)
            
            completion?()
            
            
        } else {
            
            let error = NSError(domain: "没有登录用户", code: 0, userInfo: nil)
            failureHandler?(error)
        }
        
    
    
}



























