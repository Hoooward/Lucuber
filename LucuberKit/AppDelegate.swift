//
//  AppDelegate.swift
//  LucuberKit
//
//  Created by Tychooo on 16/11/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        AVOSCloud.setAllLogsEnabled(false)
        
        DiscoverFormula.registerSubclass()
        DiscoverContent.registerSubclass()
        DiscoverPreferences.registerSubclass()
        DiscoverMessage.registerSubclass()
        
        // 注意会重复添加数据
//        pushFormulaDataToLeanCloud()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        
        return true
        
    }
    
    


    func applicationDidBecomeActive(_ application: UIApplication) {
        
//        let currentVersion = UserDefaults.dataVersion()
//        
//        syncPreferences(completion: {
//            version in
//            
//            if currentVersion != version {
//                
//                printLog("需要更新数据")
//            }
//            
//        }, failureHandler: { error in printLog(error) })
//        
    }


}



