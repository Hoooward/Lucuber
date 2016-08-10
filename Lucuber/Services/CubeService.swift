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
            return query
            
        case .Library:
            let query = AVQuery(className: Formula.parseClassName())
            query.whereKey("isLibraryFormula", equalTo: NSNumber(bool: true))
            query.addAscendingOrder("serialNumber")
            return query
        }
    }
    
}

public enum UploadFormulaMode {
    case My
    case Library
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
            
            //直接请求所有的公式, 不区分类型或种类, 因为要更新 Realm
            let query = AVQuery.getFormula(uploadingFormulaMode)
            query.limit = 1000
            
            query.findObjectsInBackgroundWithBlock { (formulas, error) in
                
                if error != nil {
                    
                    failureHandler?(error)
                }
                
                if let formulas = formulas as? [Formula] {
                    
                    UserDefaults.setNeedUpdateLibrary(false)
                    
                    if let user = AVUser.currentUser() {
                    
                        user.setNeedUpdateLibrary(false)
                        user.saveInBackgroundWithBlock({ (sessuce, error) in
                            print("更新用户成功")
                        })
                    }
                    
                    saveUploadFormulasInRealm(formulas)
                 
                    /// 将 Result 过滤一下, 只使用符合 category 的 formula
                    completion?(formulas.filter{$0.category == category})
                    
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
        let result =  getFormulsFormRealmWithMode(uploadingFormulaMode, category: category)
        if result.isEmpty { task() }
        
    case .Library:
        
        task()
        
    }

    
}

internal func fetchCategoryMenuList() -> [Category] {
    
    let query = AVQuery(className: "categoryMenu")
    
    let result = query.findObjects() as! [AVObject]
    
    
    var categorys = [Category]()
    
    result.forEach {
        if let string = $0.valueForKey("categoryString") as? String,
            let category = Category(rawValue: string){
            categorys.append(category)
        }
    }
    
    return categorys
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
                
//                print("newFeeds.count = \(newFeeds.count)")
                completion?(newFeeds)
            }
        }
    }
    
}






























