//
//  CommentViewController+FetchMessage.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

extension CommentViewController {
    
    func tryFetchMessages() {
        
        let fetchMessages: (_ failedAction: (() -> Void)?, _ successAction: (() -> Void)?) -> Void = { [weak self] failedAction, successAction in
            
            guard let recipientID = self?.conversation.recipiendID else {
                return
            }
            
            let predicate = NSPredicate(format: "sendState == %d" , MessageSendState.successed.rawValue)
            var lastMessage: Message?
            if let maxMessage = self?.messages.filter(predicate).sorted(byProperty: "createdUnixTime", ascending: true).last {
                lastMessage = maxMessage
            }
            
            // TODO: - 未来这里可能需要在一个独立的线程做
            fetchMessage(withRecipientID: recipientID, messageAge: .new, lastMessage: lastMessage, firstMessage: nil, failureHandler: {
                reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)
                
                failedAction?()
                
            }, completion: { newMessageID in
                
                tryPostNewMessageReceivedNotification(withMessageIDs: newMessageID, messageAge: .new)
                
                successAction?()
            })
            
        }
        
        guard let conversationType = ConversationType(rawValue: conversation.type) else {
            return
        }
        
        switch conversationType {
            
        case .oneToOne:
            
            // TODO: - 未来添加1对1对话时需要考虑标记已读
            fetchMessages(nil, nil)
            
        case .group:
            
            fetchMessages(nil, nil)
        }
    }
}


