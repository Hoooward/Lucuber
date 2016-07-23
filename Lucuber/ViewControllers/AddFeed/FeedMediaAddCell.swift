//
//  FeedMediaAddCell.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedMediaAddCell: UICollectionViewCell {
    
    
    @IBOutlet weak var mediaAddImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaAddImage.tintColor = UIColor.cubeTintColor()
        contentView.backgroundColor = UIColor.cubeBackgroundColor()
    }
    
}
