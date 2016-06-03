//
//  MainNavigationController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barStyle = .Black
        navigationBar.barTintColor = UIColor.cubeTintColor()
        navigationBar.tintColor = UIColor.cubeTintColor()
        for view in navigationBar.subviews {
            if view.isKindOfClass(UIImageView.classForCoder()) {
                view.hidden = true
            }
        }
        
        let imageView = UIImageView(image: UIImage(named: navigationBarImage))
        
        imageView.frame = CGRectMake(0, -20, screenWidth, 64)
        navigationBar.addSubview(imageView)
    }
    
    

}
