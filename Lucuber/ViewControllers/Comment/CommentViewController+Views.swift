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
import Proposer

// MARK: - titleView
extension CommentViewController {

	func makeTitleView() -> ConversationTitleView {

		let titleView = ConversationTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))

		if let title = titleNameOfConversation(self.conversation) {
			titleView.nameLabel.text = title
		} else {
			titleView.nameLabel.text = "讨论"
		}

		/*
		self.updateStateInfoOfTitleView(titleView)

		titleView.userInteractionEnabled = true

		let tap = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.showFriendProfile(_:)))

		titleView.addGestureRecognizer(tap)

		titleView.stateInfoLabel.textColor = UIColor.gray
		titleView.stateInfoLabel.text = "刚刚开始讨论"
         */
        self.updateInfoOfTitleView(titleView: titleView)
		return titleView
	}
    
    func updateInfoOfTitleView(titleView: ConversationTitleView) {
        // TODO: - 更新 TitleViewInfo
        guard !self.conversation.isInvalidated else { return }
        
        // 拿到 conversation 的最后一个有效 Message, 不包含我
        
        if let message = messages.last {
            let date = Date(timeIntervalSince1970: message.createdUnixTime)
            titleView.stateInfoLabel.text = String(format: "上次见是%@", date.timeAgo)
        } else {
            titleView.stateInfoLabel.text = "刚刚开始讨论"
        }
        
        titleView.stateInfoLabel.textColor = UIColor.gray
    }
}

// MARK: - MoreMessageTypesView
extension  CommentViewController {

	func makeMoreMessageTypeView() -> MoreMessageTypeView {
		let view = MoreMessageTypeView()

		view.alertCanNotAccessPhotoLibraryAction = { [weak self] in
			self?.alertCanNotOpenPhotoLibrary()
		}

		view.sendImageAction = { [weak self] image in
			self?.sendImage(image)
		}

		view.takePhotoAction = { [weak self] in
			let openCamera: ProposerAction = { [weak self] in

				guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
					self?.alertCanNotOpenCamera()
					return
				}
				if let strongSelf = self {
					strongSelf.imagePicker.sourceType = .camera
					strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
				}
			}

			proposeToAccess(.camera, agreed: openCamera, rejected: {
				self?.alertCanNotOpenCamera()
			})
		}

		view.choosePhotoAction = { [weak self] in

			let openPhotoLibrary: ProposerAction = { [weak self] in

				guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
					self?.alertCanNotOpenPhotoLibrary()
					return
				}

				if let strongSelf = self {
					strongSelf.imagePicker.sourceType = .photoLibrary
					strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
				}
			}

			proposeToAccess(.photos, agreed: openPhotoLibrary, rejected: {
				self?.alertCanNotOpenPhotoLibrary()
			})
		}

        /*
		view.pickLocationAction = { [weak self] in
			// TODO: - PickLocation
		}
         */
		return view
	}
}

