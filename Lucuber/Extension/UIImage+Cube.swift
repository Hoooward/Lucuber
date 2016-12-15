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


extension UIImage {
    
    public func scaleToSideLenght(sidLenght: CGFloat) -> UIImage {
        let pixelSideLenght = sidLenght * UIScreen.main.scale
        let pixelWidth = size.width * scale
        let pixelHeight = size.height * scale
        
        
//        printLog("pixelSideLenght = \(pixelSideLenght)")
//        printLog("scale = \(UIScreen.main.scale)")
//        printLog("imagescale = \(scale)")
//        printLog("pixelWidth = \(pixelWidth)")
//        printLog("pixelHeight = \(pixelHeight)")
        var newSize = CGSize.zero
        
        if pixelWidth > pixelHeight {
            
            if pixelHeight < pixelSideLenght {
                return self
            }
            
            let newHeight = pixelSideLenght
            let newWidth = (newHeight / pixelHeight) * pixelWidth
            newSize = CGSize(width: floor(newWidth), height: floor(newHeight))
            
        } else {
            
            if pixelWidth < pixelSideLenght {
                return self
            }
            
            let newWidth = pixelSideLenght
            let newHeight = (newWidth / pixelWidth) * pixelHeight
            newSize = CGSize(width: floor(newWidth), height: floor(newHeight))
            
        }
        
        if scale == UIScreen.main.scale {
            let newSize = CGSize(width: floor(newSize.width / scale), height: floor(newSize.height / scale))
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = newImage {
                return image
            }
            
            return self
            
        } else {
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = newImage {
                return image
            }
            
            return self
            
        }
        
        
    }
}

extension UIImage {
    
    public func fixRotation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        let width = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat(M_PI))
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            
        default:
            break
        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        let bitsPerComponent = self.cgImage?.bitsPerComponent
        let colorSpace = self.cgImage?.colorSpace
        let bitmapInfo = self.cgImage?.bitmapInfo
        
     
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        context?.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            
            context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: height, height: width))
            
        default:
            
            context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        let cgImage = context?.makeImage()
        
        return UIImage(cgImage: cgImage!)
    }
    
    func getRotationTransformWithTargetSize(size: CGSize) -> CGAffineTransform {
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            
        default:
            break

        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }

        return transform
    }
    
    public func resizeTo(targetSize: CGSize, quality: CGInterpolationQuality) -> UIImage? {
        
        let drawTransposed: Bool
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
      
        return resizeTo(targetSize: targetSize, transform: getRotationTransformWithTargetSize(size: targetSize), drawTransposed: drawTransposed , quality: quality)
        
    }
    
    public func resizeTo(targetSize: CGSize, transform: CGAffineTransform, drawTransposed: Bool, quality: CGInterpolationQuality) -> UIImage? {
        
        let newRect = CGRect(origin: CGPoint.zero, size: targetSize)
        let transposedRect = CGRect(origin: CGPoint.zero, size: CGSize(width: targetSize.height, height: targetSize.width))
        
        let bitsPerComponent = self.cgImage?.bitsPerComponent
        let colorSpace = self.cgImage?.colorSpace
        let bitmapInfo = self.cgImage?.bitmapInfo
        
        let context = CGContext(data: nil, width: Int(newRect.width), height: Int(newRect.height), bitsPerComponent: bitsPerComponent!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        context?.concatenate(transform)
        context?.interpolationQuality = quality
        
        context?.draw(self.cgImage!, in: drawTransposed ? transposedRect : newRect)
        
        if let newCGImge = context?.makeImage() {
            return UIImage(cgImage: newCGImge)
        }
        
        return nil
    }
}

public enum MessageImageBubbleDirection {
    case left
    case right
}

extension UIImage {

    public func maskWithImage(_ maskImage: UIImage) -> UIImage {

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        let context = UIGraphicsGetCurrentContext()

        var transform = CGAffineTransform.identity.concatenating(CGAffineTransform(scaleX: 1.0, y: -1.0))
    
        transform = transform.concatenating(CGAffineTransform(translationX: 0.0, y: self.size.height))
        context?.concatenate(transform)
        
        let drawRect = CGRect(origin: CGPoint.zero, size: self.size)
        
        context?.clip(to: drawRect, mask: maskImage.cgImage!)
        context?.draw(self.cgImage!, in: drawRect)
        
        let roundImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()

        return roundImage
    }

    public struct BubbleMaskImage {

        public static let left: UIImage = {
            let scale = UIScreen.main.scale
            let orientation: UIImageOrientation = .up
            let image = UIImage(named: "left_tail_image_bubble")!
            var maskImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: orientation)
            maskImage = maskImage.resizableImage(withCapInsets: UIEdgeInsets(top: 25, left: 27, bottom: 20, right: 20), resizingMode:
            UIImageResizingMode.stretch)
            return maskImage
        }()

        public static let right: UIImage = {
            let scale = UIScreen.main.scale
            let orientation: UIImageOrientation = .up
            let image = UIImage(named: "right_tail_image_bubble")!
            var maskImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: orientation)
            maskImage = maskImage.resizableImage(withCapInsets: UIEdgeInsets(top: 24, left: 20, bottom: 20, right: 27), resizingMode:
            UIImageResizingMode.stretch)
            return maskImage
        }()
    }

    public func cropToAspectRatio(aspectRatio: CGFloat) -> UIImage {
        let size = self.size

        let originalAspectRatio = size.width / size.height

        var rect = CGRect.zero

        if originalAspectRatio > aspectRatio {
            let width = size.height * aspectRatio
            rect = CGRect(x: (size.width - width) * 0.5, y: 0, width: width, height: size.height)
        } else if originalAspectRatio < aspectRatio {
            let height = size.width / aspectRatio
            rect = CGRect(x: 0, y: (size.height - height) * 0.5, width: size.width, height: height)
        } else {
            return self
        }

        let cgImage = self.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: cgImage)
    }

    public func bubbleImage(with direction: MessageImageBubbleDirection, size: CGSize) -> UIImage {

        let maskImage: UIImage

        if direction == .left {
            maskImage = BubbleMaskImage.left
        } else {
            maskImage = BubbleMaskImage.right
        }

        let bubbleImage = cropToAspectRatio(aspectRatio: size.width / size.height).resizeTo(targetSize: size).maskWithImage(maskImage)
        
        return bubbleImage
    }

}

































