//
//  AppDelegate.swift
//  LucuberKit
//
//  Created by Tychooo on 16/11/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud



fileprivate let dataVersionKey = "dateVersioKey"

extension UserDefaults {

    class func setDataVersion(_ version: String) {
        standard.set(version, forKey: dataVersionKey)
    }
    
    class func dataVersion() -> String {
        return standard.string(forKey: dataVersionKey) ?? "0.9"
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AVOSCloud.setAllLogsEnabled(false)
        DiscoverFormula.registerSubclass()
        DiscoverContent.registerSubclass()
        DiscoverPreferences.registerSubclass()
        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        // 注意会重复添加数据
//        pushFormulaDataToLeanCloud()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        
       
        
        return true
        
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let currentVersion = UserDefaults.dataVersion()
        
        syncPreferences(completion: {
            version in
            
            if currentVersion != version {
                
                printLog("需要更新数据")
            }
            
        }, failureHandler: { error in printLog(error) })
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)]:\(message)")
    #endif
}

