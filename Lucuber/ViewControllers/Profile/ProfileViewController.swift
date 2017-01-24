//
//  ProfileViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import Kingfisher

public enum ProfileUser {
    
    case discoverUser(AVUser)
    case userType(RUser)
    
    
    var userID: String {
        switch self {
        case .discoverUser(let avUser):
            if let objectId = avUser.objectId {
                return objectId
            }
            
        case .userType(let ruser):
            return ruser.lcObjcetID
        }
        
        return ""
    }
    var isMe: Bool {
        
        guard
            let currentUser = AVUser.current(),
            let currentUserId = currentUser.objectId else {
           return false
        }
        
        switch self {
        case .discoverUser(let avUser):
           return avUser.objectId ?? "" == currentUserId
            
        case .userType(let rUser):
           return rUser.lcObjcetID == currentUserId
            
        }
    }
    
    var nickname: String {
        
        switch self {
        case .discoverUser(let avUser):
            if let nickname = avUser.nickname(), !nickname.isEmpty {
                return nickname
            }
            
        case .userType(let ruser):
            if !ruser.nickname.isEmpty {
                return ruser.nickname
            }
        }
        return "没有昵称"
 
    }
    
    var username: String {
        
        switch self {
        case .discoverUser(let avUser):
            if let username = avUser.username, !username.isEmpty {
                return username
            }
            
        case .userType(let ruser):
            if !ruser.username.isEmpty {
                return ruser.username
            }
        }
        return "没有用户名"
    }
    
    public var cubeCategoryMasterCount: Int {
        
        switch self {
        case .discoverUser(let avUser):
            if let list = avUser.cubeCategoryMasterList() {
                return list.count
            }
            
        case .userType(let ruser):
            return ruser.cubeCategoryMasterList.count
        }
        return 0
    }
    
    public var cubeScoresCount: Int {
        
        switch self {
        case .discoverUser(let avUser):
            if let list = avUser.cubeScoresList() {
                return list.count
            }
            
        case .userType(let ruser):
            return ruser.cubeScoresList.count
        }
        return 0
    }
    
    public func cellCubeCategory(atIndexPath indexPath: IndexPath) -> String? {
        
        var categoryString: String?
        
        switch self {
        case .discoverUser(let avUser):
            
            if let list = avUser.cubeCategoryMasterList() {
                categoryString = list[indexPath.item]
            }
            
        case .userType(let ruser):
            categoryString = ruser.cubeCategoryMasterList[indexPath.item].categoryString
        }
        
        return categoryString
    }
    
    public func cellCubeScore(atIndexPath indexPath: IndexPath) -> CubeScores? {
        
        var cubeScores: CubeScores?
        
        switch self {
        case .discoverUser(let avUser):
            if let list = avUser.cubeScoresList() {
                if let key = Array(list.keys)[safe: indexPath.item] {
                    let scores = CubeScores()
                    scores.categoryString = key
                    scores.scoreTimerString = list[key] ?? ""
                    cubeScores = scores
                }
            }
            
        case .userType(let ruser):
            
            if !ruser.cubeScoresList.isEmpty {
                cubeScores = ruser.cubeScoresList[indexPath.item]
            }
        }
        
        return cubeScores
    }
}

final class ProfileViewController: UIViewController, CanShowFeedsViewController, SearchTrigeer {
    
