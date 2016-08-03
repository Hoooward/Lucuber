//
//  UIScrollView+Cube.swift
//  Lucuber
//
//  Created by Howard on 8/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation

extension UIScrollView {
    
    func cube_zoomToPoint(zoomPoint: CGPoint, withScale scale: CGFloat) {
        let zoomRect = cube_zoomRectWithZoomPoint(zoomPoint, scale: scale)
        zoomToRect(zoomRect, animated: true)
    }
    
    func cube_zoomRectWithZoomPoint(zoomPoint: CGPoint, scale: CGFloat) -> CGRect {
        var scale = min(scale, maximumZoomScale)
        scale = max(scale, minimumZoomScale)
        
        let zoomFactor = 1.0 / self.zoomScale
        
        let translatedZoomPoint = CGPoint(
            x: (zoomPoint.x + self.contentOffset.x) * zoomFactor,
            y: (zoomPoint.y + self.contentOffset.y) * zoomFactor
        )
        
        let destinationRectWidth = self.bounds.width / scale
        let destinationRectHeight = self.bounds.height / scale
        let destinationRect = CGRect(
            x: translatedZoomPoint.x - destinationRectWidth * 0.5,
            y: translatedZoomPoint.y - destinationRectHeight * 0.5,
            width: destinationRectWidth,
            height: destinationRectHeight
        )
        
        return destinationRect
    }
    
    func cube_zoomToPoint(zoomPoint: CGPoint, withScale scale: CGFloat, animationDuration: NSTimeInterval, animationCurve: UIViewAnimationCurve) {
        let zoomRect = cube_zoomRectWithZoomPoint(zoomPoint, scale: scale)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(animationCurve)
        
        self.zoomToRect(zoomRect, animated: false)
        
        UIView.commitAnimations()
    }
}
