//
//  FeedMediaAddCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class FeedMediaAddCell: UICollectionViewCell {
    
    @IBOutlet weak var addImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addImage.tintColor = UIColor.cubeTintColor()
        contentView.backgroundColor = UIColor.cubeBackgroundColor()
    }
    
}
