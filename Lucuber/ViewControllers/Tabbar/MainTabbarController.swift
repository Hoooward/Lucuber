//
//  MainTabbarController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit



class MainTabbarController: UITabBarController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.cubeTintColor()
        
//        print(AVUser.currentUser())
        
        
//        AVOSCloud.requestSmsCodeWithPhoneNumber("18500800404") { (succeeded, error) in
//            
//        }
//        
//        do {
//            try AVUser.signUpOrLoginWithMobilePhoneNumber("18500800404", smsCode: "350877")
//            
//        } catch  {
//            print(error)
//        }
        
//        print(AVUser.currentUser())
        
//        let testObject: AVObject = AVObject(className: "TestObject")
//        testObject["foor"] = "Bar"
//        testObject.save()
//        creatJSON()
//
//        let Path = NSBundle.mainBundle().pathForResource("Formulas", ofType: ".json")
//        let data = NSData(contentsOfFile: Path!)
//        let file = AVFile(name: "Formulas.json", data: data)
//        file.save()
//
//        var formulas = [Formula]()
//        FormulaManager.shardManager().loadNewFormulas {
//            formulas = FormulaManager.shardManager().PLLs
//            let item = formulas.first!
//            let formula: AVObject = AVObject(className: "Formulas")
//            formula.setObject(item.name, forKey: "name")
//            formula.setObject(item.formulaText, forKey: "texts")
//            formula.setObject(item.level, forKey: "level")
//            formula.setObject(item.imageName, forKey: "imageName")
//            formula.setObject(item.favorate, forKey: "favotate")
//            formula.setObject(item.category.rawValue, forKey: "category")
//            formula.setObject(item.type.rawValue, forKey: "type")
//            formula.setObject(AVUser.currentUser(), forKey: "user")
//            
//            formula.saveInBackground()
//        }
//        
////        
//        let q: AVQuery = AVQuery.init(className: "Formulas")
//        print(AVUser.currentUser().objectId)
//        q.whereKey("user", equalTo: AVUser.currentUser())
//        q.findObjectsInBackgroundWithBlock { (object, error) in
//            print(object)
//        }
//
        
        
        
        
        
        
        
    }
}
