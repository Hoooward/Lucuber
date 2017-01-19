//
//  SearchFeedsViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

private let screenHeight: CGFloat = UIScreen.main.bounds.height

final class SearchFeedsViewController: UIViewController, SearchAction {
    
    var formulaCateogry: Category?
    var profileUser: ProfileUser?
    
    static let feedNormalImagesCount: Int = CubeRuler.universalHorizontal(3, 4, 4, 3, 4).value
    
    fileprivate lazy var searchFeedsFooterView: SearchFeedFooterView = {
        
        let footerView = SearchFeedFooterView(frame: CGRect(x: 0, y: 0, width: 200, height: screenHeight - 64))
        
        footerView.tapKeywordAction = { [weak self] keyword in
            
            self?.searchBar.text = keyword
            
            self?.isKeywordHot = true
            self?.triggerSearchTaskWithSearchText(keyword)
            
            self?.searchBar.resignFirstResponder()
        }
        
        footerView.tapBlankAction = { [weak self] in
            
            self?.searchBar.resignFirstResponder()
        }
        
        return footerView
    }()
    
    var feeds = [DiscoverFeed]() {
        didSet {
            
            if feeds.isEmpty {
                
                if keyword != nil {
                    searchFeedsFooterView.style = .noResults
                    
                } else {
                    if formulaCateogry != nil || profileUser != nil {
                        searchFeedsFooterView.style = .empty
                    } else {
                        searchFeedsFooterView.style = .keywords
                    }
                }
                
                tableView.tableFooterView = searchFeedsFooterView
                
            } else {
                tableView.tableFooterView = UIView()
            }
        }
    }
    
    let needShowCategory: Bool = false
    
    fileprivate var selectedIndexPathForMenu: IndexPath?
    
