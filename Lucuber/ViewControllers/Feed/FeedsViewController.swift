//
//  FeedsViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

struct LayoutCatch {
    
    var FeedCellLayoutHash = [String: FeedCellLayout]()
    
    mutating func FeedCellLayoutOfFeed(feed: DiscoverFormula) -> FeedCellLayout {
        let key = feed.objectId ?? ""
        
        if let layout = FeedCellLayoutHash[key] {
            return layout
        } else {
            let layout = FeedCellLayout(feed: feed)
            
            updateFeedCellLayout(layout: layout, forFeed: feed)
            
            return layout
        }
    }
    
    mutating func updateFeedCellLayout(layout: FeedCellLayout, forFeed feed: DiscoverFormula) {
        let key = feed.objectId ?? ""
        
        if !key.isEmpty {
            FeedCellLayoutHash[key] = layout
        }
    }
    
    mutating func heightOfFeed(feed: DiscoverFormula) -> CGFloat {
        let layout = FeedCellLayoutOfFeed(feed: feed)
        return layout.height
    }
    
}

class FeedsViewController: UIViewController {
    
    // MARK: - Properties
    
//    private var newFeedAttachmentType: NewFeedViewController.Attachment = .Media

    
    var feeds = [DiscoverFeed]()
    var uploadingFeeds = [DiscoverFeed]()
    
    // 显示某人所有的Feed
    public var profileUser: RUser?
    var perparedFeedsCount = 0
    
    var hideRightbarItem: Bool = false
    
    fileprivate lazy var filterStyles: [FeedSortStyle] = [
        .distance,
        .time,
        .match
    ]
    
    fileprivate var feedSortStyle: FeedSortStyle = .match {
        didSet {
            // needShowDistance
            feeds = []
            tableView.reloadData()
            
        }
    }
    
    fileprivate static var layoutCatch = LayoutCatch()
    
