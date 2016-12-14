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
import Alamofire


class ViewController: UIViewController {

    @IBAction func logout(_ sender: Any) {
        service.fetchMessage(with: "5850f7c4128fe1006d92d29d", messageAge: .new)
        service.sendMessage(text: "就是这个掉")
    }
    var service = ConversationService.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        

//        let feedID = "Feed_test222"
//        service.creatNewConversation(with: feedID, failureHandler: {
//        _, _ in
//        }, completion: { conversation in
//
//            printLog(conversation)
//            self.service.sendMessage(text: "啊啊啊")
//
//        })
        service.tryOpenClientConnect(failureHandler: nil, completion: nil)
        
        let headers: HTTPHeaders = [
             "X-LC-Id" : "TdCadXfMYfAxjnLYPOam8hdx-gzGzoHsz",
             "X-LC-Key" : "dEUXdKAJJFjyki7jVT6pzQ2c,master",
            "Content-Type" : "application/json"
        ]
        
        let prarmeters: [String: Any] = [
            "convid": "5850f7c4128fe1006d92d29d",
            "msgid" : "odkbJsSCTXCLjdm_DgDO2A",
        ]
        
        let url = URL(string: "https://leancloud.cn/1.1/rtm/messages/logs")!

        
        Alamofire.upload(multipartFormData: { (data) in
            
            data.append("1481705278585".data(using: String.Encoding.utf8)!, withName: "timestamp")
            data.append("5850f7c4128fe1006d92d29d".data(using: String.Encoding.utf8)!, withName: "convid")
            data.append("odkbJsSCTXCLjdm_DgDO2A".data(using: String.Encoding.utf8)!, withName: "msgid")
            
            
        }, to:  URL(string: "https://leancloud.cn/1.1/rtm/messages/logs")!,  method: .delete, headers: headers, encodingCompletion: {
            response in
            
            printLog(response)
        })
        

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







