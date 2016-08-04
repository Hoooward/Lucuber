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
    
    private lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedsViewController.pullRefreshFeed(_:)), forControlEvents: .ValueChanged)
        return refreshControl
        
    }()
    
    private lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), forState: .Normal)
        searchBar.delegate = self
        return searchBar
        
    }()
    
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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
    private var newFeedAttachmentType: NewFeedViewController.Attachment = .Media
    
    var feeds = [Feed]()
    var uploadingFeeds = [Feed]()
 
    private static var LayoutsCatch = LayoutCatch()
    private let FeedDefaultCellIdentifier = "FeedDefaultCell"
    private let FeedBiggerImageCellIdentifier = "FeedBiggerImageCell"
    private let FeedAnyImagesCellIdentifier = "FeedAnyImagesCell"
    private let LoadMoreTableViewCellIdentifier = "LoadMoreTableViewCell"
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            searchBar.sizeToFit()
            tableView.tableHeaderView = searchBar
            
            tableView.addSubview(refreshControl)
            
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
            tableView.rowHeight = 300
            
            tableView.registerClass(FeedDefaultCell.self, forCellReuseIdentifier: FeedDefaultCellIdentifier)
            tableView.registerClass(FeedBiggerImageCell.self, forCellReuseIdentifier: FeedBiggerImageCellIdentifier)
            tableView.registerClass(FeedAnyImagesCell.self, forCellReuseIdentifier: FeedAnyImagesCellIdentifier)
            tableView.registerNib(UINib(nibName: LoadMoreTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: LoadMoreTableViewCellIdentifier)
            
        }
    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.title = "话题"
        
        tableView.contentOffset.y = CGRectGetHeight(searchBar.frame)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        uploadFeed()
    }
 
    
    
    // MARK: - UploadingFeed 
    
    var isUploadingFeed = false
    var lastFeedCreatedDate: NSDate {
        
        if feeds.isEmpty { return NSDate() }
        return feeds.last!.createdAt
        
    }
    
    private func uploadFeed(mode: UploadFeedMode = .Top, finish: (() -> Void)? = nil) {
        
        if isUploadingFeed {
            finish?()
            return
        }
        
        isUploadingFeed = true
        
        if mode == .Top  && feeds.isEmpty {
            activityIndicator.startAnimating()
        }
        
        let failureHandler: (error: NSError) -> Void  = { error in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
               
                CubeAlert.alertSorry(message: error.localizedFailureReason, inViewController: self)
                
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                finish?()
            }
        }
        
        let completion: ([Feed]) -> Void = { feeds in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.isUploadingFeed = false
                strongSelf.activityIndicator.stopAnimating()
                
                let newFeeds = feeds
                
                var wayToUpdata = UITableView.WayToUpdata.None
                
                if strongSelf.feeds.isEmpty {
                    wayToUpdata = .ReloadData
                }
                
                switch mode {
                    
                case .Top:
                    
                    wayToUpdata = .ReloadData
                    strongSelf.feeds = newFeeds
                    
                    strongSelf.refreshControl.endRefreshing()
                    
                case .LoadMore:
                    
                    let oldFeedsCount = strongSelf.feeds.count
                    
                    let oldFeedIDs = Set<String>(strongSelf.feeds.map { $0.objectId })
                    
                    var newRealFeeds = [Feed]()
                    for feed in newFeeds {
                        if !oldFeedIDs.contains(feed.objectId) {
                           newRealFeeds.append(feed)
                        }
                    }
                    
                    strongSelf.feeds += newRealFeeds
                    
                    let newFeedCount = strongSelf.feeds.count
                    
                    let indexPaths = Array(oldFeedsCount..<newFeedCount).map {
                       NSIndexPath(forRow:$0, inSection: Section.Feed.rawValue)
                    }
                    
                    wayToUpdata = .Insert(indexPaths)
                    
                }
            
                wayToUpdata.performWithTableView(strongSelf.tableView)
                
                finish?()
            }
            
        }
        
        fetchFeedWithCategory(FeedCategory.All, uploadingFeedMode: mode,lastFeedCreatDate: lastFeedCreatedDate, completion: completion, failureHandler: failureHandler)
    }
    
  

 
  
    
    // MARK: - Target
    @IBAction func creatNewFeed(sender: AnyObject) {
        if let window = view.window {
            newFeedActionSheetView.showInView(window)
        }
    }
    
    func pullRefreshFeed(sender: UIRefreshControl) {
        uploadFeed()
    }
    
}

