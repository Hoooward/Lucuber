//
//  CommentViewController+Views.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift


extension CommentViewController {
    
    func tryShowSubscribeView() {
        
        guard let group = conversation.withGroup else {
            return
        }
        
//        guard userNotificationStateIsAuthorized() else {
//            printLog("用户尚未开启通知, 暂时无法接受消息")
//            return
//        }
        
        // 仅显示一次
        guard SubscribeViewShown.canShow(groupID: group.groupID) else {
            return
        }
        
        subscribeView.subscribeAction = { [weak self] in
            
            subscribeConversationWithGroupID(group.groupID, failureHandler:{ reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
            }, completion: {
                
                printLog("订阅成功 id: \(group.groupID)")
                
                printLog("before isIncludeMe = \(group.includeMe)")
                
                if let strongSelf = self {
                    try? strongSelf.realm.write {
                        group.includeMe = true
                    }
                }
            })
        }
        
        subscribeView.showWithChangeAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let bottom = strongSelf.view.bounds.height - strongSelf.messageToolbar.frame.origin.y + SubscribeView.totalHeight
            
            let extraPart = strongSelf.commentCollectionView.contentSize.height - (strongSelf.messageToolbar.frame.origin.y - SubscribeView.totalHeight)
            
            let newContentOffsetY: CGFloat
            
            if extraPart > 0 {
                newContentOffsetY = strongSelf.commentCollectionView.contentOffset.y + SubscribeView.totalHeight
            } else {
                newContentOffsetY = strongSelf.commentCollectionView.contentOffset.y
            }
            
            strongSelf.tryUpdateCommentCollectionViewWith(newContentInsetbottom: bottom, newContentOffsetY: newContentOffsetY)
            
            strongSelf.isSubscribeViewShowing = true
        }
        
        subscribeView.hidWithChangeAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let bottom = strongSelf.view.bounds.height - strongSelf.messageToolbar.frame.origin.y
            
            let newContentOffsetY = strongSelf.commentCollectionView.contentSize.height - strongSelf.messageToolbar.frame.origin.y
            
            self?.tryUpdateCommentCollectionViewWith(newContentInsetbottom: bottom, newContentOffsetY: newContentOffsetY)
            
            self?.isSubscribeViewShowing = false
            
        }
        
        delay(3) { [weak self] in
            
            self?.subscribeView.show()
            // 在 Realm 中保存已经展示过的记录
            
            guard  self != nil else {
                return
            }
            
            guard  let realm = try? Realm() else {
                return
            }
            
            let shown = SubscribeViewShown(groupID: group.groupID)
            try? realm.write {
                realm.add(shown, update: true)
            }
            
        }
        
    }
    
    func makeHeaderView(with formula: Formula?) {
        guard let formula = formula else {
            return
        }
        
        let headerView = CommentHeaderView.creatCommentHeaderViewFormNib()
        headerView.formula = formula
        
        headerView.changeStatusAction = {
            [weak self] status in
            
            switch status {
            case .small:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 60 + 20
                    }, completion: nil)
                
            case .big:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 120 + 20
                    }, completion: nil)
                
                if let messageToolbar = self?.messageToolbar {
                    
                    if !messageToolbar.state.isAtBottom {
                        messageToolbar.state = .normal
                    }
                }
            }
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let views: [String: AnyObject] = [
            "headerView": headerView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", options: [], metrics: nil, views: views)
        
        let top = NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 64)
        
        let height = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate([top, height])
        
        headerView.heightConstraint = height
        
        self.headerView = headerView
        
    }
    
    
    
}
