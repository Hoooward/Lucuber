//
//  PhotoCell.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.redColor()
    }
}
