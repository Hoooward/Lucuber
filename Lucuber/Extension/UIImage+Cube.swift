//
//  UIImage+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func largestCenteredSquareImage() -> UIImage {
        
        let scale = self.scale
        
        let originalWidth = self.size.width * scale
        let originalHeight = self.size.height * scale
        
        let edge: CGFloat
        
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let corpSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        
        let imageRef = self.cgImage!.cropping(to: corpSquare)!
        
        return UIImage(cgImage: imageRef, scale: scale, orientation: self.imageOrientation)
    }
    
    public func resizeTo(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio = targetSize.width / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        let scale = UIScreen.main.scale
        
        let newSize: CGSize
        
        if (widthRatio > heightRatio) {
            newSize = CGSize(width: scale * floor(size.width * heightRatio), height: scale * floor(size.height * heightRatio))
        } else {
            newSize = CGSize(width: scale * floor(size.width * widthRatio), height: scale * floor(size.height * widthRatio))
        }
        
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