    var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    var searchTransition: SearchTransition?
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), for: .normal)
            searchBar.returnKeyType = .done
        }
    }
    
    @IBOutlet weak var searchBarBottomLineView: HorizontalLineView! {
        didSet {
            searchBarBottomLineView.lineColor = UIColor(white: 0.68, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.white
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.cellSeparator()
            
            tableView.registerClass(of: SearchFeedBasicCell.self)
            tableView.registerClass(of: SearchFeedURLCell.self)
            tableView.registerClass(of: SearchFeedFormulaCell.self)
            tableView.registerClass(of: SearchFeedAnyImagesCell.self)
            tableView.registerClass(of: SearchFeedNormalImagesCell.self)
            
            tableView.registerNib(of: LoadMoreTableViewCell.self)
            
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    fileprivate var isKeywordHot: Bool = false
    
    fileprivate var keyword: String? {
        didSet {
            if keyword == nil {
                clearSearchResults()
            }
            if let keyword = keyword, keyword.isEmpty {
                clearSearchResults()
            }
        }
    }
    
    fileprivate var searchTask: CancelableTask?
 
    fileprivate func triggerSearchTaskWithSearchText(_ searchText: String) {
        
        printLog("尝试搜索: \(searchText)")
        
        cancel(searchTask)
        
        if searchText.isEmpty {
            self.keyword = nil
            return
        }
        
        searchTask = delayTask(0.5) { [weak self] in
            if let footer = self?.tableView.tableFooterView as? SearchFeedFooterView {
                footer.style = .searching
            }
            self?.updateSearchResultWithText(searchText)
        }
    }
    
    fileprivate struct LayoutPool {
        
        fileprivate var feedCellLayoutHash = [String: SearchFeedCellLayout]()
        
        fileprivate mutating func feedCellLayoutOfFeed(_ feed: DiscoverFeed) -> SearchFeedCellLayout {
            let key = feed.objectId ?? ""
            
            if let layout = feedCellLayoutHash[key] {
                return layout
                
            } else {
                let layout = SearchFeedCellLayout(feed: feed)
                
                updateFeedCellLayout(layout, forFeed: feed)
                
                return layout
            }
        }
        
        fileprivate mutating func updateFeedCellLayout(_ layout: SearchFeedCellLayout, forFeed feed: DiscoverFeed) {
            
            let key = feed.objectId ?? ""
            
            if !key.isEmpty {
                feedCellLayoutHash[key] = layout
            }
        }
        
        fileprivate mutating func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
            
            let layout = feedCellLayoutOfFeed(feed)
            return layout.height
        }
    }
    
    fileprivate static var layoutPool = LayoutPool()
    
    fileprivate var isFetchingFeeds = false
    fileprivate var canLoadMore: Bool = false
    
    fileprivate func searchFeedsWithKeyword(_ keyword: String, mode: SearchFeedsMode, finish: (() -> Void)? = nil) {
   
        if isFetchingFeeds {
            finish?()
            return
        }
        
        isFetchingFeeds = true
        
        if mode == .init {
            canLoadMore = true
        }
        
        let failureHandler: FailureHandler = { [weak self] reason, errorMessage in
            defaultFailureHandler(reason, errorMessage)
            self?.isFetchingFeeds = false
            finish?()
        }
        
        let lastFeedCreatedDate = feeds.last?.createdAt ?? Date()
        
        fetchDiscoverFeedWithKeyword(keyword, category: formulaCateogry, userID: profileUser?.userID, mode: mode, lastFeedCreatDate: lastFeedCreatedDate, failureHandler: failureHandler, completion: { [weak self] feeds in
            
            let originalFeedsCount = feeds.count
            let validFeeds = feeds.flatMap({$0})
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isFetchingFeeds = false
            
            finish?()
            
            let newFeeds = validFeeds
            let oldFeeds = strongSelf.feeds
            
            self?.canLoadMore = (originalFeedsCount == 30)
            
            var wayToUpdate: UITableView.WayToUpdata = .none
            
            if strongSelf.feeds.isEmpty {
                wayToUpdate = .reloadData
            }
            
            switch mode {
                
            case .init:
                
                strongSelf.feeds = newFeeds
                
                /*
                if Set(oldFeeds.map{ $0.objectId! }) == Set(newFeeds.map{ $0.objectId! }) {
                    wayToUpdate = .none
                } else {
                    wayToUpdate = .reloadData
                }
                 */
                
                wayToUpdate = .reloadData
                
            case .loadMore:
                
                let oldFeedsCount = oldFeeds.count
                
                let oldFeedIDSet = Set(oldFeeds.map{ $0.objectId! })
                var realNewFeeds = [DiscoverFeed]()
                
                for feed in newFeeds {
                    
                    if !oldFeedIDSet.contains(feed.objectId!) {
                        realNewFeeds.append(feed)
                    }
                }
                
                strongSelf.feeds += realNewFeeds
                
                let newFeedsCount = strongSelf.feeds.count
                
               
                let indexPaths = Array(oldFeedsCount..<newFeedsCount).map({ IndexPath(row: $0, section: Section.feed.rawValue) })
                if !indexPaths.isEmpty {
                    wayToUpdate = .insert(indexPaths)
                }
            }
            
            wayToUpdate.performWithTableView(tableView: strongSelf.tableView)
        })
        
    }
    
    fileprivate func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func clearSearchResults() {
        feeds = []
        updateResultsTableView(scrollsToTop: true)
    }
    
    fileprivate func updateResultsTableView(scrollsToTop: Bool = false) {
        tableView.reloadData()
        
        if scrollsToTop {
            tableView.customScrollsToTop()
        }
    }
    
    fileprivate func updateSearchResultWithText(_ searchText: String) {
        
        let searchText = searchText.trimming(trimmingType: .whitespace)
        
        // 不能重复搜索同样的内容
        if let keyword = self.keyword, keyword == searchText {
            return
        }
        
        self.keyword = searchText
        
        guard !searchText.isEmpty else {
            return
        }
        
        searchFeedsWithKeyword(searchText, mode: .init)
    }
    
    var isFirstAppear = true
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "搜索话题"
        
        if formulaCateogry != nil {
            searchBar.placeholder = "搜索公式类型的话题"
        }
        
        if profileUser != nil {
            searchBar.placeholder = "搜索用户的话题"
        }
        
        feeds = []
        
        searchBarBottomLineView.alpha = 0
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchFeedsViewController.didRecieveMenuWillShowNotification(_:)), name: Notification.Name.UIMenuControllerWillShowMenu, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchFeedsViewController.didRecieveMenuWillHideNotification(_:)), name: Notification.Name.UIMenuControllerWillHideMenu, object: nil)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isFirstAppear {
            
            delay(0.3) { [weak self] in
                self?.searchBar.setShowsCancelButton(true, animated: true)
            }
            delay(0.4) { [weak self] in
                self?.searchBar.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        recoverSearchTransition()
        moveUpsearchBar()
        
        isFirstAppear = false
    }
    
    deinit {
        printLog("\(self)" + "已经释放")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func didRecieveMenuWillShowNotification(_ notification: Notification) {
        
        guard let menu = notification.object as? UIMenuController, let selectedIndexPathForMenu = selectedIndexPathForMenu, let cell = tableView.cellForRow(at: selectedIndexPathForMenu) as? SearchFeedBasicCell else {
            return
        }
        
        let bubbleFrame = cell.convert(cell.messageTextView.frame, to: view)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIMenuControllerWillShowMenu, object: nil)
        menu.setTargetRect(bubbleFrame, in: view)
        menu.setMenuVisible(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchFeedsViewController.didRecieveMenuWillShowNotification(_:)), name: Notification.Name.UIMenuControllerWillShowMenu, object: nil)
        
        tableView.deselectRow(at: selectedIndexPathForMenu, animated: true)
    }
    
    @objc fileprivate func didRecieveMenuWillHideNotification(_ notification: Notification) {
        
        selectedIndexPathForMenu = nil
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "showProfileView":
            
            let vc = segue.destination as! ProfileViewController
            
            if let indexPath = sender as? IndexPath {
                
                let discoveredUser = feeds[indexPath.row].creator
                vc.prepare(with: discoveredUser)
            }
             prepareOriginalNavigationControllerDelegate()
            
        case "showCommentView":
            
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
                }
            }
             prepareOriginalNavigationControllerDelegate()
            
        case "showFormulaDetail":
            
            let vc = segue.destination as! FormulaDetailViewController
            
            guard let indexPath = sender as? IndexPath,
                let feed = feeds[safe: indexPath.row],
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
            prepareOriginalNavigationControllerDelegate()
            
        default:
            break
        }
    }
}


