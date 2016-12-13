//
//  StockService.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/14.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift
import AVOSCloudIM

class ConversationService: NSObject {
    
    static let shared: ConversationService = ConversationService()
    
    lazy var currentUserClient: AVIMClient = {
        let userID = AVUser.current()!.objectId!
        let client = AVIMClient(clientId: userID)
        client.delegate = self
        client.messageQueryCacheEnabled = false
        return client
    }()
    
    func creatNewConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
        
        self.currentUserClient.open { success, error in
            
            if error != nil {
                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
                return
            }
            
            let attributes: [String: Any]? = nil
            
            self.currentUserClient.createConversation(withName: name, clientIds: [], attributes: attributes, options: AVIMConversationOption.init(rawValue: 0), callback: {
                conversation, error in
                
                if error != nil {
                    failureHandler(Reason.network(error), "创建新的 Conversation 失败")
                    return
                }
                
                if let conversation = conversation {
                    completion(conversation)
                }
                
            })
           
        }
    }
    
    func joinConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
        
        self.currentUserClient.open { success, error in
            
            if error != nil {
                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
                return
            }
            
            let query = self.currentUserClient.conversationQuery()
            
            query .getConversationById(name, callback: {
                conversation, error in
                
                if error != nil {
                    failureHandler(Reason.network(error), "查找 Conversation 失败")
                    return
                }
                
                if let conversation = conversation {
                    
                    conversation.join { success, error in
                        
                        if error != nil {
                            failureHandler(Reason.network(error), "加入 Conversation 失败")
                            return
                        }
                        
                        completion(conversation)
                    }
                }
            })
        }
    }
    
    func quitConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
        
        self.currentUserClient.open { success, error in
            
            if error != nil {
                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
                return
            }
            
            let query = self.currentUserClient.conversationQuery()
            
            query .getConversationById(name, callback: {
                conversation, error in
                
                if error != nil {
                    failureHandler(Reason.network(error), "查找 Conversation 失败")
                    return
                }
                
                if let conversation = conversation {
                    
                    conversation.quit { success, error in
                        
                        if error != nil {
                            failureHandler(Reason.network(error), "退出 Conversation 失败")
                            return
                        }
                        
                        completion(conversation)
                        
                    }
                }
            })
        }
    }
    
    public var receiveNewMessageAction: (() -> Void)?
}

extension ConversationService: AVIMClientDelegate {
    
    // 收到富文本信息
    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
        
    }
    
    // 收到普通文字信息
    func conversation(_ conversation: AVIMConversation, didReceiveCommonMessage message: AVIMMessage) {
        
    }
}















