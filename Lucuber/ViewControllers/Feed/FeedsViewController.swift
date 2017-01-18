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

class FeedsViewController: BaseViewController, SegueHandlerType, SearchTrigeer, CanScrollsToTop{
    
    // MARK: - Properties
    
    var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    lazy var searchTransition: SearchTransition = {
        return SearchTransition()
    }()

    enum SegueIdentifier: String {
        case newFeed = "showNewFeed"
    }
    
    var seletedFeedCategory: FeedCategory?
    
    var needShowCategory: Bool {
        return (seletedFeedCategory == nil) ? true : false
    }
    
    var feeds = [DiscoverFeed]()
    
    var uploadingFeeds = [DiscoverFeed]()
    func handleUploadingErrorMessage(message: String) {
        if !uploadingFeeds.isEmpty {
            uploadingFeeds[0].uploadingErrorMessage = message
            tableView.reloadSections(IndexSet(integer: Section.uploadingFeed.rawValue), with: .none)
        }
    }
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
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedsViewController.tryRefreshOrGetNewFeeds), for: .valueChanged)
        return refreshControl
        
    }()
    
    fileprivate lazy var formulaTextTitleView: UIView = {
        
        let titleLabel = UILabel()
        
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 18)
        ]
        
        let titleAttr = NSMutableAttributedString(string: "公式", attributes:textAttributes)
        
        titleLabel.attributedText = titleAttr
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.backgroundColor = UIColor.cubeTintColor()
        titleLabel.sizeToFit()
        
        titleLabel.bounds = titleLabel.frame.insetBy(dx: -25.0, dy: -4.0)
        
        titleLabel.layer.cornerRadius = titleLabel.frame.size.height/2.0
        titleLabel.layer.masksToBounds = true
        
        return titleLabel
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = self.makeSearchBar()
        return searchBar
    }()
    
    private lazy var newFeedActionSheetView: ActionSheetView = {
        let view = self.makeFeedActionSheetView()
        return view
    }()
    
    var isUploadingFeed = false
    
    var lastFeedCreatedDate: Date {
        if feeds.isEmpty { return Date() }
        
        var date: Date? = Date()
        if let lastFeed = feeds.last {
            date = lastFeed.createdAt
        }
        return date ?? Date()
    }
    
    var scrollView: UIScrollView? {
        return tableView
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        //有
        if let feedsContainerViewController = self.navigationController?.viewControllers[0] as? FeedsContainerViewController {
            
            feedsContainerViewController.showProfileViewControllerAction = { [weak self] segue, sender in
                
                guard  segue.identifier == "showProfileView" else {
                    return
                }
                
                guard let strongSelf = self else {
                    return
                }
                
                let vc = segue.destination as! ProfileViewController
                
                if let indexPath = sender as? IndexPath, let section = Section(rawValue: indexPath.section) {
                    
                    switch section {
                    case .uploadingFeed:
                        let discoveredUser = strongSelf.uploadingFeeds[indexPath.row].creator
                        vc.prepare(with: discoveredUser)
                    case .feed:
                        let discoveredUser = strongSelf.feeds[indexPath.row].creator
                        vc.prepare(with: discoveredUser)
                    default:
                        break
                    }
                }
            }
            
            feedsContainerViewController.showCommentViewControllerAction = { [weak self] segue, sender in
                
                guard let strongSelf = self else {
                    return
                }
                
                let vc = segue.destination as! CommentViewController
                
                guard let indexPath = sender as? IndexPath,
                    let feed = strongSelf.feeds[safe: indexPath.row],
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
                            strongSelf.uploadFeed()
                        }
                    }
                }
            }
            
            feedsContainerViewController.showFormulaDetailViewControllerAction = { [weak self] segue, sender in
                guard let strongSelf = self else {
                    return
                }
                
                let vc = segue.destination as! FormulaDetailViewController
                
                guard let indexPath = sender as? IndexPath,
                    let feed = strongSelf.feeds[safe: indexPath.row],
                    let realm = try? Realm() else {
                        return
                }
                
                var formula = feedWith(feed.objectId!, inRealm: realm)?.withFormula
                
                if formula == nil {
                    realm.beginWrite()
                    formula = vc.prepareFormulaFrom(feed, inRealm: realm)
                    try? realm.commitWrite()
                }
                
                guard let resultFormula = formula else {
                    return
                }
                vc.formula = resultFormula
                vc.previewFormulaStyle = .single
            }
            
            feedsContainerViewController.showFormulaFeedsViewControllerAction = { [weak self] segue, sender in
                let vc = segue.destination as! FeedsViewController
                vc.seletedFeedCategory = .formula
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        recoverOriginalNavigationDelegate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarLine.isHidden = false
        
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        tableView.addSubview(refreshControl)
        
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        
        tableView.registerClass(of: FeedBaseCell.self)
        tableView.registerClass(of: FeedBiggerImageCell.self)
        tableView.registerClass(of: FeedAnyImagesCell.self)
        tableView.registerClass(of: FeedURLCell.self)
        tableView.registerClass(of: FeedFormulaCell.self)
        tableView.registerNib(of: LoadMoreTableViewCell.self)
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        tableView.contentOffset.y = searchBar.frame.height
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.title = "话题"
        
        searchBar.placeholder = "搜索话题"
        
        
        if seletedFeedCategory != nil {
            navigationItem.titleView = formulaTextTitleView
            navigationItem.rightBarButtonItem = nil
            tableView.tableHeaderView = UIView()
        }
        
        tableView.contentOffset.y = searchBar.frame.height
        
       
        
        uploadFeed()
    }
    
    deinit {
        printLog("\(self)" + "已经释放")
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
                strongSelf.refreshControl.endRefreshing()
                
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
            
        } else {
            // 设定排序
//            var feedStoryStyle = self.feedSortStyle
            
        }
        
        fetchDiscoverFeed(with: seletedFeedCategory, feedSortStyle: self.feedSortStyle, uploadingFeedMode: mode, lastFeedCreatDate: self.lastFeedCreatedDate, failureHandler: failureHandler, completion: completion)
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
    
    // MARK: - Segue
    var newFeedViewController: NewFeedViewController?
    
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
            vc.getFeedsViewController = getFeedsViewController
    
        }
    }
}