extension SearchFeedsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] _ in
            self?.searchBarBottomLineView.alpha = 1
            
        }, completion: nil)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        
        if isKeywordHot {
            isKeywordHot = false
            
            keyword = nil
            feeds = []
            tableView.reloadData()
            
            searchBar.becomeFirstResponder()
            
        } else {
            
            searchBar.resignFirstResponder()
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] _ in
                self?.searchBarBottomLineView.alpha = 0
                }, completion: { finished in
            })
            
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        isKeywordHot = false
        
        triggerSearchTaskWithSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboard()
    }
    
}

// MARK: TableView Delegate & DataSource
extension SearchFeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate enum Section: Int {
        case feed = 0
        case loadMore
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .feed:
            return feeds.count
            
        case .loadMore:
            return feeds.isEmpty ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        func cellForFeed(_ feed: DiscoverFeed) -> UITableViewCell {
            
            switch feed.category {
            case .text:
                let cell: SearchFeedBasicCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            case .url:
                let cell: SearchFeedURLCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            case .formula:
                let cell: SearchFeedFormulaCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
                
            case .image:
                if feed.imageAttachmentsCount <= SearchFeedsViewController.feedNormalImagesCount {
                    let cell: SearchFeedNormalImagesCell = tableView.dequeueReusableCell(for: indexPath)
                    return cell
                } else {
                    let cell: SearchFeedAnyImagesCell = tableView.dequeueReusableCell(for: indexPath)
                    return cell
                }
            default:
                let cell: SearchFeedBasicCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
            }
        }
        
