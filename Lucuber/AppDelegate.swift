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
        
        
        // 1 判断是否登录
        
        if let currentUser = AVUser.current() {
            
            if let avatarURL = currentUser.getUserAvatarImageUrl(),
                let nickName = currentUser.getUserNickName() {
                
                // 进入 Main
                
                let storyboard = UIStoryboard(name: "Main" , bundle: nil)
                
                let vc = storyboard.instantiateInitialViewController()
                
                
            } else {
            
                // 进入 Main ， 进入设置选项卡， 设置头像。
            }
            
        } else {
            
            // 进入 Register
        }
        
     
        
        
        initializeWhetherNeedUploadLibraryFormulas()
        
        
        
        // TODO: 测试登陆账户
        if let user = AVUser.current() {
            
            printLog("当前登录账户:\(user.username)")
            
        } else {
            
            AVUser.logIn(withUsername: "12345", password: "12345")
        }

        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        printLog(path)
        
        return true
    }



}