// MARK: - MoreViewManager
extension  CommentViewController {
	func makeCommentMoreViewManager() -> CommentMoreViewManager {

		let manager = CommentMoreViewManager()

		manager.conversation = self.conversation

		manager.toggleSubscribeAction = { [weak self] in

            
			guard let strongSelf = self else {
				return
			}
			guard let group = strongSelf.conversation.withGroup else {
				return
			}

			let oldincludeMe: Bool = group.includeMe
            let subscribeFeedID = group.groupID
            
            var newSubscribeList = [String]()
            if let oldMySubscribeList = AVUser.current()?.subscribeList() {
                newSubscribeList = oldMySubscribeList
            }
            
            if !oldincludeMe {
                if newSubscribeList.contains(subscribeFeedID) {
                    return
                } else {
                    newSubscribeList.append(subscribeFeedID)
                }
            } else {
                if newSubscribeList.contains(subscribeFeedID) {
                    if let index = newSubscribeList.index(of: subscribeFeedID) {
                        newSubscribeList.remove(at: index)
                    }
                } else {
                    return
                }
            }
            
            // 如果之前已经订阅, 并且开启通知
            if oldincludeMe && group.notificationEnabled {
                
                unSubscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in

                    manager.moreView.hideAndDo(afterHideAction: {
                        CubeAlert.alertSorry(message: "关闭通知失败,请检查网络连接", inViewController: self)
                    })
                    defaultFailureHandler(reason, errorMessage)
                    
                }, completion: {
                    
                    pushMySubscribeListToLeancloud(with: newSubscribeList,failureHandler: { reason, errorMessage in
                        manager.moreView.hideAndDo(afterHideAction: {
                            CubeAlert.alertSorry(message: "取消订阅失败,请检查网络连接", inViewController: self)
                        })
                        defaultFailureHandler(reason, errorMessage)
                    }, completion: {
                        
                        guard let realm = try? Realm() else {
                            return
                        }
                        
                        try? realm.write {
                            group.includeMe = false
                            group.notificationEnabled = false
                        }
                    })
                })
                
            } else {
                
                pushMySubscribeListToLeancloud(with: newSubscribeList,failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                }, completion: {
                    
                    guard let realm = try? Realm() else {
                        return
                    }
                    
                    try? realm.write {
                        group.includeMe = !oldincludeMe
                    }
                })
            }
     
		}
       
        manager.toggleSwitchNotification = { [weak self] switchOn in
            
            guard let group = self?.conversation.withGroup else {
                return
            }
            
            let failedAction: () -> Void = {
                manager.moreView.hideAndDo(afterHideAction: {
                    CubeAlert.alertSorry(message: "开启通知失败,请检查网络连接", inViewController: self)
                })
            }
            
            let updateMysubscribeListAction:() -> Void = {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                let subscribeFeedID = group.groupID
                
                var oldSubscribeList = [String]()
                if let oldMySubscribeList = AVUser.current()?.subscribeList() {
                    oldSubscribeList = oldMySubscribeList
                }
                var newSubscribeList = oldSubscribeList
                
                if switchOn {
                    if newSubscribeList.contains(subscribeFeedID) {
                        try? realm.write {
                            group.notificationEnabled = true
                            group.includeMe = true
                        }
                        return
                    } else {
                        newSubscribeList.append(subscribeFeedID)
                    }
                } else {
                    if newSubscribeList.contains(subscribeFeedID) {
                        if let index = newSubscribeList.index(of: subscribeFeedID) {
                            newSubscribeList.remove(at: index)
                        }
                    } else {
                        return
                    }
                }
                
                pushMySubscribeListToLeancloud(with: newSubscribeList, failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                    failedAction()
                }, completion: {
                    
                    try? realm.write {
                        group.notificationEnabled = true
                        group.includeMe = true
                    }
                })
            }
            
            manager.moreView.hideAndDo(afterHideAction: {
              
            if switchOn {
                if #available(iOS 10.0, *) {
                    
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.getNotificationSettings(completionHandler: {
                        setting in
                        
                        // 系统的回调可能不在主线程, 可能导致下面访问 realm 实例会出错
                        DispatchQueue.main.async {
                            
                            if setting.authorizationStatus != .authorized {
                                manager.moreView.hideAndDo(afterHideAction: { [weak self] in
                                    self?.alertCanNotAccessNotification()
                                })
                               
                            } else {
                                
                                subscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                                    failedAction()
                                    defaultFailureHandler(reason, errorMessage)
                                    
                                }, completion: {
                                    
                                    updateMysubscribeListAction()
                                })
                            }
                        }
                    })
                    
                } else {
                    
                    let settings = UIUserNotificationSettings(
                        types: [.alert, .badge, .sound],
                        categories: nil
                    )
                    
                    let agreedAction: ProposerAction = { [weak self] in
                        
                        if let group = self?.conversation.withGroup {
                            
                            subscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                                failedAction()
                                defaultFailureHandler(reason, errorMessage)
                                
                            }, completion: {
                                 updateMysubscribeListAction()
                            })
                        }
                    }
                    
                    proposeToAccess(.notifications(settings), agreed: {
                        agreedAction()
                    }, rejected: { [weak self] in
                        manager.moreView.hideAndDo(afterHideAction: {
                            self?.alertCanNotAccessNotification()
                        })
                    })
                }
                
            } else {
                
                unSubscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                    manager.moreView.hideAndDo(afterHideAction: {
                        CubeAlert.alertSorry(message: "关闭通知失败,请检查网络连接", inViewController: self)
                    })
                    defaultFailureHandler(reason, errorMessage)
                    
                }, completion: {
                    
                    guard let realm = try? Realm() else {
                        return
                    }
                    try? realm.write {
                        group.notificationEnabled = false
                    }
                })
                }
            })
        }
        
        

		manager.reportAction = {
			// TODO: - 举报
		}

		return manager
	}
}

// MARK: - HeaderView Formula&Feed
extension CommentViewController {

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

