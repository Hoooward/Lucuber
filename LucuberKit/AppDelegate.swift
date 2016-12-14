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
        CustomMessage.registerSubclass()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        // 注意会重复添加数据
//        pushBaseFormulaDataToLeanCloud()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
        
        
        return true
        
    }
    
    func changeRootViewController() {
        window?.rootViewController = determineRootViewController()
    }
    
    private func determineRootViewController() -> UIViewController {
        
        let storyboardName = AVUser.isLogin ? "Main1" : "Resgin"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    




}



