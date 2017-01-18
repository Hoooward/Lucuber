//
//  SubcribesViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

class SubscribesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(of: SubscribeFeedCell.self)
            tableView.registerNib(of: DeletedSuscribeFeedCell.self)
        }
    }
    
    var realm = try! Realm()
    @IBOutlet weak var noSubscribeListLabel: UILabel! {
        didSet {
           noSubscribeListLabel.textColor = UIColor.lightGray
        }
    }
    
    
    fileprivate var noSubscribeList: Bool {
        return self.feedConversations.count == 0
    }
    
    fileprivate var haveUnreadMessages = false {
        didSet {
            reloadTableView()
        }
    }
    
    fileprivate lazy var clearUnreadBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "清空未读", style: .plain, target: self, action: #selector(SubscribesViewController.clearUnread))
        return item
    }()
    
    fileprivate lazy var feedConversations: Results<Conversation> = {
        return feedConversationsInRealm(self.realm)
    }()
    
    fileprivate var unreadFeedConversations: Results<Conversation>? {
        didSet {
            if let unreadFeedConversations = unreadFeedConversations {
                navigationItem.rightBarButtonItem = unreadFeedConversations.count > 3 ? clearUnreadBarButtonItem : nil
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    fileprivate var feedConversationsNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "订阅"
        
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        tableView.contentOffset.y = 0
        
        feedConversationsNotificationToken = feedConversations.addNotificationBlock {
            [weak self] (change: RealmCollectionChange) in
            let predicate = NSPredicate(format: "hasUnreadMessages = true")
            self?.unreadFeedConversations = self?.feedConversations.filter(predicate)
            self?.updateFooterView()
        }
        
        if let gestures = navigationController?.view.gestureRecognizers {
            for recognizer in gestures {
                if recognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    tableView.panGestureRecognizer.require(toFail: recognizer as! UIScreenEdgePanGestureRecognizer)
                    break
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SubscribesViewController.reloadTableView), name: Config.NotificationName.newUnreadMessages, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SubscribesViewController.reloadTableView), name: Config.NotificationName.changedFeedConversation, object: nil)
    }
    
    var isFirstAppear = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isFirstAppear {
            haveUnreadMessages = countOfUnreadMessagesInRealm(realm, withConversationType: .group) > 0
        }
        
        isFirstAppear = false
        
        tableView.setEditing(false, animated: true)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
        tableView?.delegate = nil
        
        feedConversationsNotificationToken?.stop()
        
    }
    
    func clearUnread() {
        
    }
    
    @objc fileprivate func reloadTableView() {
        self.tableView.reloadData()
        updateFooterView()
    }
    
    fileprivate func updateFooterView() {
        noSubscribeListLabel.isHidden = !noSubscribeList
    }
}

extension SubscribesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedConversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = feedConversations[indexPath.row]
        
        if let feed = conversation.withGroup?.withFeed {
            
            if feed.deleted {
                let cell: DeletedSuscribeFeedCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
            } else {
                let cell: SubscribeFeedCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
            }
            
        } else {
            
            let cell: SubscribeFeedCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let conversation = feedConversations[indexPath.row]
        
        if let feed = conversation.withGroup?.withFeed {
            
            if feed.deleted {
                guard let cell = cell as? DeletedSuscribeFeedCell else {
                    return
                }
                
                cell.configureCell(with: conversation)
                
            } else {
                guard let cell = cell as? SubscribeFeedCell else {
                    return
                }
                
                cell.configureCell(with: conversation)
            }
            
        } else {
            guard let cell = cell as? SubscribeFeedCell else {
                return
            }
            
             cell.configureCell(with: conversation)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消订阅"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let group = self.feedConversations[indexPath.row].withGroup else {
                return
            }
            printLog(group)
            
            if group.notificationEnabled {
                
                unSubscribeConversationWithGroupID(group.groupID, failureHandler: {
                    reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                    
                    tableView.setEditing(false, animated: true)
                    CubeAlert.alertSorry(message: "取消订阅失败,请检查网络连接.", inViewController: self)
                    
                }, completion: {
                    
                    let subscribeFeedID = group.groupID
                    
                    var oldSubscribeList = [String]()
                    if let oldMySubscribeList = AVUser.current()?.subscribeList() {
                        oldSubscribeList = oldMySubscribeList
                    }
                    
                    var newSubscribeList = oldSubscribeList
                    
                    if group.includeMe {
                        if newSubscribeList.contains(subscribeFeedID) {
                            if let index = newSubscribeList.index(of: subscribeFeedID) {
                                newSubscribeList.remove(at: index)
                            }
                        }
                    }
                    
                    pushMySubscribeListToLeancloud(with: newSubscribeList,failureHandler: { reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                        tableView.setEditing(false, animated: true)
                        CubeAlert.alertSorry(message: "取消订阅失败,请检查网络连接.", inViewController: self)
                        
                    }, completion: {
                        
                        guard let realm = try? Realm() else {
                            return
                        }
                        
                        try? realm.write {
                            group.notificationEnabled = false
                            group.includeMe = false
                        }
                        
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    })
                })
                
            } else {
                
                let subscribeFeedID = group.groupID
                
                var oldSubscribeList = [String]()
                if let oldMySubscribeList = AVUser.current()?.subscribeList() {
                    oldSubscribeList = oldMySubscribeList
                }
                
                var newSubscribeList = oldSubscribeList
                
                if group.includeMe {
                    if newSubscribeList.contains(subscribeFeedID) {
                        if let index = newSubscribeList.index(of: subscribeFeedID) {
                            newSubscribeList.remove(at: index)
                        }
                    }
                }
                
                pushMySubscribeListToLeancloud(with: newSubscribeList,failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                    tableView.setEditing(false, animated: true)
                    CubeAlert.alertSorry(message: "取消订阅失败,请检查网络连接.", inViewController: self)
                }, completion: {
                    
                    guard let realm = try? Realm() else {
                        return
                    }
                    try? realm.write {
                        group.includeMe = false
                    }
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            }
        }
    }
    
   
}


















