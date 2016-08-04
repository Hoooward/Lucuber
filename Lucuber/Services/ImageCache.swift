//
//  ImageCache.swift
//  Lucuber
//
//  Created by Howard on 7/27/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import Kingfisher


final class ImageCache {
    
    static let shardInstance = ImageCache()
    
    let cache = NSCache()
    let cacheQueue = dispatch_queue_create("ImageChacheQueue", DISPATCH_QUEUE_SERIAL)
    let cacheAttachmentQueue = dispatch_queue_create("ImageChacheAttachmentQueue", DISPATCH_QUEUE_SERIAL)
    
    class func attachmentOriginKeyWithURLString(URLString: String) -> String {
        return "attachment-cube-\(URLString)"
    }
    
    class func attachmentSideLengthKeyWithURLString(URLString: String, sideLenght: CGFloat) -> String {
       return "attachment-\(sideLenght)-\(URLString)"
    }
    
    func imageOfAttachment(attachment: ImageAttachment, withSideLenght: CGFloat?) -> UIImage? {
        
        guard let attachmentURL = NSURL(string: attachment.URLString) else {
            return nil
        }
        
        var sideLenght: CGFloat = 0
        if let withSideLenght = withSideLenght {
           sideLenght = withSideLenght
        }
        
        let originKey = ImageCache.attachmentOriginKeyWithURLString(attachmentURL.absoluteString)
        let sideLengtKey = ImageCache.attachmentSideLengthKeyWithURLString(attachmentURL.absoluteString, sideLenght: sideLenght)
        
        let options: KingfisherOptionsInfo = [
            .CallbackDispatchQueue(cacheAttachmentQueue),
            .ScaleFactor(UIScreen.mainScreen().scale)
        ]
        
        Kingfisher.ImageCache.defaultCache.retrieveImageForKey(sideLengtKey, options: options) { (image, cacheType) in
            
            if let image = image {
                dispatch_async(dispatch_get_main_queue()) {
                    return image
                }
                
            } else {
                
                Kingfisher.ImageCache.defaultCache.retrieveImageForKey(originKey, options: options, completionHandler: { (image, cacheType) in
                    if let image = image {
                        
                        var resultImage = image
                        
                        if sideLenght != 0 {
                            
                            let pixelSideLenght = sideLenght * UIScreen.mainScreen().scale
                            
                            let pixelWidth = image.size.width * image.scale
                            let pixelHeight = image.size.width * image.scale
                            
                            if pixelWidth > pixelHeight {
                                
                            }
                            
                        }
                    }
                })
            }
        }
        
        
        return UIImage()
        
        
        
    }
    
}