    func makeFeedHeaderView(with feed: ConversationFeed?) {

		guard let feed = feed else {
			return
		}

		let feedHeaderView = FeedHeaderView.instanceFromNib()

        feedHeaderView.feed = feed

		feedHeaderView.tapAvatarAction = { [weak self] in
           self?.performSegue(withIdentifier: "showProfileView", sender: nil)
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

        feedHeaderView.tapImagesAction = { [weak self] transitionView, image, attachments, index in
            
            let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewController(withIdentifier: "MediaPreviewViewController") as! MediaPreviewViewController
            
            vc.startIndex = index
            let frame = transitionView.convert(transitionView.bounds, to: self?.view)
            vc.previewImageViewInitalFrame = frame
            vc.bottomPreviewImage = image
            
            vc.afterDismissAction = { [weak self] in
                self?.view.window?.makeKeyAndVisible()
            }
            
            vc.previewMedias = attachments.map { PreviewMedia.attachmentType($0) }
            
            mediaPreviewWindow.rootViewController = vc
            mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
            mediaPreviewWindow.makeKeyAndVisible()
            
        }

        feedHeaderView.tapUrlInfoAction = { [weak self] url in
            self?.cube_openURL(url)
        }
        
        feedHeaderView.tapFormulaInfoAction = { [weak self] _ in
            self?.performSegue(withIdentifier: "showFormulaDetail", sender: nil)
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
        
        guard let group = conversation.withGroup, !group.includeMe else {
            return
        }

        // 仅显示一次
        guard SubscribeViewShown.canShow(groupID: group.groupID) else {
            return
        }
        
        subscribeView.subscribeAction = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let group = strongSelf.conversation.withGroup else {
                return
            }
            
            let updateMysubscribeListAction:() -> Void = {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                let subscribeFeedID = group.groupID
                
                var newSubscribeList = [String]()
                if let oldMySubscribeList = AVUser.current()?.subscribeList() {
                    newSubscribeList = oldMySubscribeList
                }
                
                if newSubscribeList.contains(subscribeFeedID) {
                    try? realm.write {
                        group.includeMe = true
                    }
                    return
                } else {
                    newSubscribeList.append(subscribeFeedID)
                }
                
                pushMySubscribeListToLeancloud(with: newSubscribeList, failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                }, completion: {
                    
                    try? realm.write {
                        group.notificationEnabled = true
                        group.includeMe = true
                    }
                })
            }
            
            
            if #available(iOS 10.0, *) {
                
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.getNotificationSettings(completionHandler: {
                    setting in
                    
                    // 系统的回调可能不在主线程, 可能导致下面访问 realm 实例会出错
                    DispatchQueue.main.async {
                        if setting.authorizationStatus != .authorized {
                           self?.alertCanNotAccessNotification()
                            
                        } else {
                            
                            subscribeConversationWithGroupID(group.groupID, failureHandler: { reason, errorMessage in
                                defaultFailureHandler(reason, errorMessage)
                                
                            }, completion: {
                                updateMysubscribeListAction()
                              
                            })
                        }
                    }
                })
                
            } else {
                
                let settings = UIUserNotificationSettings(
                    types: [.alert, .badge, .sound],
                    categories: nil
                )
                
                let agreedAction: ProposerAction = {
                    subscribeConversationWithGroupID(group.groupID, failureHandler:{ reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                    }, completion: {
                        printLog("订阅成功 id: \(group.groupID)")
                        printLog("before isIncludeMe = \(group.includeMe)")
                        updateMysubscribeListAction()
                    })
                }
                
                proposeToAccess(.notifications(settings), agreed: {
                    agreedAction()
                }, rejected: { [weak self] in
                    self?.alertCanNotAccessNotification()
                })
            }
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

// MARK: - subscribeView
extension CommentViewController {

	func makeSubscribeView() -> SubscribeView {

		let subscribeView = SubscribeView()

		subscribeView.translatesAutoresizingMaskIntoConstraints = false
		self.view.insertSubview(subscribeView, belowSubview: self.messageToolbar)

		let leading = NSLayoutConstraint(item: subscribeView, attribute: .leading, relatedBy: .equal, toItem: self.messageToolbar, attribute: .leading, multiplier: 1.0, constant: 0)

		let trailing = NSLayoutConstraint(item: subscribeView, attribute: .trailing, relatedBy: .equal, toItem: self.messageToolbar, attribute: .trailing, multiplier: 1.0, constant: 0)

		let bottom = NSLayoutConstraint(item: subscribeView, attribute: .bottom, relatedBy: .equal, toItem: self.messageToolbar, attribute: .top, multiplier: 1.0, constant: SubscribeView.totalHeight)

		let height = NSLayoutConstraint(item: subscribeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SubscribeView.totalHeight)

		NSLayoutConstraint.activate([leading, trailing, bottom, height])
		self.view.layoutIfNeeded()

		subscribeView.bottomConstraint = bottom

		return subscribeView
	}
}

// MARK: - imagePicker
extension CommentViewController {

	func makeImagePickerController() -> UIImagePickerController {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		//imagePicker.mediaTypes =  [kUTTypeImage as String, kUTTypeMovie as String]
		imagePicker.videoQuality = .typeMedium
		imagePicker.allowsEditing = false
		return imagePicker
	}
}
