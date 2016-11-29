//
//  MainNavigationController.swift

//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .default
        navigationBar.tintColor = UIColor.cubeTintColor()
        
        navigationBarLine.isHidden = true
        
        navigationBar.setBackgroundImage(UIImage(named: "navigationbarBackgroundWhite"), for: .any, barMetrics: .default)
//        let imageView = UIImageView(image: UIImage(named: "navigationbarBackgroundWhite"))
//        imageView.frame = CGRect(x: 0 , y: -20, width: UIScreen.main.bounds.width, height: 64)
//        navigationBar.insertSubview(imageView, at: 0)
        
        self.interactivePopGestureRecognizer?.delegate =  self
        
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (self.viewControllers.count <= 1) {
            return false
        }
        return true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        self.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    
}
