//
//  UIImage+Cube.swift
//  Lucuber
//
//  Created by Howard on 7/26/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


extension UIImage {
    
    public func fixRotation() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        
        let width = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        
        let context = CGBitmapContextCreate(nil, Int(width), Int(height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageGetBitmapInfo(CGImage).rawValue)
        
        CGContextConcatCTM(context, transform)
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(context, CGRect(x: 0, y: 0, width: height, height: width), CGImage)
        default:
            CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height: height), CGImage)
        }
        
        let cgImage = CGBitmapContextCreateImage(context)!
        
        return UIImage(CGImage: cgImage)
    }
    
    
    
    func getRotationTransformWithTargetSize(size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        default:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        default:
            break
        }
        
        return transform
    }
    
    public func resizeToSize(targetSize: CGSize, quality: CGInterpolationQuality) -> UIImage? {
        //是否需要
        let drawTransposed: Bool
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored :
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        return resizeToSize(targetSize, transform: getRotationTransformWithTargetSize(targetSize), drawTransposed: drawTransposed, quality: quality)
        
    }
    
    public func resizeToSize(targetSize: CGSize, transform: CGAffineTransform, drawTransposed: Bool, quality: CGInterpolationQuality) -> UIImage? {
        
        let newRect = CGRect(origin: CGPointZero, size: targetSize)
        let transposedRect = CGRect(origin: CGPointZero, size: CGSize(width: targetSize.height, height: targetSize.width))
        
        let bitmapContext = CGBitmapContextCreate(nil, Int(newRect.width), Int(newRect.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageGetBitmapInfo(CGImage).rawValue)
        
        CGContextConcatCTM(bitmapContext, transform)
        CGContextSetInterpolationQuality(bitmapContext, quality)
        
        CGContextDrawImage(bitmapContext, drawTransposed ? transposedRect : newRect, CGImage)
        
        if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
            return UIImage(CGImage: newCGImage)
        }
        
        return nil
    }
}












