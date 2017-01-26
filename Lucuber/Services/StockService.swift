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
//import AVOSCloudIM
//
//class ConversationService: NSObject {
//    
//    static let shared: ConversationService = ConversationService()
//    
//    var currentConversation: AVIMConversation?
//    var isConnect: Bool = false
//    
//    var didReceiveTextMessageAction: (() -> Void)?
//    var didReceiveMediaMessageAction: (() -> Void)?
//    
//    lazy var currentUserClient: AVIMClient = {
//        let userID = AVUser.current()!.objectId!
//        let client = AVIMClient(clientId: userID)
//        client.delegate = self
//        client.messageQueryCacheEnabled = false
//        return client
//    }()
//    
//    func tryOpenClientConnect(failureHandler: FailureHandler?, completion: (() -> Void)?) {
//        
//        self.currentUserClient.open {success, error in
//            
//            if error != nil {
//                failureHandler?(Reason.network(error), "建立长链接失败")
//            }
//            
//            self.isConnect = success
//            
//            if success {
//                printLog("已经与服务器建立长链接")
//                completion?()
//            }
//        }
//    }
//    


//    func fetchMessage(with conversationID: String, messageAge: MessageAge) {
//        
//        let query = self.currentUserClient.conversationQuery()
//        
//        query.getConversationById(conversationID, callback: {
//            
//            conversation, error in
//            
//            self.currentConversation = conversation
//            conversation?.queryMessages(withLimit: 20, callback: {
//                messages, error in
//                
//                var messageIDs = [String]()
//                
//                if let messages = messages as? [AVIMMessage] {
//                    
//                    guard let realm = try? Realm() else {
//                        return
//                    }
//                    printLog("共获取到 **\(messages.count)** 个新 Messages")
//                    
//                    realm.beginWrite()
//                    
//                    messages.forEach { discoverMessage in
//                        
//                        guard let messageID = discoverMessage.messageId else {
//                            return
//                        }
//                        
//                        var message = messageWith(messageID, inRealm: realm)
//                        
//                        if message == nil {
//                            
//                            // 如果本地没有这个 Message , 创建一个新的
//                            let newMessage = Message()
//                            newMessage.lcObjectID = messageID
//                            //newMessage.textContent = discoverMessage.text ?? ""
//                            //newMessage.mediaType = Int(discoverMessage.mediaType)
//                            
//                            newMessage.sendState = MessageSendState.read.rawValue
//                            
//                            newMessage.createdUnixTime = TimeInterval( discoverMessage.sendTimestamp)
//                            if case .new = messageAge {
//                                if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
//                                    if newMessage.createdUnixTime < latestMessage.createdUnixTime {
//                                        // 只考虑最近的消息，过了可能混乱的时机就不再考虑
//                                        if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
//                                            printLog("xbefore newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                                            newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
//                                            printLog("xadjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            realm.add(newMessage)
//                            
//                            message = newMessage
//                        }
//                        
//                        if let message = message {
//                            
//                            let userID = discoverMessage.clientId
//                                
//                            printLog(conversation?.members)
//                            
//                        }
//                        
//                        
//                    }
//                    
//                }
//                
//                
//                printLog(messages)
//            })
//            
//        })
//    }
    
//    func creatNewConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
//        
//        self.currentUserClient.open { success, error in
//            
//            if error != nil {
//                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
//                return
//            }
//            
//            let attributes: [String: Any]? = nil
//            
//            self.currentUserClient.createConversation(withName: name, clientIds: [], attributes: attributes, options: AVIMConversationOption.init(rawValue: 0), callback: {
//                conversation, error in
//                
//                if error != nil {
//                    failureHandler(Reason.network(error), "创建新的 Conversation 失败")
//                    return
//                }
//                
//                if let conversation = conversation {
//                    self.currentConversation = conversation
//                    completion(conversation)
//                }
//                
//            })
//           
//        }
//    }
//    
//    func joinConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
//        
//        self.currentUserClient.open { success, error in
//            
//            if error != nil {
//                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
//                return
//            }
//            
//            let query = self.currentUserClient.conversationQuery()
//            
//            query .getConversationById(name, callback: {
//                conversation, error in
//                
//                if error != nil {
//                    failureHandler(Reason.network(error), "查找 Conversation 失败")
//                    return
//                }
//                
//                if let conversation = conversation {
//                    
//                    conversation.join { success, error in
//                        
//                        if error != nil {
//                            failureHandler(Reason.network(error), "加入 Conversation 失败")
//                            return
//                        }
//                        
//                        completion(conversation)
//                    }
//                }
//            })
//        }
//    }
//    
//    func quitConversation(with name: String, failureHandler: @escaping FailureHandler, completion: @escaping (AVIMConversation) -> Void) {
//        
//        self.currentUserClient.open { success, error in
//            
//            if error != nil {
//                failureHandler(Reason.network(error), "当前用户 Open Client 失败")
//                return
//            }
//            
//            let query = self.currentUserClient.conversationQuery()
//            
//            query .getConversationById(name, callback: {
//                conversation, error in
//                
//                if error != nil {
//                    failureHandler(Reason.network(error), "查找 Conversation 失败")
//                    return
//                }
//                
//                if let conversation = conversation {
//                    
//                    conversation.quit { success, error in
//                        
//                        if error != nil {
//                            failureHandler(Reason.network(error), "退出 Conversation 失败")
//                            return
//                        }
//                        
//                        completion(conversation)
//                        
//                    }
//                }
//            })
//        }
//    }
//    
//    public var receiveNewMessageAction: (() -> Void)?
//}
//
//extension ConversationService: AVIMClientDelegate {
//    
//    // 收到富文本信息
//    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
//        
//    }
//    
//    // 收到普通文字信息
//    func conversation(_ conversation: AVIMConversation, didReceiveCommonMessage message: AVIMMessage) {
//        
//        printLog(message)
//    }
//}
//
//













