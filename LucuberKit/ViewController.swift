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








