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

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /// 所有请求是否 Log
        AVOSCloud.setAllLogsEnabled(false)

        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        
        Formula.registerSubclass()
        DiscoverMessage.registerSubclass()
//        FormulaComment.registerSubclass()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.updateFormulasLibrary), name: Notification.Name.updateFormulasLibraryNotification, object: nil)
        
       
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        
//       logout()
        
        
        
        return true
    }

    
    var updateFormulaAlertItShow = false
    
    let alertWindow = UIWindow()
    func updateFormulasLibrary() {
        
        if !updateFormulaAlertItShow {
            
            updateFormulaAlertItShow = true
            
            CubeAlert.confirmOrCancel(title: "更新提示", message: " 目前「公式库」中的部分数据有所更新。", confirmTitle: "现在更新", cancelTitles: "取消", inViewController: window?.rootViewController, confirmAction: {
                
                
                self.updateFormulaAlertItShow = false
                
                HUD.show(.label("正在更新公式库..."))
                
                fetchLibraryFormulaFormLeanCloudAndSaveToRealm(completion: {
                    
                    self.updateFormulaAlertItShow = false
                    
                    HUD.flash(.label("更新成功"), delay: 2)
                    
                    NotificationCenter.default.post(name: Notification.Name.needReloadFormulaFromRealmNotification, object: nil)
                    
                    
                    }, failureHandler: { _ in
                        
                        HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 2) { _ in
                        }
                        
                        // 如果更新失败暂时不管。
                        
                })
                
                
                }, cancelAction: {
                    
                    self.updateFormulaAlertItShow = false
                    printLog("不更新")
                    
            })
        }
        
        
    }

    
    func changeRootViewController() {
        window?.rootViewController = determineRootViewController()
    }

    
    private func determineRootViewController() -> UIViewController {
        
        let storyboardName = self.isLogin ? "Main" : "Resgin"
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        return storyboard.instantiateInitialViewController()!
    }
    

    private var isLogin: Bool {
        
        get {
            
            if let currentUser = AVUser.current(),
                let _ =  currentUser.getUserAvatarImageUrl(),
                let _ = currentUser.getUserNickName() {
                return true
            }
            return false
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
         updateCurrentUserInfo()
    }
}


































