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
    
    mutating func FeedCellLayoutOfFeed(feed: DiscoverFeed) -> FeedCellLayout {
        let key = feed.objectId ?? ""
        
        if let layout = FeedCellLayoutHash[key] {
            return layout
        } else {
            let layout = FeedCellLayout(feed: feed)
            
            updateFeedCellLayout(layout: layout, forFeed: feed)
            
            return layout
        }
    }
    
    mutating func updateFeedCellLayout(layout: FeedCellLayout, forFeed feed: DiscoverFeed) {
        let key = feed.objectId ?? ""
        
        if !key.isEmpty {
            FeedCellLayoutHash[key] = layout
        }
    }
    
    mutating func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        let layout = FeedCellLayoutOfFeed(feed: feed)
        return layout.height
    }
    
}

class FeedsViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Properties
    
//    private var newFeedAttachmentType: NewFeedViewController.Attachment = .Media
    
    enum SegueIdentifier: String {
        case newFeed = "ShowNewFeed"
        case comment = "ShowCommentView"
    }

    
    var seletedFeedCategory: FeedCategory?
    
    var needShowCategory: Bool {
        return (seletedFeedCategory == nil) ? true : false
    }
    
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
    fileprivate let FeedURLCellIdentifier = "FeedURLCell"
    fileprivate let FeedFormulaCellIdentifier = "FeedFormulaCell"
    
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
                    strongSelf.cube_performSegue(with: .newFeed, sender: nil)
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
                    
                    try? realm.write {
                        newVc.formula = Formula.new(inRealm: realm)
                    }
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
        refreshControl.tintColor = UIColor.cubeTintColor()
        tableView.addSubview(refreshControl)
        
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        tableView.rowHeight = 300
        
        tableView.register(FeedBaseCell.self, forCellReuseIdentifier: FeedBaseCellIdentifier)
        tableView.register(FeedBiggerImageCell.self, forCellReuseIdentifier: FeedBiggerImageCellIdentifier)
        tableView.register(FeedAnyImagesCell.self, forCellReuseIdentifier: FeedAnyImagesCellIdentifier)
        tableView.register(UINib(nibName: LoadMoreTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: LoadMoreTableViewCellIdentifier)
        tableView.register(FeedURLCell.self, forCellReuseIdentifier: FeedURLCellIdentifier)
        tableView.register(FeedFormulaCell.self, forCellReuseIdentifier: FeedFormulaCellIdentifier)
        
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.title = "话题"
        
        tableView.contentOffset.y = searchBar.frame.height
        
        uploadFeed()
    }
    
    
    fileprivate var canLoadMore: Bool = false
    
    fileprivate func uploadFeed(mode: UploadFeedMode = .top, finish: (() -> Void)? = nil) {
        
        if isUploadingFeed {
            finish?()
            return
        }
        
        isUploadingFeed = true
        
        if mode == .top  && feeds.isEmpty {
            loadingFeedsIndicator.startAnimating()
        }
        
        let failureHandler: FailureHandler  = { reason, errorMessage in
            
            defaultFailureHandler(reason, errorMessage)
            
                DispatchQueue.main.async { [weak self] in
                    
//                    CubeAlert.alertSorry(message: error.localizedFailureReason, inViewController: self)
                    
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
                        IndexPath(row: $0, section: Section.feed.rawValue)
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
            
            // 设定排序
            var feedStoryStyle = self.feedSortStyle
            
            
        }
        
        fetchDiscoverFeed(with: FeedCategory.text, feedSortStyle: self.feedSortStyle, uploadingFeedMode: mode, lastFeedCreatDate: self.lastFeedCreatedDate, failureHandler: failureHandler, completion: completion)
        
     }
    
    // MARK: - Target & Action
    
    func tryRefreshOrGetNewFeeds() {
       
        delay(1.5) {
           self.uploadFeed()
        }
     
    }
    
    @IBAction func creatNewFeed(_ sender: AnyObject) {
        guard let window = view.window else {
            return 
        }
        newFeedActionSheetView.showInView(view: window)
    }
    
    // MARK: - PrepareForSegue
    
    
    fileprivate var newFeedViewController: NewFeedViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let identifier = segueIdentifier(for: segue)
        
        
        let beforeUploadingFeedAction: (DiscoverFeed, NewFeedViewController) -> Void = {
            [weak self] feed, newFeedViewController in
            
            self?.newFeedViewController = newFeedViewController
            
            DispatchQueue.main.async {
                
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.customScrollsToTop()
                strongSelf.tableView.beginUpdates()
                
                strongSelf.uploadingFeeds.insert(feed, at: 0)
                
                let indexPath = IndexPath(row: 0, section: Section.uploadingFeed.rawValue)
                strongSelf.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
                strongSelf.tableView.endUpdates()
            }
        }
        
        let afterCreatedFeedAction: (DiscoverFeed)-> Void = {
            [weak self] feed in
            
            self?.newFeedViewController = nil
            
            DispatchQueue.main.async {
                
                guard let strongSelf = self else {
                    return
                }
                
                feed.parseAttachmentsInfo()
                
                strongSelf.tableView.customScrollsToTop()
                
                strongSelf.tableView.beginUpdates()
                
                var animation: UITableViewRowAnimation = .automatic
                
                if !strongSelf.uploadingFeeds.isEmpty {
                    
                    strongSelf.uploadingFeeds = []
                    
                    let indexSet = IndexSet(integer: Section.uploadingFeed.rawValue)
                    
                    strongSelf.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
                    
                    animation = .none
                }
                
                strongSelf.feeds.insert(feed, at: 0)
                
                let indexPath = IndexPath(row: 0, section: Section.feed.rawValue)
                strongSelf.tableView.insertRows(at: [indexPath], with: animation)
                
                strongSelf.tableView.endUpdates()
                
            }
            
            // TODO: - joinGroup
        }
        
        let getFeedsViewController: () -> FeedsViewController? = {
            [weak self] in
            return self
        }
        
        
        switch identifier {
            
        case .newFeed:
            
            guard let nvc = segue.destination as? UINavigationController, let vc = nvc.topViewController as? NewFeedViewController else {
                return
            }
            
            vc.beforUploadingFeedAction = beforeUploadingFeedAction
            vc.afterUploadingFeedAction = afterCreatedFeedAction
//            vc.getFeedsViewController = getFeedsViewController
            
        case .comment:
            
            let vc = segue.destination as! CommentViewController
            
            guard let indexPath = sender as? IndexPath,
                let feed = feeds[safe: indexPath.row],
                let realm = try? Realm() else {
                return
            }
            
            realm.beginWrite()
            let feedConversation = vc.prepareConversation(for: feed, inRealm: realm)
            try? realm.commitWrite()
            
            vc.conversation = feedConversation
            vc.hidesBottomBarWhenPushed = true
            vc.feed = feed
            
            vc.afterDeletedFeedAction = { [weak self] feedLcObjcetID in
                
                if let strongSelf = self {
                   
                    var deletedFeed: DiscoverFeed?
                    for feed in strongSelf.feeds {
                        if feed.objectId! == feedLcObjcetID {
                            deletedFeed = feed
                            break
                        }
                    }
                    
                    if let deletedFeed = deletedFeed, let index = strongSelf.feeds.index(of: deletedFeed) {
                        strongSelf.feeds.remove(at: index)
                        
                        let indexPath = IndexPath(row: index, section: Section.feed.rawValue)
                        strongSelf.tableView.deleteRows(at: [indexPath], with: .none)
                        
                        return
                    }
                    
                    
                    delay(1) {
                        self?.uploadFeed()
                    }

                    
                }
                
            }
    
            
        }
        
    }
 
}

