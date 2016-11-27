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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let realm = try? Realm() else {
            return 
        }
        printLog(realm)
        printLog(realm)
        printLog(realm)
        printLog(realm)
        printLog(realm)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        sendImageMessage()
    }
    
    
    func sendImageMessage() {
        
        let image = UIImage(named: "Rubik's_cube")!
        let imageData = UIImageJPEGRepresentation(image, 0.95)
//        
//        pushMessageImage(atPath: nil, orFileData: imageData, metaData: nil, toRecipient: "test", recipientType: "group", afterCreatedMessage: { message in
//            printLog(message)
//        }, failureHandler: { error in
//            printLog(error)
//        }, completion: { success in
//            printLog(success)
//        })
    }

}







