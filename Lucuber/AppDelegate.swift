//
//  AppDelegate.swift

//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import Photos
import CoreTelephony
import PKHUD
import RealmSwift

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /// 所有请求是否 Log
        AVOSCloud.setAllLogsEnabled(false)

        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        
        DiscoverFormula.registerSubclass()
        DiscoverContent.registerSubclass()
        DiscoverPreferences.registerSubclass()
        DiscoverMessage.registerSubclass()
        
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        
        _ = creatMeInRealm()
        
        return true
    }

  
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func changeRootViewController() {
        window?.rootViewController = determineRootViewController()
    }
    
    private func determineRootViewController() -> UIViewController {
        
        let storyboardName = AVUser.isLogin ? "Main" : "Resgin"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    
  
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        guard let realm = try? Realm() else {
            return
        }
        
        if let currentUser = currentUser(in: realm) {
            
            let unPushedFormula = unPushedFormulaWith(currentUser: currentUser, inRealm: realm)
            
            
            if !unPushedFormula.isEmpty {
                
                for formula in unPushedFormula {
                    
                    pushFormulaToLeancloud(with: formula, failureHandler: {
                        reason, errorMessage in
                       
                        defaultFailureHandler(reason, errorMessage)
                        
                    }, completion: nil)
                    
                    
                }
            }
            
        }
    }

    
}


