        switch section {
        case .feed:
            let feed = feeds[indexPath.row]
            return cellForFeed(feed)
            
        case .loadMore:
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        func configureCell(with feed: DiscoverFeed, atCell cell: UITableViewCell) {
            
            guard let cell = cell as? SearchFeedBasicCell else {
                return
            }
            
            cell.tapAvatarAction = { [weak self] cell in
                
                if let indexPath = tableView.indexPath(for: cell) {
                    self?.hideKeyboard()
                    self?.performSegue(withIdentifier: "showProfileView", sender: indexPath)
                }
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
                    let _ = self,
                    let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            
            let layout = SearchFeedsViewController.layoutPool.feedCellLayoutOfFeed(feed)
            
            switch feed.category {
                
            case .text:
                
                cell.configureCell(with: feed, layout: layout, keyword: keyword)
                
            case .url:
            
                guard let cell = cell as? SearchFeedURLCell else {
                    break
                }
                
                cell.configureCell(with: feed, layout: layout, keyword: keyword)
                
                cell.tapURLInfoAction = { [weak self] URL in
                    self?.cube_openURL(URL)
                }
                
            case .formula:
                
                guard let cell = cell as? SearchFeedFormulaCell else {
                    break
                }
                
                cell.configureCell(with: feed, layout: layout, keyword: keyword)
                
                cell.tapFormulaInfoAction = { [weak self] cell in
                    guard
                        let cell = cell,
                        let indexPath = tableView.indexPath(for: cell) else {
                            return
                    }
                    self?.performSegue(withIdentifier: "showFormulaDetail", sender: indexPath)
                }
                
            case .image:
                
                let tapImagesAction: tapMediaActionTypealias = { [weak self] transitionView, image, imageAttachments, index in
                    
                    let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewController(withIdentifier: "MediaPreviewViewController") as! MediaPreviewViewController
                    
                    vc.startIndex = index
                    let frame = transitionView.convert(transitionView.bounds, to: self?.view)
                    vc.previewImageViewInitalFrame = frame
                    vc.bottomPreviewImage = image
                    
                    vc.afterDismissAction = { [weak self] in
                        self?.view.window?.makeKeyAndVisible()
                    }
                    
                    vc.previewMedias = imageAttachments.map { PreviewMedia.attachmentType($0) }
                    
                    mediaPreviewWindow.rootViewController = vc
                    mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                    mediaPreviewWindow.makeKeyAndVisible()
                }
                
                if feed.imageAttachmentsCount <= SearchFeedsViewController.feedNormalImagesCount {
                    
                    guard let cell = cell as? SearchFeedNormalImagesCell else {
                        break
                    }
                    
                    cell.configureCell(with: feed, layout: layout, keyword: keyword)
                    
                    cell.tapMediaAction = tapImagesAction
                    
                } else {
                    
                    guard let cell = cell as? SearchFeedAnyImagesCell else {
                        break
                    }
                    
                    cell.configureCell(with: feed, layout: layout, keyword: keyword)
                    cell.tapMediaAction = tapImagesAction

                }
                
            default:
                break
            }
        }
        
        switch section {
        case .feed:
            
            let feed = feeds[indexPath.row]
            configureCell(with: feed, atCell: cell)
            
        case .loadMore:
            
            guard let cell = cell as? LoadMoreTableViewCell else {
                break
            }
            
            guard canLoadMore else {
                cell.isLoading = false
                break
            }
            
            if !cell.isLoading {
                cell.isLoading = true
            }
            
            if let keyword = self.keyword {
                searchFeedsWithKeyword(keyword, mode: .loadMore, finish: {
                    
                    delayTask(0.5, work: { [weak cell] in
                        cell?.isLoading = false
                        
                    })
                })
                
            } else {
                cell.isLoading = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return 0
        }
        
        switch section {
            
        case .feed:
            let feed = feeds[indexPath.row]
            return SearchFeedsViewController.layoutPool.heightOfFeed(feed)
            
        case .loadMore:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        hideKeyboard()
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
            
        case .feed:
            performSegue(withIdentifier: "showCommentView", sender: indexPath)
            break
            
        case .loadMore:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        selectedIndexPathForMenu = indexPath
        
        guard let _ = tableView.cellForRow(at: indexPath) as? SearchFeedBasicCell else {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == #selector(UIResponder.copy(_:)) {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchFeedBasicCell else {
            return
        }
        
        if action == #selector(UIResponder.copy(_:)) {
            UIPasteboard.general.string = cell.messageTextView.text
        }
    }
}
