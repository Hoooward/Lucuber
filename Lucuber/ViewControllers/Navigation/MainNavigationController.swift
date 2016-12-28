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
        
        navigationBar.setBackgroundImage(UIImage(named: "navigationbarBackgroundWhite"), for: .any, barMetrics: .default)
//        let imageView = UIImageView(image: UIImage(named: "navigationbarBackgroundWhite"))
//        imageView.frame = CGRect(x: 0 , y: -20, width: UIScreen.main.bounds.width, height: 64)
//        navigationBar.insertSubview(imageView, at: 0)
        
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (self.viewControllers.count <= 1) {
            return false
        }
        return true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
