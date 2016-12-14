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
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    enum RemoteNotificationType: String {
        case message = "message"
        case officialMessage = "official_message"
        case friendRequest = "friend_request"
        case messageDeleted = "message_deleted"
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 配置 Realm
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        /// 所有请求是否 Log
        AVOSCloud.setAllLogsEnabled(false)

        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        
        DiscoverFormula.registerSubclass()
        DiscoverContent.registerSubclass()
        DiscoverPreferences.registerSubclass()
        DiscoverMessage.registerSubclass()
        DiscoverFeed.registerSubclass()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        
        _ = creatMeInRealm()
        
       
       
        
        
        AVPush.setProductionMode(false)
        let push = AVPush()
        push.setMessage("啊啊啊")
       // [AVPush setProductionMode:NO];
        
        push.sendInBackground()
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
        
        if AVUser.isLogin {
            registerForRemoteNotification()
        }
        
        return storyboard.instantiateInitialViewController()!
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
       
//        pushCurrentUserUpdateInformation()
    }
    
    // 在用户 登录/注册 成功后才申请通知权限
    func registerForRemoteNotification() {

        if #available(iOS 10, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            
            //notificationCenter.delegate = self
        
            notificationCenter.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge, UNAuthorizationOptions.sound], completionHandler: {
                success, error in
                
                UIApplication.shared.registerForRemoteNotifications()
            })
            
            notificationCenter.getNotificationSettings(completionHandler: {
                setting in
                
                if setting.authorizationStatus == UNAuthorizationStatus.authorized {
                    printLog("授权成功")
                }
                
            })
        }
        
        // TODO: - iOS 10 以下的版本
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = AVInstallation.current()
        installation.setDeviceTokenFrom(deviceToken)
        installation.setObject(AVUser.current(), forKey: "creator")
        installation.saveInBackground()
        
    }
    
    
    
    
}


































