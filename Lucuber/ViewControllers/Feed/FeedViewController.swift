//
//  ConversationViewController.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit





class FeedsViewController: UIViewController {
    
    // MARK: - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddFeed" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let newFeedVC = navigationVC.viewControllers.first! as! NewFeedViewController
            newFeedVC.attachment = newFeedAttachmentType
        }
    }
    
    // MARK: - Properties
    private static var LayoutsCatch = LayoutCatch()
    
    private var newFeedAttachmentType: NewFeedViewController.Attachment = .Media
 
    private lazy var activityIndicatorTitleView = ConversationIndicatorTitleView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    
    var feeds = [Feed]()
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let FeedDefaultCellIdentifier = "FeedDefaultCell"
    private let FeedBiggerImageCellIdentifier = "FeedBiggerImageCell"
    private let LoadMoreTableViewCellIdentifier = "LoadMoreTableViewCell"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            searchBar.sizeToFit()
            tableView.tableHeaderView = searchBar
            
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
            tableView.rowHeight = 300
            
            tableView.registerClass(FeedDefaultCell.self, forCellReuseIdentifier: FeedDefaultCellIdentifier)
            
            tableView.registerClass(FeedBiggerImageCell.self, forCellReuseIdentifier: FeedBiggerImageCellIdentifier)
        
            tableView.registerNib(UINib(nibName: LoadMoreTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: LoadMoreTableViewCellIdentifier)
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.title = "话题"
        
        
        loadNewComment()
        

        tableView.contentOffset.y = CGRectGetHeight(searchBar.frame)
        
    }
    
    private func loadNewComment() {
        activityIndicator.startAnimating()
        let query = AVQuery(className: Feed.parseClassName())
        query.addDescendingOrder("updatedAt")
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if error == nil {
                self.feeds = result as! [Feed]
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
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
                    
                  
                    strongSelf.newFeedAttachmentType = .Media
                    strongSelf.performSegueWithIdentifier("ShowAddFeed", sender: nil)
                }
            ),
            .Option(
                title: "公式",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    let navigationVC = UIStoryboard(name: "AddFormula", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let newVc = navigationVC.rootViewController as! NewFormulaViewController
                    newVc.editType = NewFormulaViewController.EditType.NewAttchment
                    
                    strongSelf.presentViewController(navigationVC, animated: true, completion: nil)
                   
                }
            ),
            .Option(
                title: "复原成绩",
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
    

   
    
}



extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let feed = feeds[indexPath.row]
        
        switch feed.attachment {
        case .Text:
            let cell = tableView.dequeueReusableCellWithIdentifier(FeedDefaultCellIdentifier, forIndexPath: indexPath) as! FeedDefaultCell
            cell.configureWithFeed(feed, layout: FeedsViewController.LayoutsCatch.FeedCellLayoutOfFeed(feed), needshowCategory: false)
            return cell
        case .BigImage:
            let cell = tableView.dequeueReusableCellWithIdentifier(FeedBiggerImageCellIdentifier, forIndexPath: indexPath) as! FeedBiggerImageCell
            cell.configureWithFeed(feed, layout: FeedsViewController.LayoutsCatch.FeedCellLayoutOfFeed(feed), needshowCategory: false)
        default:
            break
        }
        
        
        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let feed = feeds[indexPath.row]
        let height = FeedsViewController.LayoutsCatch.heightOfFeed(feed)
        print(height)
        
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}

extension FeedsViewController: UISearchBarDelegate {
    
}

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
