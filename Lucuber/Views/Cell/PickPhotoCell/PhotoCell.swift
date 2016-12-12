//
//  PhotoCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
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
            option.isSynchronous = true
            option.version = .current
            option.deliveryMode = .highQualityFormat
            option.resizeMode = .exact
            option.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: imageAsset, targetSize: CGSize(width: 120, height: 120), contentMode: PHImageContentMode.aspectFill, options: option, resultHandler: { [weak self] image, info in
                
                if let image = image {
                     self?.imageView.image = image
                    
                }
                
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