// MARK: - TableView Delegaate&DataSource

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public enum Section: Int {
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
                let cell: FeedBaseCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            case .url:
                let cell: FeedURLCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            case .image:
                if feed.imageAttachmentsCount == 1 {
                    let cell: FeedBiggerImageCell = tableView.dequeueReusableCell(for: indexPath)
                    return cell
                    
                } else {
                    let cell: FeedAnyImagesCell = tableView.dequeueReusableCell(for: indexPath)
                    return cell
                }
                
            case .formula:
                let cell: FeedFormulaCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            default:
                let cell: FeedBaseCell = tableView.dequeueReusableCell(for: indexPath)
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
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        func configureFeedCell(cell: UITableViewCell, withFeed feed: DiscoverFeed) {
            
            guard let cell = cell as? FeedBaseCell else {
                return
            }
            
            cell.tapAvatarAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                strongSelf.navigationController?.viewControllers[0].performSegue(withIdentifier: "showProfileView", sender: indexPath)
            }
            
            
            cell.tapCategoryAction = { [weak self] cell in
                guard
                    let strongSelf = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                strongSelf.navigationController?.viewControllers[0].performSegue(withIdentifier: "showFormulaFeeds", sender: indexPath)
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
                
                cell.configureWithFeed(feed, layout: layout, needshowCategory: false)
                
            case .url:
                
                guard let cell = cell as? FeedURLCell else {
                    break
                }
                
                cell.configureWithFeed(feed, layout: layout, needshowCategory: false)
                
                cell.tapURLInfoAction = { [weak self] URL in
                    self?.parent?.cube_openURL(URL)
                }
                
            case .image:
                
                let tapMediaAction: tapMediaActionTypealias = { [weak self] transitionView, image, attachments, index in
                    
                    guard let image = image else {
                        return
                    }
                    
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
                
                if feed.imageAttachmentsCount == 1 {
                    guard let cell = cell as? FeedBiggerImageCell else {
                        break
                    }
                    
                    cell.configureWithFeed(feed, layout: layout, needshowCategory: false)
                    cell.tapMediaAction = tapMediaAction
                    
                } else {
                   
                    guard let cell = cell as? FeedAnyImagesCell else {
                        break
                    }
                    
                    cell.configureWithFeed(feed, layout: layout, needshowCategory: false)
                    cell.tapMediaAction = tapMediaAction
                }
                

            case .formula:

                guard let cell = cell as? FeedFormulaCell else {
                    return
                }
                cell.configureWithFeed(feed, layout: layout, needshowCategory: needShowCategory)

                cell.tapFormulaInfoAction = { [weak self] cell in
                    
                    guard let cell = cell else {
                        return
                    }
                    
                    guard let indexPath = tableView.indexPath(for: cell) else {
                        return
                    }
                    self?.navigationController?.viewControllers[0].performSegue(withIdentifier: "showFormulaDetail", sender: indexPath)
                }
                
            default:
                break
            }
        }
        
        switch section {
            
        case .uploadingFeed:
            
            let feed = uploadingFeeds[indexPath.row]
            configureFeedCell(cell: cell, withFeed: feed)
            
            if let cell = cell as? FeedBaseCell {
                
                cell.retryUploadingFeedAction = { [weak self] cell in
                    
                    self?.newFeedViewController?.post(again: true)

                    if let indexPath = self?.tableView.indexPath(for: cell) {
                        self?.uploadingFeeds[indexPath.row].uploadingErrorMessage = nil
                        cell.hasUploadingErrorMessage = false
                    }
                }

	            cell.deleteUploadingFeedAction = { [weak self] cell in

                    if let indexPath = self?.tableView.indexPath(for: cell) {
                        self?.uploadingFeeds.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.newFeedViewController = nil
                    }

                }
            }
         
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
        case .feed:
            navigationController?.viewControllers[0].performSegue(withIdentifier: "showCommentView", sender: indexPath)
        default:
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
    
}

extension FeedsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        navigationController?.viewControllers[0].performSegue(withIdentifier: "showSearchFeeds", sender: nil)
        return false
    }
}


