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
    
    func imageOfAttachment(attachment: ImageAttachment, withSideLenght: CGFloat?, completion:(url: NSURL, image: UIImage?, cacheType: CacheType) -> Void)  {
        
        guard let attachmentURL = NSURL(string: attachment.URLString) else {
            return
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
                    completion(url: attachmentURL, image: image, cacheType: cacheType)
                }
                
            } else {
                
                Kingfisher.ImageCache.defaultCache.retrieveImageForKey(originKey, options: options, completionHandler: { (image, cacheType) in
                    if let image = image {
                        
                        var resultImage = image
                        
                        if sideLenght != 0 {
                            
                            resultImage = image.scaleToSideLenght(sideLenght)
                            
                            let originalData = UIImageJPEGRepresentation(resultImage, 1.0)
                            
                            Kingfisher.ImageCache.defaultCache.storeImage(resultImage, originalData: originalData, forKey: sideLengtKey, toDisk: true, completionHandler: { 
                            })
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                               completion(url: attachmentURL, image: resultImage, cacheType: cacheType)
                        }
                        
                    } else {
                        
                        ImageDownloader.defaultDownloader.downloadImageWithURL(attachmentURL, options: options, progressBlock: { (receivedSize, totalSize) in
                            
                            }, completionHandler: { (image, error, imageURL, originalData) in
                                
                                if let image = image {
                                    
                                    Kingfisher.ImageCache.defaultCache.storeImage(image, originalData: originalData, forKey: originKey, toDisk: true, completionHandler: nil)
                                    
                                    var resultImage = image
                                    
                                    if sideLenght != 0 {
                                        
                                        resultImage = image.scaleToSideLenght(sideLenght)
                                        
                                        let originalData = UIImageJPEGRepresentation(resultImage, 1.0)
                                        
                                        Kingfisher.ImageCache.defaultCache.storeImage(resultImage, originalData: originalData, forKey: sideLengtKey, toDisk: true, completionHandler: nil)
                                        
                                        
                                        
                                    }
                                    dispatch_async(dispatch_get_main_queue()) {
                                          completion(url: attachmentURL, image: resultImage, cacheType: cacheType)
                                    }
                                    
                                } else {
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                       completion(url: attachmentURL, image: nil, cacheType: cacheType)
                                    }
                                }
                        })
                        
                    }
                })
                
                
            }
        }
        
        
    }
    
}