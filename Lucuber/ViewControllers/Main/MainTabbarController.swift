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
        
        let str = "(R U R' U) (R U' R' U') (R' F R F')"
        
        let pattern = "\\(.*?\\)"
        
        
        
        do {
            let a =  try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
//           let result = a.rangeOfFirstMatchInString(str, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: str.characters.count))
            let resu = a.matchesInString(str, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: str.characters.count))
            
            for s in resu {
                print(s.range)
                let stt = (str as NSString).substringWithRange(s.range)
                print(stt)
            }
            
            
        } catch{
            print(error)
        }
    
        
        
    }
}
