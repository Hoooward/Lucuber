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

enum ProfileUser {
    
    case discoverUser(AVUser)
    case userType(RUser)
    
    
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
}

final class ProfileViewController: UIViewController {
    
    public var profileUser: ProfileUser?
    
    var profileUserIsMe = true {
        didSet {
            if !profileUserIsMe {
                
            } else {
                
                let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .plain, target: self, action: #selector(ProfileViewController.showSettings(sender:)))
                
                customNavigationItem.rightBarButtonItem = settingsBarButtonItem
                // TODO: - 创建 Feed 删除 Feed 的通知
            }
        }
    }
    
    @objc private func showSettings(sender: UIBarButtonItem) {
        
    }
    
    fileprivate var statusBarShouldLight = false
    fileprivate var noNeedToChangeStatusBar = false
    
    @IBOutlet weak var topShadowImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerNib(of: ProfileHeaderCell.self)
            collectionView.registerNib(of: ProfileFooterCell.self)
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
        bar.isTranslucent = true
        bar.shadowImage = UIImage()
        bar.barStyle = UIBarStyle.blackTranslucent
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont.navigationBarTitle()]
        bar.titleTextAttributes = textAttributes
        
        return bar
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if statusBarShouldLight {
            return UIStatusBarStyle.lightContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: - 清理缓存
        view.addSubview(customNavigationBar)
        
      
        

        
        if let profileUser = profileUser {
            
            switch profileUser {
                
            case .discoverUser(let avUser):
                guard let realm = try? Realm() else {
                    break
                }
                
                if let user =  userWith(avUser.objectId ?? "", inRealm: realm) {
                    
                    self.profileUser = ProfileUser.userType(user)
                    updateProfileCollectionView()
                }
                
            case .userType(_):
                break
            }
            
        } else {
            // 为空的话显示自己
            guard let realm = try? Realm(), let me = currentUser(in: realm) else {
                return
            }
            
            profileUser = ProfileUser.userType(me)
            
            updateProfileCollectionView()
            
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
        
        automaticallyAdjustsScrollViewInsets = false
        
        if let tabBarController = tabBarController {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController.tabBar.bounds.height, right: 0)
        }
        
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
    }
    
    func updateProfileCollectionView() {
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case header = 0
        case footer
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .header:
            return 1
            
        case .footer:
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .header:
            let cell: ProfileHeaderCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
            
        case .footer:
            let cell: ProfileFooterCell = collectionView.dequeueReusableCell(for: indexPath)
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
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
    }
    
}


