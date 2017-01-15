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
import LucuberTimer


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    enum RemoteNotificationType: String {
        case message = "message"
		case bunchMessages = "bunchMessages"
        case officialMessage = "official_message"
        case friendRequest = "friend_request"
        case messageDeleted = "message_deleted"
    }
    
    private var remoteNotificationType: RemoteNotificationType? {
        willSet {
//            if let type = newValue {
//                switch type {
//                    
//                case .Message, .OfficialMessage:
//                    lauchStyle.value = .Message
//                    
//                default:
//                    break
//                }
//            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        AVOSCloud.setAllLogsEnabled(false)

        AVOSCloud.setApplicationId("SpFbe0lY0xU6TV6GgnCCLWP7-gzGzoHsz", clientKey: "rMx2fpwx245YMLuWrGstWYbt")
        
        DiscoverFormula.registerSubclass()
        DiscoverContent.registerSubclass()
        DiscoverPreferences.registerSubclass()
        DiscoverMessage.registerSubclass()
        DiscoverFeed.registerSubclass()
        DiscoverCubeCategory.registerSubclass()
        DiscoverFeedback.registerSubclass()
        
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = determineRootViewController()
        window?.makeKeyAndVisible()
        
         customAppearce()
        //pushCubeCategory()
        
        /// 注册通知, 在注册完成时切换控制器。
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.changeRootViewController), name: Notification.Name.changeRootViewControllerNotification, object: nil)
   

        _ = creatMeInRealm()

        if AVUser.isLogin {

            if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? UILocalNotification, let userInfo = notification.userInfo, let type = userInfo["type"] as? String {
                remoteNotificationType = RemoteNotificationType(rawValue: type)
            }
        }

        return true
    }


	private var isFirstLaunch: Bool = true
    func applicationDidBecomeActive(_ application: UIApplication) {

        printLog("进入前台")


		if !isFirstLaunch {
            fetchUnreadMessages() {}


        } else {

			// TODO: - 第一次 Launch 可以做一些需要加载的数据

			// 同步我订阅的 Feed ,获取最新的 Conversation 信息


        }

        application.applicationIconBadgeNumber = -1

        NotificationCenter.default.post(name: Notification.Name.applicationDidBecomeActiveNotification, object: nil)
		isFirstLaunch = false
    }

    func applicationWillResignActive(_ application: UIApplication) {

        printLog("即将进入后台")

        UIApplication.shared.applicationIconBadgeNumber = 0

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        printLog("进入后台")

        // TODO -: 发送保存草稿的通知

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
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard AVUser.isLogin, let type = userInfo["type"] as? String, let remoteNotificationType = RemoteNotificationType(rawValue: type) else {
            completionHandler(.noData)
            return
            
        }
        printLog("收到通知")
        
        defer {
            if application.applicationState != .active {
                self.remoteNotificationType = remoteNotificationType
            }
        }
        
        switch remoteNotificationType {
            
        case .message:
            
            if let messageId = userInfo["messageID"] as? String {

				fetchMessageWithMessageLcID(messageId, failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                }, completion: { messageIds in
                    printLog("下载通知的 Message 完成")
                    tryPostNewMessageReceivedNotification(withMessageIDs: messageIds, messageAge: .new)
					completionHandler(.newData)
                })
            }

            break
        default:
            break
        }
    }

    private func fetchUnreadMessages(_ action: @escaping () -> Void) {

        guard AVUser.isLogin else {
            action()
            return
        }

        fetchUnreadMessage(failureHandler: {
            reason, errorMessage in
            defaultFailureHandler(reason, errorMessage)
        }, completion: { newMessageIds in
            tryPostNewMessageReceivedNotification(withMessageIDs: newMessageIds, messageAge: .new)

            action()
        })
    }
    
    
    func unregisterThirdPartyPush() {
        // TODO: 还不确定是不需要删除当前的 AVInstallation
        DispatchQueue.main.async {
            self.clearNotification()
        }
    }

    fileprivate func clearNotification() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.cancelAllLocalNotifications()
    }

    fileprivate func customAppearce() {
        
        window?.backgroundColor = UIColor.white
        
        // Global Tint Color
        
        window?.tintColor = UIColor.cubeTintColor()
        window?.tintAdjustmentMode = .normal
        
        // NavigationBar Item Style
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.cubeTintColor()], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.cubeTintColor().withAlphaComponent(0.3)], for: .disabled)
        
        // NavigationBar Title Style
        
        let shadow: NSShadow = {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.lightGray
            shadow.shadowOffset = CGSize(width: 0, height: 0)
            return shadow
        }()
        let textAttributes: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.navgationBarTitle(),
            NSShadowAttributeName: shadow,
            NSFontAttributeName: UIFont.navigationBarTitle()
        ]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
//        UINavigationBar.appearance().barTintColor = UIColor.white
        
        // TabBar
        
        UITabBar.appearance().tintColor = UIColor.cubeTintColor()
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
}


































