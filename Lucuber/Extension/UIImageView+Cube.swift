//
//  UIImageView+Cube.swift
//  Lucuber
//
//  Created by Howard on 7/26/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    
    public func setImageWithURL(URL: NSURL) {
        kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))], progressBlock: { (receivedSize, totalSize) in
            
            }) { (image, error, cacheType, imageURL) in
                
        }
    }
}