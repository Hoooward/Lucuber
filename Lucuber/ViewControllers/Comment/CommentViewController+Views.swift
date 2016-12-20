//
//  CommentViewController+Views.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import UserNotifications


extension CommentViewController {
    
    func makeCommentMoreViewManager() -> CommentMoreViewManager {
        
        let manager = CommentMoreViewManager()
        
        manager.conversation = self.conversation
        
        manager.toggleSubscribeAction = { [weak self] switchOn in
            
            if switchOn {
                if #available(iOS 10.0, *) {
                    
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.getNotificationSettings(completionHandler: {
                        setting in
                        
                        DispatchQueue.main.async {
                            if setting.authorizationStatus != .authorized {
                                
                                manager.moreView.hideAndDo(afterHideAction: {
                                    CubeAlert.alertSorry(message: "您尚未开启 Lucuber 的推送权限, 请前往 设置-通知 中做修改.", inViewController: self)
                                })
                                
                            } else {
                                
                                if let group = self?.conversation.withGroup {
                                    
                                    subscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                                        defaultFailureHandler(reason, errorMessage)
                                        
                                    }, completion: {
                                        
                                        if let strongSelf = self {
                                            try? strongSelf.realm.write {
                                                group.includeMe = true
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
                
            } else {
                
                if let group = self?.conversation.withGroup {
                    
                    unSubscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                        
                    }, completion: {
                        
                        if let strongSelf = self {
                            try? strongSelf.realm.write {
                                group.includeMe = false
                            }
                        }
                    })
                }
            }
        }
        
        manager.reportAction = { [weak self] in
            // TODO: - 举报
        }
        
        return manager
    }
    
    func tryFoldHeaderView() {
        
        if let formulaHeaderView = formulaHeaderView {
            if formulaHeaderView.status == .big {
                formulaHeaderView.status = .small
            }
        }
        
        if let feedHeaderView = feedHeaderView {
            if feedHeaderView.foldProgress != 1.0 {
                feedHeaderView.foldProgress = 1.0
            }
        }
    }
    

    func makeFeedHeaderView(with feed: DiscoverFeed?) {

		guard let feed = feed else {
			return
		}

		let feedHeaderView = FeedHeaderView.instanceFromNib()

        feedHeaderView.feed = feed


		feedHeaderView.tapAvatarAction = { [weak self] in
			// TODO: - 点击头像
        }

        feedHeaderView.foldAction = { [weak self] in

            if let _ = self {

                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in

                    self?.commentCollectionView.contentInset.top = 64 + FeedHeaderView.foldHeight + 5

                }, completion: nil)
            }
        }

        feedHeaderView.unfoldAction = { [weak self] feedHeaderView in

            if let strongSelf = self {

                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in

                    self?.commentCollectionView.contentInset.top = 64 + feedHeaderView.normalHeight + 5

                }, completion: nil)

                if !strongSelf.messageToolbar.state.isAtBottom {
					strongSelf.messageToolbar.state = .normal
                }
            }
        }

        feedHeaderView.tapImagesAction = { [weak self] transitionViews, attachments, image, index in
            // TODO: - 执行 previewImage
        }

        feedHeaderView.tapUrlInfoAction = { [weak self] url in
            self?.cube_openURL(url)
        }

        feedHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedHeaderView)

        let views: [String: AnyObject] = [
            "feedHeaderView": feedHeaderView
        ]


        let constrainsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[feedHeaderView]|", options: [], metrics: nil, views: views)

		let top = NSLayoutConstraint(item: feedHeaderView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 64)

		let height = NSLayoutConstraint(item: feedHeaderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: feedHeaderView.normalHeight)

		NSLayoutConstraint.activate(constrainsH)
		NSLayoutConstraint.activate([top, height])

		feedHeaderView.heightConstraint = height

		self.feedHeaderView = feedHeaderView
    }
    
    func tryShowSubscribeView() {
        
        guard let group = conversation.withGroup else {
            return
        }

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


    func makeFormulaHeaderView(with formula: Formula?) {
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
        
        self.formulaHeaderView = headerView
        
    }
    
   
    
}