// MARK: - TableView Delegaate&DataSource

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case uploadingFeed = 0
        case feed
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
            
        case .feed:
            return feeds.count
            
        case .loadMore:
            return feeds.isEmpty ? 0 : 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        func cellForFeed(feed: DiscoverFeed) -> UITableViewCell {
            
            switch feed.category {
                
            case .text:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedBaseCellIdentifier, for: indexPath) as! FeedBaseCell
                
                return cell
                
            case .url:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedURLCellIdentifier, for: indexPath) as! FeedURLCell
                return cell
                
                
            case .image:
                
                if feed.imageAttachmentsCount == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedBiggerImageCellIdentifier, for: indexPath) as! FeedBiggerImageCell
                    return cell
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: FeedAnyImagesCellIdentifier, for: indexPath) as! FeedAnyImagesCell
                    return cell
                }
                
                // TODO: - 其他类型的 Cell
            case .formula:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedFormulaCellIdentifier, for: indexPath) as! FeedFormulaCell
                return cell
                
                
            default:
                  let cell = tableView.dequeueReusableCell(withIdentifier: FeedBaseCellIdentifier, for: indexPath) as! FeedBaseCell
                return cell
            }
            
        }
        
        switch section {
            
        case .uploadingFeed:
            let feed = uploadingFeeds[indexPath.row]
            return cellForFeed(feed: feed)
            
        case .feed:
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
        
        
        // 设置Cell公共的闭包
        func configureFeedCell(cell: UITableViewCell, withFeed feed: DiscoverFeed) {
            
            guard let cell = cell as? FeedBaseCell else {
                return
            }
            
//            cell.needsShowLocation
            
            cell.tapAvatarAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                printLog("点击头像在indexPath: \(indexPath)")
                strongSelf.performSegue(withIdentifier: "", sender: indexPath)
            }
            
            
            cell.tapCategoryAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                printLog("点击Kind在indexPath: \(indexPath)")
                strongSelf.performSegue(withIdentifier: "", sender: indexPath)
            }
            
            cell.touchesBeganAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                strongSelf.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                
            }
            
            cell.touchesEndedAction = { [weak self] cell in
                guard
                    let _ = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                delay(0.03) {
                    [weak self] in
                    self?.tableView(tableView, didSelectRowAt: indexPath)
                }
            }
            
            cell.touchesCancelledAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            }
            
            let layout = FeedsViewController.layoutCatch.FeedCellLayoutOfFeed(feed: feed)
            
            switch feed.category {
            case .text:
                
                cell.configureWithFeed(feed, layout: layout, needshowCategory: self.needShowCategory)
                
            case .url:
                
                guard let cell = cell as? FeedURLCell else {
                    break
                }
                
                cell.configureWithFeed(feed, layout: layout, needshowCategory: self.needShowCategory)
                
                cell.tapURLInfoAction = { [weak self] URL in
                    printLog("打开URL \(URL)")
                    self?.cube_openURL(URL)
                }
                
            case .image:
                
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
                
                if feed.imageAttachmentsCount == 1 {
                    guard let cell = cell as? FeedBiggerImageCell else {
                        break
                    }
                    
                    cell.configureWithFeed(feed, layout: layout, needshowCategory: self.needShowCategory)
                    cell.tapMediaAction = tapMediaAction
                    
                } else {
                   
                    guard let cell = cell as? FeedAnyImagesCell else {
                        break
                    }
                    
                    cell.configureWithFeed(feed, layout: layout, needshowCategory: self.needShowCategory)
                    cell.tapMediaAction = tapMediaAction
                }
                
                
            case .formula:
                
                 cell.configureWithFeed(feed, layout: layout, needshowCategory: self.needShowCategory)
                
            default:
                break
            }
        }
        
        switch section {
        case .uploadingFeed:
            
            let feed = uploadingFeeds[indexPath.row]
            configureFeedCell(cell: cell, withFeed: feed)
         
            break
        case .feed:
            let feed = feeds[indexPath.row]
            configureFeedCell(cell: cell, withFeed: feed)
            
        case .loadMore:
            
            guard let cell = cell as? LoadMoreTableViewCell else {
                break
            }
            
            guard canLoadMore else {
                cell.isLoading = false
                break
            }
            
            printLog("加载更多 Feed")
            
            if !cell.isLoading {
                cell.isLoading = true
            }
            
            uploadFeed(mode: .loadMore, finish: {
                [weak cell] in
                
                cell?.isLoading = false
            })
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
            
        case .feed :
            let feed = feeds[indexPath.row]
            return FeedsViewController.layoutCatch.heightOfFeed(feed: feed)
            
        case .loadMore:
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true)
        
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .uploadingFeed:
            break
        case .feed:
            
            cube_performSegue(with: SegueIdentifier.comment, sender: indexPath as AnyObject?)
            
        case .loadMore:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return false
        }
        
        switch section {
        case .uploadingFeed:
            return false
            
        case .feed:
            
            
            return true
        default:
            return false
        }
    }
    
    // TODO: - Report
    
}

extension FeedsViewController: UISearchBarDelegate {
    
}


