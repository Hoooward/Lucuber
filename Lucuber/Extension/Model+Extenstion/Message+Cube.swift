//
//  Message+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/15.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


extension Message {
    
    var fixedImageSize: CGSize {
        
        let imagePreferredWidth = Config.ChatCell.mediaPreferredWidth
        let imagePreferredHeight = Config.ChatCell.mediaPreferredHeight
        let imagePreferredAspectRatio: CGFloat = 4.0 / 3.0
        
        if let (imageWidth, imageHeight) = imageMetaOfMessage(message: self) {
            
            let aspectRatio = imageWidth / imageHeight
            
            let realImagePreferredWidth = max(imagePreferredWidth, ceil(Config.ChatCell.mediaMinHeight * aspectRatio))
            let realImagePreferredHeight = max(imagePreferredHeight, ceil(Config.ChatCell.mediaMinWidth / aspectRatio))
            
            if aspectRatio >= 1 {
                var size = CGSize(width: realImagePreferredWidth, height: ceil(realImagePreferredWidth / aspectRatio))
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinWidth)
                
                return size
                
            } else {
                var size = CGSize(width: realImagePreferredHeight * aspectRatio, height: realImagePreferredHeight)
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinHeight)
                
                return size
            }
            
        } else {
            let size = CGSize(width: imagePreferredWidth, height: ceil(imagePreferredWidth / imagePreferredAspectRatio))
            
            return size
        }
    }
}
