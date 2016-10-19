//
//  UIScrollView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/16.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var isAtTop: Bool {
        
        return contentOffset.y == -contentInset.top
    }
    
    func customScrollsToTop() {
        
        let topPoint = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topPoint, animated: true)
    }
}


extension UIScrollView {
    
    func zoom(to zoomPoint: CGPoint, withScale scale: CGFloat) {
        let zoomRect = self.zoomRect(with: zoomPoint, scale: scale)
        self.zoom(to: zoomRect, animated: true)
    }
    
    func zoom(to zoomPoint: CGPoint, withScale scale: CGFloat,
                     animationDuration: TimeInterval,
                     animationCurve: UIViewAnimationCurve) {
        
        let zoomRect = self.zoomRect(with: zoomPoint, scale: scale)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(animationCurve)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        self.zoom(to: zoomRect, animated: false)
        
        UIView.commitAnimations()
        
    }
    
    func zoomRect(with zoomPoint: CGPoint, scale: CGFloat) -> CGRect {
        
        var scale = min(scale, maximumZoomScale)
        scale = max(scale, minimumZoomScale)
        
        let zoomFactor = 1.0 / self.zoomScale
        
        let translatedZoomPoint = CGPoint(
            x: (zoomPoint.x + self.contentOffset.x) * zoomFactor,
            y: (zoomPoint.y + self.contentOffset.y) * zoomFactor)
        
        let destinationRectWidth = self.bounds.width / scale
        let destinationRectHeight = self.bounds.height / scale
        let destinationRect = CGRect(
            x: translatedZoomPoint.x - destinationRectWidth * 0.5,
            y: translatedZoomPoint.y - destinationRectHeight * 0.5,
            width: destinationRectWidth,
            height: destinationRectHeight)
        
        return destinationRect
        
    }
    
}
