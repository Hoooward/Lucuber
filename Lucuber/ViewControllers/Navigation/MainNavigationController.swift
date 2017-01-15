//
//  MainNavigationController.swift

//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .default
        navigationBar.tintColor = UIColor.cubeTintColor()
        
        navigationBarLine.isHidden = true
//        navigationBar.setBackgroundImage(UIImage(named: "navigationbarBackgroundWhite"), for: .any, barMetrics: .default)
        
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        
        return true
    }
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToViewController(viewController, animated: false)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToRootViewController(animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
