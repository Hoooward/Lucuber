//
//  ViewController.swift
//  LucuberKit
//
//  Created by Tychooo on 16/11/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud


class ViewController: UIViewController {
    
    var formulas = [Formula]() {
        didSet {
            
            test(formulas: formulas)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

       
//        AVUser.loginAdministrator()
//        syncPreferences()
//        syncFormula(with: .library, categoty: .x3x3, completion: {
//            
//            newFormulas in
//            
//            self.formulas = newFormulas
//            
//        }, failureHandler: nil)
//        
       
    }

}


func test(formulas: [Formula]) {
    
    guard let realm = try? Realm() else {
        return
    }
    
//    if let currentUser =  currentUser(in: realm) {
//        
//        pushToLeancloud(with: currentUser.masterList.map {
//            $0.localObjectID
//        }, completion: nil, failureHandler: nil)
//    }
    
    for index in 0..<20 {
        let formula = formulas[index]
        try? realm.write {
//            appendMaster(with: formula, inRealm: realm)
        }
    }
    
    let user = currentUser(in: realm)
    
    printLog(user?.masterList)
}






fileprivate let nicknameKey = "nickname"
fileprivate let avatorImageURLKey = "avatorImageURL"
fileprivate let localObjectIDKey = "localObjectID"
fileprivate let masterListKey = "masterList"
fileprivate let introdctionKey = "introduction"

extension AVUser {
    
    func setIntroduction(_ string: String) {
        setObject(string, forKey: introdctionKey)
    }
    
    func introduction() -> String? {
        return object(forKey: introdctionKey) as? String
    }
    
    func localObjectID() -> String? {
        return object(forKey: localObjectIDKey) as? String
    }
    
    func setLocalObjcetID(_ userID: String) {
        setObject(userID, forKey: localObjectIDKey)
    }
    
    func nickname() -> String? {
        return object(forKey: nicknameKey) as? String
    }
    
    func avatorImageURL() -> String? {
        return object(forKey: avatorImageURLKey) as? String
    }
    
    func setNickname(_ nikeName: String) {
        setObject(nikeName, forKey: nicknameKey)
    }
    
    func setAvatorImageURL(_ imageUrl: String) {
        setObject(imageUrl, forKey: avatorImageURLKey)
    }
    
    
    func masterList() -> [String]? {
        return object(forKey: masterListKey) as? [String]
    }
    
    func setMasterList(_ list: [String]) {
        setObject(list, forKey: masterListKey)
    }
    
}
