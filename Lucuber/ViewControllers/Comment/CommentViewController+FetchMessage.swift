//
//  CommentViewController+FetchMessage.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

extension CommentViewController {

    func tryLoadPreviousMessage(completion: @escaping () -> Void) {

        if isLoadingPreviousMessages {
            return
        }

        isLoadingPreviousMessages = true

        printLog("准备加载旧Message")

        if displayedMessagesRange.location == 0 {

            printLog("从网络加载过去的 Message")


            if let recipiendID = self.conversation.recipiendID {
                var firstMessage: Message?
                if let minMessage = self.messages.first {
                    firstMessage = minMessage
                }

                fetchMessage(withRecipientID: recipiendID, messageAge: .old, lastMessage: nil, firstMessage: firstMessage, failureHandler: { [weak self] reason, errorMessage in

                    self?.isLoadingPreviousMessages = false
                    completion()
                    defaultFailureHandler(reason, errorMessage)

                }, completion: { [weak self] newMessageID in

                    tryPostNewMessageReceivedNotification(withMessageIDs: newMessageID, messageAge: .old)

                    self?.isLoadingPreviousMessages = false

                    if newMessageID.isEmpty {
                        self?.noMorePreviousMessage = true
                        printLog("网络上没有更旧的 Message")
                    } else {
                        printLog("从网络加载过去的 Message 成功.")
                    }
                    completion()
                })
            }

        } else {

            printLog("从本地 Realm 中加载过去的 Message")
            var newMessageCount = self.messagesBunchCount

            if displayedMessagesRange.location - newMessageCount < 0 {
                newMessageCount = displayedMessagesRange.location
            }

            if newMessageCount > 0 {

                self.displayedMessagesRange.location -= newMessageCount
                self.displayedMessagesRange.length += newMessageCount

                self.lastUpdateMessagesCount = self.messages.count

                var indexPaths = [IndexPath]()
                for i in 0 ..< newMessageCount {

                    let indexPath = IndexPath(item: i, section: Section.message.rawValue)
                    indexPaths.append(indexPath)
                }

                let bottomOffset = self.commentCollectionView.contentSize.height - self.commentCollectionView.contentOffset.y
//
//                printLog("当前的contentSize: \(self.commentCollectionView.contentSize)")
//                printLog("当前的ContentOffset: \(self.commentCollectionView.contentOffset)")
                CATransaction.begin()
                CATransaction.setDisableActions(true)

                self.commentCollectionView.performBatchUpdates({
                    [weak self] in
                    self?.commentCollectionView.insertItems(at: indexPaths)

                }, completion: {
                    [weak self] finished in
                    guard let strongSelf = self else {
                        return
                    }
//                        printLog("插入之后的contentSize: \(self?.commentCollectionView.contentSize)")
//                        printLog("插入之后的ContentOffset: \(self?.commentCollectionView.contentOffset)")
                    var contentOffset = strongSelf.commentCollectionView.contentOffset
                    contentOffset.y = strongSelf.commentCollectionView.contentSize.height - bottomOffset

                    strongSelf.commentCollectionView.setContentOffset(contentOffset, animated: false)

                    CATransaction.commit()

                    // 上面的 CATransaction 保证了 CollectionView 在插入后不闪动

                    self?.isLoadingPreviousMessages = false
                    completion()
                    printLog("从本地加载过去的 Message 成功.")
                })
            }
        }
    }

    
    func tryFetchMessages() {
        
        let fetchMessages: (_ failedAction: (() -> Void)?, _ successAction: (() -> Void)?) -> Void = { [weak self] failedAction, successAction in
            
            guard let strongSelf = self, let recipientID = self?.conversation.recipiendID, let me = currentUser(in: strongSelf.realm) else {
                return
            }
            
            let predicate = NSPredicate(format: "sendState == %d" , MessageSendState.successed.rawValue)
            var lastMessage: Message?
            if let messages: [Message]? = self?.messages.filter(predicate).filter({ $0.creator ?? RUser() != me }) {
                lastMessage = messages?.sorted(by: {
                    $0.createdUnixTime > $1.createdUnixTime
                }).first
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


