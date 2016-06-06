//
//  RegsinViewController.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegsinViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        self.navigationItem.backBarButtonItem?.title = "返回"
        navigationItem.title = "注册"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
