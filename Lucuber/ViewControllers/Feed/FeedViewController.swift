//
//  ConversationViewController.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

///缓存Cell中元素的Frame
private struct LayoutCatch {
    
    private var FeedCellLayoutHash = [String: FeedCellLayout]()
    
    private mutating func FeedCellLayoutOfFeed(feed: Feed) -> FeedCellLayout {
        let key = feed.objectId
        
        if let layout = FeedCellLayoutHash[key] {
            return layout
        } else {
            let layout = FeedCellLayout(feed: feed)
            
            updateFeedCellLayout(layout, forFeed: feed)
            
            return layout
        }
    }
    
    private mutating func updateFeedCellLayout(layout: FeedCellLayout, forFeed feed: Feed) {
        let key = feed.objectId
        
        if !key.isEmpty {
            FeedCellLayoutHash[key] = layout
        }
    }
    
    private mutating func heightOfFeed(feed: Feed) -> CGFloat {
        let layout = FeedCellLayoutOfFeed(feed)
        return layout.height
    }
}

private let FeedDefaultCellIdentifier = "FeedDefaultCell"

class FeedViewController: UIViewController {
    
    // MARK: - Properties
    private static var LayoutsCatch = LayoutCatch()
 
    private lazy var activityIndicatorTitleView = ConversationIndicatorTitleView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    
    var feeds = [Feed]()
    

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            searchBar.sizeToFit()
            tableView.tableHeaderView = searchBar
            
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
            tableView.rowHeight = 300
            
            tableView.registerClass(FeedDefaultCell.self, forCellReuseIdentifier: FeedDefaultCellIdentifier)
            
        
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleLabel
        //        let content = "评论" + NSUUID().UUIDString
        
        
        loadNewComment()
        
        let feed = Feed()
        
        feed.contentBody = "UIRefreshControl的使用方法一般是在UIControlEventValueChanged事件时触发，也就是下拉到一定程度的时候触发。这样可能出现的问题是下拉释放后很快调用-endRefresh，动画不流畅。可以在－scrollViewDidEndDragging:willDecelerate:时判断下拉程度来触发，或者延迟调用-endRefresh。最后找到了看起来完美的方法，在下拉释放回弹后调用。也就是在-scrollViewDidEndDecelerating:中调用，代码如下："
        
        feed.creator = AVUser.currentUser()
        feed.kind = FeedKind.Text.rawValue
        feed.category = FeedCategory.Formula.rawValue
        
        feed.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.feeds.append(feed)
                print("发布成功")
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        })
        tableView.contentOffset.y = CGRectGetHeight(searchBar.frame)
        
    }
    
    func loadNewComment() {
        let query = AVQuery(className: Feed.parseClassName())
        query.addDescendingOrder("updatedAt")
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if error == nil {
                self.feeds = result as! [Feed]
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
              
            })
            }
        })
    }

 
    private lazy var newFeedActionSheetView: ActionSheetView = {
        let view = ActionSheetView(items: [
            .Option(
                title: "文字和图片",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.performSegueWithIdentifier("ShowAddFeed", sender: nil)
                }
            ),
            
            .Option(
                title: "复原成绩",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                }
            ),
            
            .Option(
                title: "公式",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                }
            ),
            
            .Cancel
            
            ]
        )
        return view
    }()
    
    // MARK: - Target
    @IBAction func creatNewFeed(sender: AnyObject) {
        if let window = view.window {
            newFeedActionSheetView.showInView(window)
        }
    }
    
   
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), forState: .Normal)
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "话题"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.sizeToFit()
        return titleLabel
    }()
   
    
}



extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FeedDefaultCellIdentifier, forIndexPath: indexPath) as! FeedDefaultCell
        cell.configureWithFeed(feeds[indexPath.row], layout: FeedViewController.LayoutsCatch.FeedCellLayoutOfFeed(feeds[indexPath.row]), needshowCategory: false)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let feed = feeds[indexPath.row]
        let height = FeedViewController.LayoutsCatch.heightOfFeed(feed)
        print(height)
        
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}

extension FeedViewController: UISearchBarDelegate {
    
}
