//
//  MainTabbarController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import LucuberTimer

class MainTabbarController: UITabBarController {
    
    
    enum Tab: Int {
        
        case formula = 0
        case score
        case feeds
        case timer
        case profile
        
        var title: String {
            
            switch self {
            case .formula:
                return "公式"
            case .score:
                return "成绩"
            case .feeds:
                return "话题"
            case .timer:
                return "计时器"
            case .profile:
                return "我"
            }
        }
        
        var canBeenDoubleTap: Bool {
            switch self {
            case .formula, .feeds:
                return true
            default:
                return false
            }
        }
    }
    
    fileprivate var checkDoubleTapTimer: Timer?
    
    fileprivate var previousTab: Tab = .feeds
    var tab: Tab? {
        didSet {
            if let tab = tab {
                self.selectedIndex = tab.rawValue
            }
        }
    }
    
    fileprivate var hasFirstTapOnTabWhenItIsAtTop = false {
        willSet {
            checkDoubleTapTimer?.invalidate()
            
            if newValue {
                let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainTabbarController.checkDoubleTap(_:)), userInfo: nil, repeats: false)
                checkDoubleTapTimer = timer
            }
        }
    }
    
    @objc fileprivate func checkDoubleTap(_ timer: Timer) {
        hasFirstTapOnTabWhenItIsAtTop = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        view.backgroundColor = UIColor.white
        
        self.tabBar.tintColor = UIColor.cubeTintColor()
        
     
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabbarController.updateSelectedItem), name: Config.NotificationName.changedLaunchStyle, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabbarController.updateTabbarStyle), name: NSNotification.Name.tabbarItemTextEnableDidChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       updateTabbarStyle()
        
    }
    
    func updateSelectedItem() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.lauchStyle == .message {
                selectedIndex = Tab.feeds.rawValue
                
                if let nav = viewControllers?[Tab.feeds.rawValue] as? UINavigationController {
                    if let vc = nav.topViewController as? FeedsContainerViewController {
                        vc.currentOption = .subscribe
                    }
                }
            }
        }
    }
    
    func updateTabbarStyle() {
        let noNeedTitle: Bool
        
        if let tabBarItemTextEnabled = UserDefaults.tabbarItemTextEnabled() {
            noNeedTitle = !tabBarItemTextEnabled
        } else {
            noNeedTitle = true
        }
        
        
        if noNeedTitle {
            // 将 UITabBarItem 的 image 下移一些，也不显示 title 了
            if let items = tabBar.items {
                for item in items {
                    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                    item.title = nil
                }
            }
            
        } else {
            if let items = tabBar.items {
                for i in 0..<items.count {
                    let item = items[i]
                    item.imageInsets = UIEdgeInsets.zero
                    item.title = Tab(rawValue: i)?.title
                }
            }
        }
    }
    
    deinit {
        checkDoubleTapTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainTabbarController: UITabBarControllerDelegate {
  
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard
            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return
        }
        
        // 相等才继续，确保第一次 tap 不做事
        guard tab == previousTab else {
            previousTab = tab
            hasFirstTapOnTabWhenItIsAtTop = false
            return
        }
        
        if tab.canBeenDoubleTap {
            if let vc = nvc.topViewController as? CanScrollsToTop, let scrollView = vc.scrollView {
                if scrollView.isAtTop {
                    if !hasFirstTapOnTabWhenItIsAtTop {
                        hasFirstTapOnTabWhenItIsAtTop = true
                        return
                    }
                }
            }
        }
        
        if let vc = nvc.topViewController as? CanScrollsToTop {
            
            vc.scrollsToTopIfNeed(otherwise: { [weak self, weak vc] in
                
                guard tab.canBeenDoubleTap else { return }
                
                guard let scrollView = vc?.scrollView else { return }
                
                if let vc = vc as? FeedsViewController {
                    if self?.hasFirstTapOnTabWhenItIsAtTop ?? false {
                        if !vc.feeds.isEmpty && !vc.refreshControl.isRefreshing {
                            scrollView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
                            vc.refreshControl.beginRefreshing()
                            vc.tryRefreshOrGetNewFeeds()
                            self?.hasFirstTapOnTabWhenItIsAtTop = false
                        }
                    }
                }
                
//                if let vc = vc as? FormulaViewController {
//                    if self?.hasFirstTapOnTabWhenItIsAtTop ?? false {
//                     
//                    }
//                }
           
            })
        }
    }
}
