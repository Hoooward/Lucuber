
//
//  FeedMediaCell.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = UIColor.cubeBackgroundColor()
        imageView.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        imageView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedMediaCell.deleteImage(_:)))
        
        deleteImageView.addGestureRecognizer(tapGesture)
    }
    
    func deleteImage(sender: UIGestureRecognizer) {
        
        print("删除图片")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureWithImage(image: UIImage) {
        imageView.image = image
        deleteImageView.hidden = false
    }
}
