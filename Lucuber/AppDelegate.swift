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

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /// 所有请求是否 Log
        AVOSCloud.setAllLogsEnabled(false)

        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        
        Formula.registerSubclass()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.updateFormulasLibrary), name: Notification.Name.updateFormulasLibraryNotification, object: nil)
        
       
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
//        if let currentUser = AVUser.current() {
//            printLog("currentUser = \(AVUser.current())")
//            printLog("userNickName: \(AVUser.current().getUserNickName())")
//            printLog("userAvatarURL: = \(AVUser.current().getUserAvatarImageUrl())")
//            
//            
//        } else {
//            printLog("尚未登录")
//        }
        
//       logout()
        
        return true
    }

    
    func updateFormulasLibrary() {
        
        CubeAlert.confirmOrCancel(title: "更新提示", message: " 目前「公式库」中的部分数据有所更新。", confirmTitle: "现在更新", cancelTitles: "取消", inViewController: window?.rootViewController, confirmAction: {
            
            printLog("正在更新")
            CubeHUD.showActivityIndicator()
            
            let query = AVQuery.getFormula(mode: .library)
            
            query?.findObjectsInBackground { formulas, error in
                
                if let formulas = formulas as? [Formula] {
                    
                    
                    if let user = AVUser.current() {
                        
                        user.setNeedUpdateLibrary(need: false)
                        user.saveEventually { successed, error in
                            
                            if successed {
                                printLog("更新 currentUser 的 needUploadLibrary 属性为 false")
                                
                            } else {
                                printLog("更新 currentUser 的 needUploadLibrary 属性失败")
                            }
                        }
                    }
                    
                    deleteLibraryFormalsRContentAtRealm()
                    
                    saveUploadFormulasAtRealm(formulas: formulas, mode: .library, isCreatNewFormula: false)
                    
                    CubeHUD.hideActivityIndicator()
                }
                
            }
   
            }, cancelAction: {
                
                printLog("不更新")
                
        })
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


































