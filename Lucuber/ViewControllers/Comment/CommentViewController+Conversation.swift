//
// Created by Tychooo on 16/12/14.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift
import AVOSCloudIM

// 1.创建新的 Feed 时, 才创建新的 Conversation

extension CommentViewController {
    
    func creatConversation() {
        let currenUser = AVUser.current()!
        
        let client = AVIMClient.init(clientId: currenUser.objectId!)
        
        client.open { success , error in
            
            if error != nil {
                defaultFailureHandler(Reason.network(error), "开启聊天失败")
            }
            
            client.createConversation(withName: "Formula_ss", clientIds: [], callback: { conversation, error in
                
                printLog(conversation)
            })
            
        }
        
    }
}
