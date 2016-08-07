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
            return query
            
        case .Library:
            let query = AVQuery(className: Formula.parseClassName())
            query.addAscendingOrder("name")
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

internal func fetchFormulaWithMode(uploadingFormulaMode: UploadFormulaMode, completion: (([Formula]) -> Void)?, failureHandler: ((NSError) -> Void)? ) {
    
    
    let query = AVQuery.getFormula(uploadingFormulaMode)
    // LeanCloud 限定最多返回1000条
    query.limit = 1000
    
    
    query.findObjectsInBackgroundWithBlock { (formulas, error) in
        
        if error != nil {
            
            failureHandler?(error)
        }
        
        if let formulas = formulas as? [Formula] {
            completion?(formulas)
            
        }
        
        
        
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
                
//                print("newFeeds.count = \(newFeeds.count)")
                completion?(newFeeds)
            }
        }
    }
    
}






























