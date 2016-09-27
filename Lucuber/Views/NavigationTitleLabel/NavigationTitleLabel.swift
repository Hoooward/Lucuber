//
//  NavigationTitleLabel.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class NavigationTitleLabel: UILabel {
    
    init(title: String) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        
        text = title
        
        textAlignment = .center
        font = UIFont.navigationBarTitle() // make sure it's the same as system use
        textColor = UIColor.navgationBarTitle()
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
