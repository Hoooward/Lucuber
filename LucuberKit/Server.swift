//
//  Server.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud

public func loginAdmin() {
    
    AVUser.logInWithUsername(inBackground: "admain", password: "h1Y2775852", block: { user, error in
        
        if let user = user  {
            printLog("当前已登录管理员账户, id: \(user.objectId)")
        }
        
        if error != nil {
            printLog(error)
        }
        
    })
    
}


public func validateMobile(mobile: String,
                    checkType: LoginType,
                    failureHandler: ((NSError?) -> Void)?,
                    completion: (() -> Void)?) {



    let query = AVQuery(className: "_User")
    query.whereKey("mobilePhoneNumber", equalTo: mobile)

    query.findObjectsInBackground {

        users, error in

        switch checkType {

        case .register:

            if error == nil {

                if let findUsers = users {

                    // 有找个一个存在的用户
                    if let user = findUsers.first as? AVUser,
                       let _ = user.nickname() {

                        // 账户已经注册。且有昵称
                        let error = NSError(domain: "", code: Config.ErrorCode.registered, userInfo: nil)
                        failureHandler?(error)

                    } else {
                        completion?()

                    }

                } else {
                    completion?()
                }

            } else {

                failureHandler?(error as? NSError)
            }


        case .login:

            if error == nil {

                if let finUserss = users {

                    if
                        let user = finUserss.first as? AVUser,
                        let _ = user.nickname() {

                        completion?()

                    } else {

                        failureHandler?(error as? NSError)
                    }
                }

            } else {

                 failureHandler?(error as? NSError)

            }
        }

    }

}
