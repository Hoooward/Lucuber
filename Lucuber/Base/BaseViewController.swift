//
//  BaseViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {
    
    var animatedOnNavigationBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController = navigationController else {
            return
        }
        
        navigationController.navigationBar.backgroundColor = nil
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.setBackgroundImage(nil, for: .default)
        
        let textAttributes: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.navgationBarTitle(),
            NSFontAttributeName: UIFont.navigationBarTitle()
        ]
        
        navigationController.navigationBar.titleTextAttributes = textAttributes
        navigationController.navigationBar.tintColor = nil
        
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animatedOnNavigationBar)
        }
    }
}