    var showProfileViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)?
    var showCommentViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)?
    var showFormulaDetailViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)?
    var showFormulaFeedsViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)?
    
    var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    lazy var searchTransition: SearchTransition = {
        return SearchTransition()
    }()
    
    public var profileUser: ProfileUser?
    
    fileprivate var feeds: [DiscoverFeed]?
    fileprivate var feedAttachments: [ImageAttachment?]?
    
    var profileUserIsMe = true {
        didSet {
            if !profileUserIsMe {
                
            } else {
                
                let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .plain, target: self, action: #selector(ProfileViewController.showSettings(sender:)))
                
                customNavigationItem.rightBarButtonItem = settingsBarButtonItem
                NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.createdFeed(_:)), name: Config.NotificationName.createdFeed, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.deletedFeed(_:)), name: Config.NotificationName.deletedFeed, object: nil)
            }
        }
    }
    
  
    
    fileprivate var statusBarShouldLight = false
    fileprivate var noNeedToChangeStatusBar = false
    
    @IBOutlet weak var topShadowImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerNib(of: ProfileHeaderCell.self)
            collectionView.registerNib(of: ProfileFooterCell.self)
            collectionView.registerNib(of: ProfileSeparationLineCell.self)
            collectionView.registerNib(of: ProfileMasterCell.self)
            collectionView.registerNib(of: ProfileScoreCell.self)
            collectionView.registerNib(of: ProfileFeedsCell.self)
            collectionView.registerNib(of: CubeCategoryCell.self)
            collectionView.registerHeaderNibOf(ProfileSectionHeaderReusableView.self)
            collectionView.registerFooterClassOf(UICollectionReusableView.self)
            collectionView.alwaysBounceVertical = true
        }
    }
    
    fileprivate lazy var customNavigationItem: UINavigationItem = UINavigationItem(title: "Tychooo")
    fileprivate lazy var customNavigationBar: UINavigationBar = {
        
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        bar.tintColor = UIColor.white
        bar.tintAdjustmentMode = .normal
        bar.alpha = 0
        bar.setItems([self.customNavigationItem], animated: false)
        bar.backgroundColor = UIColor.clear
        bar.isTranslucent = true
        bar.shadowImage = UIImage()
        bar.barStyle = UIBarStyle.blackTranslucent
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont.navigationBarTitle()]
        bar.titleTextAttributes = textAttributes
        
        return bar
    }()
    
    fileprivate lazy var shareView: ProfileShareView = {
        let rect = CGRect(x: 0, y: 0, width: 120, height: 120)
        let share = ProfileShareView(frame: rect)
        //self.view.addSubview(share)
        return share
    }()
    
    func setBackButtonWithTitle() {
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(ProfileViewController.back(_:)))
        
        customNavigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc fileprivate func back(_ sender: AnyObject) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if statusBarShouldLight {
            return UIStatusBarStyle.lightContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    fileprivate lazy var collectionViewWidth: CGFloat = {
        return self.collectionView.bounds.width
    }()
    
    fileprivate lazy var sectionLeftEdgeInset: CGFloat = {
        return Config.Profile.leftEdgeInset
    }()
    
    fileprivate lazy var sectionRightEdgeInset: CGFloat = {
        return Config.Profile.rightEdgeInset
    }()
    
    fileprivate lazy var sectionBottomEdgeInset: CGFloat = {
        return 0
    }()
    
    fileprivate  var introductionText: String  {
        
        guard let profileUser = self.profileUser else { return "还未填写自我介绍" }
        
        switch profileUser {
            
        case .discoverUser(let avUser):
            if let introduction = avUser.introduction(), !introduction.isEmpty {
                return introduction
            }
            
        case .userType(let user):
            
            if user.isMe {
                guard let realm = try? Realm(), let me = currentUser(in: realm) else {
                    return "还未填写自我介绍"
                }
                
                if let introduction = me.introduction, !introduction.isEmpty {
                    return introduction
                }
            }
            
            if let introduction = user.introduction, !introduction.isEmpty {
               return introduction
            }
        }
        return "还未填写自我介绍"
    }
    
    fileprivate var footerCellHeight: CGFloat {
        let attributes = [NSFontAttributeName: Config.Profile.introductionFont]
        let labelWidth = self.collectionViewWidth - (Config.Profile.leftEdgeInset + Config.Profile.rightEdgeInset)
        let rect = (self.introductionText as NSString).boundingRect(with: CGSize(width: labelWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return 10 + 24 + 4 + 18 + 10 + ceil(rect.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "个人主页"
        view.addSubview(customNavigationBar)
        automaticallyAdjustsScrollViewInsets = false
        
        ImageCache.default.calculateDiskCacheSize(completion:  { size in
            
            let cacheSize = Double(size)/1000000
            printLog("Kingfisher.ImageCache cacheSize: \(cacheSize) MB")
            
            if cacheSize > 300 {
                ImageCache.default.cleanExpiredDiskCache()
            }
        })
        
        if let profileUser = profileUser {
            
            switch profileUser {
                
            case .discoverUser(let avUser):
                guard let realm = try? Realm() else {
                    break
                }
                
                var user: RUser?
                try? realm.write {
                    user = getOrCreatRUserWith(avUser, inRealm: realm)
                }
                if let user = user {
                    self.profileUser = ProfileUser.userType(user)
                    updateProfileCollectionView()
                }
                
            case .userType(_):
                break
            }
            
        } else {
            
            guard let realm = try? Realm(), let oldMe = currentUser(in: realm) else {
                return
            }
            
            // 显示 My 时, 需要更新用户 Info
            fetchUser(with: oldMe.lcObjcetID, failureHandeler: { [weak self] reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
                self?.profileUser = ProfileUser.userType(oldMe)
                self?.updateProfileCollectionView()
                
            }, completion: { [weak self] avUser in
               
                var newMe: RUser?
                try? realm.write {
                    newMe =  getOrCreatRUserWith(avUser, inRealm: realm)
                }
                if let newMe = newMe {
                    self?.profileUser = ProfileUser.userType(newMe)
                    self?.updateProfileCollectionView()
                }
            })
        }
        
        profileUserIsMe = profileUser?.isMe ?? false
        
        if let profileLayout = collectionView.collectionViewLayout as? ProfileLayout {
            
            profileLayout.scrollUpAction = { [weak self] progress in
                
                guard let strongSelf = self else { return }
                
                let indexPath = IndexPath(item: 0, section: Section.header.rawValue)
                
                if let coverCell = strongSelf.collectionView.cellForItem(at: indexPath) as? ProfileHeaderCell {
                    
                    let beginChangePercentage: CGFloat = 1 - 64 / strongSelf.collectionView.bounds.width * profileAvatarAspectRatio
                    let normalizedProgressForChange: CGFloat = (progress - beginChangePercentage) / (1 - beginChangePercentage)
                    
                    coverCell.avatarBlurImageView.alpha = progress < beginChangePercentage ? 0 : normalizedProgressForChange
                    
                    let shadowAlpha = 1 - normalizedProgressForChange
                    
                    if shadowAlpha < 0.2 {
                        strongSelf.topShadowImageView.alpha = progress < beginChangePercentage ? 1 : 0.2
                    } else {
                        strongSelf.topShadowImageView.alpha = progress < beginChangePercentage ? 1 : shadowAlpha
                    }
                }
            }
        }
        
        if let gestures = navigationController?.view.gestureRecognizers {
            for recognizer in gestures {
                if recognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    collectionView.panGestureRecognizer.require(toFail: recognizer as! UIScreenEdgePanGestureRecognizer)
                    printLog("Require UIScreenEdgePanGestureRecognizer")
                    break
                }
            }
        }
        
        if let tabBarController = tabBarController {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController.tabBar.bounds.height, right: 0)
        }
        
        if let profileUser = profileUser {
            switch profileUser {
            case .discoverUser(let avUser):
                customNavigationItem.title = avUser.nickname() ?? "Detail"
                
            case .userType(let rUser):
                customNavigationItem.title = rUser.nickname
                updateProfileCollectionView()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.updateProfileCollectionView), name: Config.NotificationName.newMyInfo, object: nil)
        
        if profileUserIsMe {
            remindUserToReview()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        printLog("个人主页控制器已释放" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        statusBarShouldLight = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1.0
        
        statusBarShouldLight = false
        
        if noNeedToChangeStatusBar {
            statusBarShouldLight = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        updateProfileCollectionView()
    }
    
    func updateProfileCollectionView() {
        if let profileUser = profileUser {
            switch profileUser {
            case .discoverUser(let avUser):
                customNavigationItem.title = avUser.nickname() ?? "Detail"
            case .userType(let rUser):
                customNavigationItem.title = rUser.nickname
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc fileprivate func createdFeed(_ sender: Notification) {
        
        guard feeds != nil else {
            return
        }
        
        let feed = sender.object as! DiscoverFeed
        feeds!.insert(feed, at: 0)
        
        updateFeedAttachmentsAfterUpdateFeeds()
    }
    
    @objc fileprivate func deletedFeed(_ sender: Notification) {
        
        guard feeds != nil else {
            return
        }
        
        let feedID = sender.object as! String
        var indexOfDeletedFeed: Int?
        for (index, feed) in feeds!.enumerated() {
            if feed.objectId! == feedID {
                indexOfDeletedFeed = index
                break
            }
        }
        guard let index = indexOfDeletedFeed else {
            return
        }
        feeds!.remove(at: index)
        
        updateFeedAttachmentsAfterUpdateFeeds()
    }
    
    fileprivate func updateFeedAttachmentsAfterUpdateFeeds() {
        
        feedAttachments = feeds!.map({ feed -> ImageAttachment? in
            if let attachment = feed.attachment {
                if case let .images(attachments) = attachment {
                    return attachments.first
                }
            }
            return nil
        })
        
        updateProfileCollectionView()
    }
    
    @objc private func showSettings(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSettingInfo", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "showEditMaster":
            break
            
        case "showSearchFeeds":
            
            let vc = segue.destination as! SearchFeedsViewController
            vc.hidesBottomBarWhenPushed = true
            
            vc.profileUser = profileUser
            prepareSearchTransition()
            
            vc.originalNavigationControllerDelegate = self.originalNavigationControllerDelegate
            
        case "showFeedsView":
            
            let vc = segue.destination as! FeedsViewController
            if
                let info = sender as? [String: Any],
                let profileUser = info["profileUser"] as? ProfileUser,
                let feeds = info["feeds"] as? [DiscoverFeed] {
                vc.profileUser = profileUser
                vc.feeds = feeds
            }
            vc.hideRightBarItem = true
            
        case "showProfileView":
            showProfileViewControllerAction?(segue, sender)
            recoverOriginalNavigationDelegate()
            
        case "showCommentView":
            showCommentViewControllerAction?(segue, sender)
            recoverOriginalNavigationDelegate()
        case "showFormulaDetail":
            showFormulaDetailViewControllerAction?(segue, sender)
            recoverOriginalNavigationDelegate()
        case "showFormulaFeeds":
            showFormulaFeedsViewControllerAction?(segue, sender)
            recoverOriginalNavigationDelegate()
        default:
            break
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case header = 0
        case footer
        case master
        case separationLine
        case score
        case separationLine2
        case feeds
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .header:
            return 1
            
        case .footer:
            return 1
            
        case .master:
            return  profileUser?.cubeCategoryMasterCount ?? 0
            
        case .score:
            return  profileUser?.cubeScoresCount ?? 0
            
        case .separationLine:
            return 0
            
        case .feeds:
            return 1
            
        case .separationLine2:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .header:
            let cell: ProfileHeaderCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let profileUser = profileUser {
                switch profileUser {
                case .discoverUser(let avUser):
                    cell.configureWithDiscoverUser(avUser)
                case .userType(let ruser):
                    cell.configureWithRUser(ruser)
                }
            }
            
            cell.updatePrettyColorAction = { [weak self] prettyColor in
                self?.customNavigationBar.tintColor = prettyColor
                
                let textAttributes = [
                    NSForegroundColorAttributeName: prettyColor,
                    NSFontAttributeName: UIFont.navigationBarTitle()
                ]
                self?.customNavigationBar.titleTextAttributes = textAttributes
            }
            
            return cell
            
        case .footer:
            let cell: ProfileFooterCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let profileUser = profileUser {
                cell.configureWithProfileUser(profileUser, introduction: introductionText)
            }
            
            return cell
            
        case .master:
            
            let cell: CubeCategoryCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let profileUser = profileUser {
                
                switch profileUser {
                case .discoverUser(let avUser):
                    
                    if let list = avUser.cubeCategoryMasterList() {
                        cell.categoryString = list[indexPath.item]
                    }
                    
                case .userType(let ruser):
                    
                    if !ruser.cubeCategoryMasterList.isEmpty {
                        cell.categoryString = ruser.cubeCategoryMasterList[indexPath.item].categoryString
                    }
                }
            }
            
            return cell
            
        case .separationLine:
            let cell: ProfileSeparationLineCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
            
        case .score:
            let cell: ProfileScoreCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let profileUser = profileUser {
                cell.scores = profileUser.cellCubeScore(atIndexPath: indexPath)
            }
            return cell
            
        case .separationLine2:
            let cell: ProfileSeparationLineCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
            
        case .feeds:
            let cell: ProfileFeedsCell = collectionView.dequeueReusableCell(for: indexPath)
            
            cell.configureWithProfileUser(profileUser, feedAttachments: feedAttachments, completion: { [weak self] feeds, feedAttachments in
                self?.feeds = feeds
                self?.feedAttachments = feedAttachments
            })
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .header:
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width * profileAvatarAspectRatio)
            
        case .footer:
            return CGSize(width: collectionView.bounds.width, height: footerCellHeight)
            
        case .master:
            
            let categoryString = profileUser?.cellCubeCategory(atIndexPath: indexPath) ?? ""
            
            let rect = (categoryString as NSString).boundingRect(with: CGSize(width: CGFloat(FLT_MAX), height: CubeCategoryCell.height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            
            return CGSize(width: rect.width + 24, height: CubeCategoryCell.height)
            
        case .separationLine:
            return CGSize(width: collectionView.bounds.width, height: 1)
            
        case .score:
            return CGSize(width: collectionView.bounds.width, height: 40)
            
        case .separationLine2:
            return CGSize(width: collectionView.bounds.width, height: 1)
            
        case .feeds:
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let header: ProfileSectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError()
            }
            
            switch section {
                
            case .master:
                
                header.titleLabel.text = "擅长"
                
                if profileUserIsMe {
                    header.tapAction = { [weak self] in
                        self?.performSegue(withIdentifier: "showEditMaster", sender: nil)
                    }
                } else {
                    header.accessoryImageView.isHidden = true
                }
                
                return header
            case .score:
                
                header.titleLabel.text = "成绩"
                
                if profileUserIsMe {
                    header.tapAction = { [weak self] in
                        self?.performSegue(withIdentifier: "showEditScore", sender: nil)
                    }
                } else {
                    header.accessoryImageView.isHidden = true
                }
                
                return header
                
            default:
                header.titleLabel.text = ""
            }
            
            return header
            
        } else {
            
            let footer: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
            
        case .header:
            return UIEdgeInsets(top: 0, left: 0, bottom: sectionBottomEdgeInset, right: 0)
            
        case .footer:
            return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
            
        case .master:
            return UIEdgeInsets(top: 0, left: sectionLeftEdgeInset, bottom: 15, right: sectionRightEdgeInset)
            
        case .separationLine:
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            
        case .score:
            return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
            
            
        case .separationLine2:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        case .feeds:
            return UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let profileUser = profileUser else {
            return CGSize.zero
        }
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        let normalHeight: CGFloat = 40
        
        if profileUser.isMe {
            
            switch section {
                
            case .master:
                return CGSize(width: collectionViewWidth, height: normalHeight)
                
            case .score:
                return CGSize(width: collectionViewWidth, height: normalHeight)
                
            default:
                return CGSize.zero
            }
            
        } else {
            
            switch section {
                
            case .master:
                let height: CGFloat = profileUser.cubeCategoryMasterCount > 0 ? normalHeight : 0
                return CGSize(width: collectionViewWidth, height: height)

            case .score:
                let height: CGFloat = profileUser.cubeScoresCount > 0 ? normalHeight : 0
                return CGSize(width: collectionViewWidth, height: height)
                
            default:
                return CGSize.zero
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
            
        case .feeds:
            guard let profileUser = profileUser else {
                break
            }
            
            let info: [String: Any] = [
                "profileUser": profileUser,
                "feeds": feeds ?? [],
                ]
            self.performSegue(withIdentifier: "showFeedsView", sender: info)
            
        default:
            break
        }
        
        
    }
    
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if shareView.progress >= 1.0 {
            shareView.shareActionAnimationAndDoFurther {
                
            }
            
        }
    }
}

