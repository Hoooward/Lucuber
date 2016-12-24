//
//  Model.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

let defaultScoreGroupLocalObjectId: String = "defaultScoreGroup"

open class Score: Object {
    
    open dynamic var timertext: String = ""
    open dynamic var localObjectId: String = ""
    open dynamic var isPop: Bool = false
    open dynamic var isDeleteByCreator: Bool = false
    open dynamic var atGroup: ScoreGroup?
    open dynamic var createdUnixTime: TimeInterval = Date().timeIntervalSince1970
    
}

open class ScoreGroup: Object {
    
    open dynamic var lcObjectId: String = ""
    open dynamic var localObjectId: String = ""
    
    //open let timerList = List<Score>()
    open let timerList = LinkingObjects(fromType: Score.self, property: "atGroup")
    
    
}

// MARK: - Group

public func scoreGroupWith(_ localObjectId: String, inRealm realm: Realm) -> ScoreGroup? {
    let predicate = NSPredicate(format: "localObjectId = %@", localObjectId)
    return realm.objects(ScoreGroup.self).filter(predicate).first
}

public func getOrCreatDefaultScoreGroup() -> ScoreGroup {
    
    guard let realm = try? Realm() else {
        fatalError()
    }
    
    if let defaultGroup = scoreGroupWith(defaultScoreGroupLocalObjectId, inRealm: realm) {
        return defaultGroup
        
    } else {
        
        realm.beginWrite()
        let newGroup = ScoreGroup()
        newGroup.localObjectId = defaultScoreGroupLocalObjectId
        realm.add(newGroup)
        try? realm.commitWrite()
        
        return newGroup
    }
}
