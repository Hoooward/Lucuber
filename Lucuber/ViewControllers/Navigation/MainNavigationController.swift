//
//  MainNavigationController.swift

//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .default
        navigationBar.tintColor = UIColor.cubeTintColor()
        
        navigationBarLine.isHidden = true
        
        
    }

}
