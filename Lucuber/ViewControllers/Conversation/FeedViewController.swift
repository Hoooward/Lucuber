//
//  ConversationViewController.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let FeedDefaultCellIdentifier = "FeedDefaultCell"
class FeedViewController: UIViewController {
    
    private lazy var activityIndicatorTitleView = ConversationIndicatorTitleView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), forState: .Normal)
        searchBar.delegate = self
        return searchBar
    }()

    @IBOutlet var tableView: UITableView! {
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
    
    var feeds = [Feed]()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        let content = "评论" + NSUUID().UUIDString
        
        
        loadNewComment()
    
        let feed = Feed()
        feed.contentBody = content
        feed.author = AVUser.currentUser()
        feed.kind = "text"
        
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
    
    
    private struct LayoutPool {
        
        private var feedCellLayoutHash = [String: FeedcellLayout]()
        
        private mutating func feedCellLayoutOfFeed(feed: Feed) -> FeedcellLayout {
            let key = feed.objectId
            
            if let layout = feedCellLayoutHash[key] {
                return layout
            } else {
                let layout = FeedcellLayout(feed: feed)
                
                updateFeedCellLayout(layout, forFeed: feed)
                
                return layout
            }
        }
        
        private mutating func updateFeedCellLayout(layout: FeedcellLayout, forFeed feed: Feed) {
            let key = feed.objectId
            
            if !key.isEmpty {
                feedCellLayoutHash[key] = layout
            }
        }
        
        private mutating func heightOfFeed(feed: Feed) -> CGFloat {
            let layout = feedCellLayoutOfFeed(feed)
            return layout.height
        }
    }
    
    private static var LayoutsPool = LayoutPool()
    
}

struct FeedcellLayout {
    
    var height: CGFloat = 0
    
    struct DefaultLayout {
        
        let avatarImageViewFrame: CGRect
        let nicknameLabelFrame: CGRect
        let categoryButtonFrame: CGRect
        
        
        let messageTextViewFrame: CGRect
        
        let leftBottomLabelFrame: CGRect
        let messageCountLabelFrame: CGRect
        let discussionImageViewFrame: CGRect
        
    }
    
    init(feed: Feed) {
        if let kind = FeedKind(rawValue: feed.kind!) {
            switch kind{
            case .Text:
                height = FeedDefaultCell.heightOfFeed(feed)
            default:
                break
                
            }
            
        }
        
        let avatarImageViewFrame = CGRect(x: 15, y: 10, width: 40, height: 40)
        
        let nicknameLabelFrame: CGRect
        let categoryButtonFrame: CGRect
        
        if let category = FeedCategory(rawValue: feed.category) {
           
            let rect = (category.rawValue as NSString).boundingRectWithSize(CGSize(width: 320, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)], context: nil)
            
            let categoryButtonWidth = ceil(rect.width) + 20
            
            categoryButtonFrame = CGRect(x: screenWidth - categoryButtonWidth - 15, y: 19, width: categoryButtonWidth, height: 22)
            
            let nickNameLabelwidth = screenWidth - 65 - 15
            nicknameLabelFrame = CGRect(x: 65, y: 21, width: nickNameLabelwidth, height: 18)
            
            
        } else {
            let nickNameLabelwidth = screenWidth - 65 - 15
            nicknameLabelFrame = CGRect(x: 65, y: 21, width: nickNameLabelwidth, height: 18)
            categoryButtonFrame = CGRectZero
        }
        
        let rect1 = (feed.contentBody! as NSString).boundingRectWithSize(CGSize(width: FeedDefaultCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesFontLeading, .UsesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)], context: nil)
        
        let messageTextViewHeight = ceil(rect1.height)
        let messageTextViewFrame = CGRect(x: 65, y: 54, width: screenWidth - 65 - 15, height: messageTextViewHeight)
        
        let leftBottomLabelOriginY = height - 17 - 15
        let leftBottomLabelFrame = CGRect(x: 65, y: leftBottomLabelOriginY, width: screenWidth - 65 - 85, height: 17)
        
        let message
        
    }
    
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FeedDefaultCellIdentifier, forIndexPath: indexPath) as! FeedDefaultCell
        cell.configureWithFeed(feeds[indexPath.row], layout: FeedViewController.LayoutsPool.feedCellLayoutOfFeed(feeds[indexPath.row]), needshowCategory: false)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let feed = feeds[indexPath.row]
        let height = FeedViewController.LayoutsPool.heightOfFeed(feed)
        print(height)
        
        return height
    }
}

extension FeedViewController: UISearchBarDelegate {
    
}