// MARK: - TableViewDelegate&DataSource

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case uploadingFeed = 0
        case Feed
        case loadMore
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
            
        case .uploadingFeed:
            return uploadingFeeds.count
            
        case .Feed:
            return feeds.count
            
        case .loadMore:
            return feeds.isEmpty ? 0 : 1
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        func cellForFeed(feed: Feed) -> UITableViewCell {
            
            switch feed.attachment {
                
            case .Text:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(FeedDefaultCellIdentifier, forIndexPath: indexPath) as! FeedDefaultCell
                cell.configureWithFeed(feed, layout: FeedsViewController.LayoutsCatch.FeedCellLayoutOfFeed(feed), needshowCategory: false)
                return cell
                
            case .Image(let imagesAttachments):
                
                if imagesAttachments.count  > 1 {
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(FeedAnyImagesCellIdentifier, forIndexPath: indexPath) as! FeedAnyImagesCell
                    
                    cell.configureWithFeed(feed, layout: FeedsViewController.LayoutsCatch.FeedCellLayoutOfFeed(feed), needshowCategory: false)
                    
                    return cell
                }
                
                let cell = tableView.dequeueReusableCellWithIdentifier(FeedBiggerImageCellIdentifier, forIndexPath: indexPath) as! FeedBiggerImageCell
                
                cell.configureWithFeed(feed, layout: FeedsViewController.LayoutsCatch.FeedCellLayoutOfFeed(feed), needshowCategory: false)
                
                return cell
  
            default:
                return UITableViewCell()
            }
        }
   
        switch section {
            
        case .uploadingFeed:
            let feed = uploadingFeeds[indexPath.row]
            return cellForFeed(feed)
            
        case .Feed:
            let feed = feeds[indexPath.row]
            return cellForFeed(feed)
            
        case .loadMore:
            
            return tableView.dequeueReusableCellWithIdentifier(LoadMoreTableViewCellIdentifier, forIndexPath: indexPath)
        }
        
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        
        
        switch section {
            
        case .Feed:
    
            let feed = feeds[indexPath.row]
            
            guard let cell = cell as? FeedBiggerImageCell else {
                break
            }
            
            cell.tapMediaAction = { [weak self] transitionView, image, index in
                
                guard let image = image else {
                    return
                }
                
                let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreviewViewController") as! MediaPreviewViewController
                
                vc.startIndex = index
//                vc.transitionView = transitionView
                let frame = transitionView.convertRect(transitionView.bounds, toView: self?.view)
                vc.previewImageViewInitalFrame = frame
                vc.bottomPreviewImage = image
                
                delay(0) {
//                    transitionView.alpha = 0
                }
                
                vc.afterDismissAction = { [weak self] in
                 
//                    transitionView.alpha = 1
                    self?.view.window?.makeKeyAndVisible()
                }
                
                vc.previewMedias = [image]
                
                mediaPreviewWindow.rootViewController = vc
                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                mediaPreviewWindow.makeKeyAndVisible()
                
            }
    
            
        case .loadMore:
            guard let cell = cell as? LoadMoreTableViewCell else {
                return
            }
            cell.isLoading = true
            uploadFeed(UploadFeedMode.LoadMore) {
                cell.isLoading = false
            }
            
        default:
            break
        }
    }
    
 
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .uploadingFeed:
            let feed = uploadingFeeds[indexPath.row]
            return FeedsViewController.LayoutsCatch.heightOfFeed(feed)
            
        case .Feed :
            let feed = feeds[indexPath.row]
            return FeedsViewController.LayoutsCatch.heightOfFeed(feed)
            
        case .loadMore:
            return 60
        }
        
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
