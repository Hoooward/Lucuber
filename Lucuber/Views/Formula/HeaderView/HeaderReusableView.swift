//
//  HeaderReusableView.swift
//  Lucuber
//
//  Created by Howard on 16/7/2.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class HeaderReusableView: UICollectionReusableView {

    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.cubeTintColor()
    }
    
}
