//
//  PhotoCell.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageManager: PHImageManager?
    
    var imageAsset: PHAsset? {
        willSet {
            guard let imageAsset = newValue else {
                return
            }
            
            let option = PHImageRequestOptions()
            option.synchronous = true
            option.version = .Current
            option.deliveryMode = .HighQualityFormat
            option.resizeMode = .Exact
            option.networkAccessAllowed = true
            
            self.imageManager?.requestImageForAsset(imageAsset, targetSize: CGSize(width: 120, height: 120), contentMode: .AspectFill, options: option ) {
                [weak self] image, info in
                
                self?.imageView.image = image
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.redColor()
    }
}
