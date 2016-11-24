//
//  HeaderReusableView.swift
//  Lucuber
//
//  Created by Howard on 16/7/2.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class HeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor.lightGray
        titleLabel.textColor = color
        countLabel.textColor = color
    }
    
    public func configerView(with type: Type?, count: Int) {
       
        guard let type = type else {
            return
        }
   
        titleLabel.text = type.sectionText
        countLabel.text = "共 \(count) 个"
    }
    
}

