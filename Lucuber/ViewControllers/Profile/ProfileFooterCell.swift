//
//  ProfileFooterCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ProfileFooterCell: UICollectionViewCell {

    @IBOutlet weak var textView: ChatTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.isScrollEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textColor = UIColor.cubeGrayColor()
        textView.backgroundColor = UIColor.clear
        textView.tintColor = UIColor.black
        textView.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.cubeTintColor()
        ]
        
    }
}