    @IBOutlet weak var loadingFeedsIndicator: UIActivityIndicatorView!
    private lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedsViewController.tryRefreshOrGetNewFeeds), for: .valueChanged)
        return refreshControl
        
    }()
    
    private lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), for: .normal)
        searchBar.delegate = self
        return searchBar
        
    }()
    
    fileprivate let FeedBaseCellIdentifier = "FeedBaseCell"
    fileprivate let FeedBiggerImageCellIdentifier = "FeedBiggerImageCell"
    fileprivate let FeedAnyImagesCellIdentifier = "FeedAnyImagesCell"
    fileprivate let LoadMoreTableViewCellIdentifier = "LoadMoreTableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var isUploadingFeed = false
    
    var lastFeedCreatedDate: Date {
        
        if feeds.isEmpty { return Date() }
        
        var date: Date? = Date()
        
        if let lastFeed = feeds.last {
            date = lastFeed.createdAt
        }
        return date ?? Date()
    }
    
    private lazy var newFeedActionSheetView: ActionSheetView = {
        
        let view = ActionSheetView(items: [
            .Option(
                title: "文字和图片",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
//                    strongSelf.newFeedAttachmentType = .media
                    strongSelf.performSegue(withIdentifier: "ShowNewFeed", sender: nil)
                }
            ),
            
            .Option(
                title: "公式",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    let navigationVC = UIStoryboard(name: "NewFormula", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let newVc = navigationVC.viewControllers.first as! NewFormulaViewController
                    
                    /// 由于初始化顺序,下面三行代码先后顺序不可改变
                    guard let realm = try? Realm() else {
                        return
                    }
                    newVc.editType = NewFormulaViewController.EditType.newAttchment
                    newVc.view.alpha = 1
                    newVc.formula = Formula.new(inRealm: realm)
                    newVc.realm = realm
                    
                    strongSelf.present(navigationVC, animated: true, completion: nil)
                    
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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        tableView.addSubview(refreshControl)
        
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        tableView.rowHeight = 300
        
        tableView.register(FeedBaseCell.self, forCellReuseIdentifier: FeedBaseCellIdentifier)
        tableView.register(FeedBiggerImageCell.self, forCellReuseIdentifier: FeedBiggerImageCellIdentifier)
        tableView.register(FeedAnyImagesCell.self, forCellReuseIdentifier: FeedAnyImagesCellIdentifier)
        tableView.register(UINib(nibName: LoadMoreTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: LoadMoreTableViewCellIdentifier)
        
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.title = "话题"
        
        tableView.contentOffset.y = searchBar.frame.height
        
        uploadFeed()
    }
    
    
    fileprivate func uploadFeed(mode: UploadFeedMode = .top, finish: (() -> Void)? = nil) {
        
        if isUploadingFeed {
            finish?()
            return
        }
        
        isUploadingFeed = true
        
        if mode == .top  && feeds.isEmpty {
            loadingFeedsIndicator.startAnimating()
        }
        
        let failureHandler: (_ error: NSError) -> Void  = { error in
            
                DispatchQueue.main.async { [weak self] in
                    
                    CubeAlert.alertSorry(message: error.localizedFailureReason, inViewController: self)
                    
                    self?.loadingFeedsIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    self?.isUploadingFeed = false
                    
                    finish?()
                }
        }
        
        let completion: ([DiscoverFeed]) -> Void = { feeds in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.isUploadingFeed = false
                strongSelf.loadingFeedsIndicator.stopAnimating()
                
                let newFeeds = feeds
                
                var wayToUpdata = UITableView.WayToUpdata.none
                
                if strongSelf.feeds.isEmpty {
                    wayToUpdata = .reloadData
                }
                
                switch mode {
                    
                case .top:
                    
                    wayToUpdata = .reloadData
                    strongSelf.feeds = newFeeds
                    
                    strongSelf.refreshControl.endRefreshing()
                    
                case .loadMore:
                    
                    let oldFeedsCount = strongSelf.feeds.count
                    
                    let oldFeedIDs = Set<String>(strongSelf.feeds.map { $0.objectId! })
                    
                    var newRealFeeds = [DiscoverFeed]()
                    for feed in newFeeds {
                        if !oldFeedIDs.contains(feed.objectId!) {
                            newRealFeeds.append(feed)
                        }
                    }
                    
                    strongSelf.feeds += newRealFeeds
                    
                    let newFeedCount = strongSelf.feeds.count
                    
                    let indexPaths = Array(oldFeedsCount..<newFeedCount).map {
                        IndexPath(row: $0, section: Section.Feed.rawValue)
                    }
                    
                    wayToUpdata = .insert(indexPaths )
                    
                }
                
                wayToUpdata.performWithTableView(tableView: strongSelf.tableView)
                
                finish?()
            }
            
        }
        
        if let  _ = profileUser {
            // 获取当前用户的Feed
            
        }  else {
            
            var feedStoryStyle = self.feedSortStyle
            
            
        }
        
        fetchFeedWithCategory(category: FeedCategory.All, uploadingFeedMode: mode,lastFeedCreatDate: lastFeedCreatedDate, completion: completion, failureHandler: failureHandler)
    }
    
    // MARK: - Target & Action
    
    func tryRefreshOrGetNewFeeds() {
        
         uploadFeed()
    }
    
    @IBAction func creatNewFeed(_ sender: AnyObject) {
        guard let window = view.window else {
            return 
        }
        newFeedActionSheetView.showInView(view: window)
    }
    
    // MARK: - PrepareForSegue
    
 
}

// MARK: - TableView Delegaate&DataSource

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case uploadingFeed = 0
        case Feed
        case loadMore
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        func cellForFeed(feed: Feed) -> UITableViewCell {
            
            switch feed.attachment {
                
            case .Text:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedBaseCellIdentifier, for: indexPath) as! FeedBaseCell
                cell.configureWithFeed(feed: feed, layout: FeedsViewController.layoutCatch.FeedCellLayoutOfFeed(feed: feed), needshowCategory: false)
                return cell
                
            case .Image(let imagesAttachments):
                
                if imagesAttachments.count  > 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedAnyImagesCellIdentifier, for: indexPath) as! FeedAnyImagesCell
                    
                    cell.configureWithFeed(feed: feed, layout: FeedsViewController.layoutCatch.FeedCellLayoutOfFeed(feed: feed), needshowCategory: false)
                    
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedBiggerImageCellIdentifier, for: indexPath) as! FeedBiggerImageCell
                
                cell.configureWithFeed(feed: feed, layout: FeedsViewController.layoutCatch.FeedCellLayoutOfFeed(feed: feed), needshowCategory: false)
                
                return cell
                
            default:
                return UITableViewCell()
            }
        }
        
        switch section {
            
        case .uploadingFeed:
            let feed = uploadingFeeds[indexPath.row]
            return cellForFeed(feed: feed)
            
        case .Feed:
            let feed = feeds[indexPath.row]
            return cellForFeed(feed: feed)
            
        case .loadMore:
            
            return tableView.dequeueReusableCell(withIdentifier: LoadMoreTableViewCellIdentifier, for: indexPath)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        
        
        switch section {
            
        case .Feed:
            
            _ = feeds[indexPath.row]
            
            let tapMediaAction: tapMediaActionTypealias = { [weak self] transitionView, image, attachments, index in
                
                guard let image = image else {
                    return
                }
                
                let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewController(withIdentifier: "MediaPreviewViewController") as! MediaPreviewViewController
                
                vc.startIndex = index
                //                vc.transitionView = transitionView
                let frame = transitionView.convert(transitionView.bounds, to: self?.view)
                vc.previewImageViewInitalFrame = frame
                vc.bottomPreviewImage = image
                
                delay(0) {
                    //                    transitionView.alpha = 0
                }
                
                vc.afterDismissAction = { [weak self] in
                    
                    //                    transitionView.alpha = 1
                    self?.view.window?.makeKeyAndVisible()
                }
                
                vc.previewMedias = attachments.map { PreviewMedia.attachmentType($0) }
                
                mediaPreviewWindow.rootViewController = vc
                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                mediaPreviewWindow.makeKeyAndVisible()
                
            }
            
            if let cell = cell as? FeedBiggerImageCell {
                cell.tapMediaAction = tapMediaAction
            }
            
            if let cell = cell as? FeedAnyImagesCell {
                cell.tapMediaAction = tapMediaAction
            }
            
            
            
        case .loadMore:
            guard let cell = cell as? LoadMoreTableViewCell else {
                return
            }
            cell.isLoading = true
            uploadFeed(mode: UploadFeedMode.loadMore) {
                cell.isLoading = false
            }
            
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .uploadingFeed:
            let feed = uploadingFeeds[indexPath.row]
            return FeedsViewController.layoutCatch.heightOfFeed(feed: feed)
            
        case .Feed :
            let feed = feeds[indexPath.row]
            return FeedsViewController.layoutCatch.heightOfFeed(feed: feed)
            
        case .loadMore:
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
        
        
    }
    
}

extension FeedsViewController: UISearchBarDelegate {
    
}

///缓存Cell中元素的Frame

