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
    
}


public enum UploadFeedMode {
    case Top
    case LoadMore
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
                
                completion?(newFeeds)
            }
        }
    }
    
}




























