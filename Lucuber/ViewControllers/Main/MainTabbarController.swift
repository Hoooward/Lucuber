//
//  MainTabbarController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
    }
    func makeUI() {
        tabBar.tintColor = UIColor.cubeTintColor()
    }

}
