//
//  ViewController.swift
//  LucuberKit
//
//  Created by Tychooo on 16/11/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud


class ViewController: UIViewController {

//    @IBAction func logout(_ sender: Any) {
//        AVUser.logOut()
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Login
     
        // 测试 Realm 初始化
//        guard let realm = try? Realm() else {
//            return 
//        }
        
//        printLog("\(realm) 已经初始化成功")
        
//        sendeTextMessage()
//        sendImageMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func sendImageMessage() {
        
        let image = UIImage(named: "Howard")!
        let imageData = UIImageJPEGRepresentation(image, 0.95)
        
        pushMessageImage(atPath: nil, orFileData: imageData, metaData: nil, toRecipient: "test", recipientType: "group", afterCreatedMessage: { message in
            printLog("图片 Message 已经在本地创建完成, 准备 push")
            printLog(message)
        }, failureHandler: { error in
            printLog(error)
        }, completion: { success in
            printLog("图片 Message 推送成功")
        })
    }
    
    func sendeTextMessage() {
        
        pushMessageText("抱歉.", toRecipient: "test", recipientType: "group", afterCreatedMessage: {
            message in
            
            printLog("文子 Message 已经在本地创建完成, 准备 push")
            printLog(message)
            
        }, failureHandler: { error in
            printLog(error)
            
        }, completion: { success in
            printLog("文字 Message 推送成功")
        })
    }
    
    

}







