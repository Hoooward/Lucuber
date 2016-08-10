//
//  AppDelegate.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
 
        
        Formula.registerSubclass()
        FormulaComment.registerSubclass()
        Feed.registerSubclass()
        
        
        
        /// 如果已经登录,就去获取是否需要更新公式的bool值
        /// 因为 getObjectInBackgroundWithId 是并发的, 应用程序一启动如果第一个视图是 Formula
        /// 的话会第一时间使用 NeedUpdateLibrary 属性进行 Formula 数据加载. 即使在 LeanCloud 中 将
        /// 值设为 ture 后的第一次启动, NeedUpdateLibrary 的值还是 false. 第二次启动才会更新 Libray.
        if let user = AVUser.currentUser()  {
            
            // 如果已经更新后的UserDefault为真, 不用做任何事情.
            if !UserDefaults.needUpdateLibrary() {
                
                let query = AVQuery(className: "_User")
                
                query.getObjectInBackgroundWithId(user.objectId) {
                    result, error in
                    
                    if error == nil {
                        let need = result.objectForKey("needUpdateLibrary") as! Bool
                        print("launch = \(need)")
                        UserDefaults.setNeedUpdateLibrary(need)
                    }
                    
                }
            }
           
        } else {
            // 如果没有登录, 直接设置为 true
            UserDefaults.setNeedUpdateLibrary(true)
        }
       
         
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        print(path)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print(#function)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

