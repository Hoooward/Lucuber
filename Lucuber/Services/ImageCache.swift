//
//  ImageCache.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher

final class CubeImageCache {
   
    static let shard = CubeImageCache()
    
    var cache = NSCache<AnyObject, AnyObject>()
    let cacheQueue = DispatchQueue.init(label: "ImageChacheQueue")
    let cacheAttachmentQueue = DispatchQueue(label: "ImageChacheAttachmentQueue")
    
    
    public enum imageExtension {
        case jpeg
        case png
    }
    
    class func attachmentOriginKeyWithURLString(URLString: String) -> String {
        return "attachment-cube-\(URLString)"
    }
    
    class func attachmentSideLengthKeyWithURLString(URLString: String, sideLenght: CGFloat) -> String {
        return "attachment-\(sideLenght)-\(URLString)"
    }
   
    
    func storeAlreadyUploadImageToCache(with image: UIImage, imageExtension: imageExtension, imageURLString: String) {
        guard let attachmentURL = NSURL(string: imageURLString) else {
            return
        }
        
        let options: KingfisherOptionsInfo = [
            .callbackDispatchQueue(cacheAttachmentQueue),
            .scaleFactor(UIScreen.main.scale)
        ]
        
        let originKey = CubeImageCache.attachmentOriginKeyWithURLString(URLString: attachmentURL.absoluteString!)
        
        // 尝试在本地寻找原始图片
        ImageCache.default.retrieveImage(forKey: originKey, options: options, completionHandler: {
            (findImage, cacheType) in
            
            
            if let _ = findImage {
                return
            }
            
            let resultImage = image
            
            var originalData: Data?
            
            switch imageExtension {
            case .jpeg:
                originalData = UIImageJPEGRepresentation(resultImage, 1.0)
            case .png:
                originalData = UIImagePNGRepresentation(resultImage)
                
            }
            
            ImageCache.default.store(resultImage, original: originalData, forKey: originKey,  toDisk: true, completionHandler: {
                        
            })
            
        })
    }
    
    func imageOfAttachment(attachment: ImageAttachment, withSideLenght: CGFloat?, imageExtesion: imageExtension, completion:@escaping (_ url: NSURL, _ image: UIImage?, _ cacheType: CacheType) -> Void)  {
        
        guard let attachmentURL = NSURL(string: attachment.URLString) else {
            return
        }
        
        var sideLenght: CGFloat = 0
        if let withSideLenght = withSideLenght {
            sideLenght = withSideLenght
        }
        
        let originKey = CubeImageCache.attachmentOriginKeyWithURLString(URLString: attachmentURL.absoluteString!)
        let sideLengtKey = CubeImageCache.attachmentSideLengthKeyWithURLString(URLString: attachmentURL.absoluteString!, sideLenght: sideLenght)
        
        let options: KingfisherOptionsInfo = [
            .callbackDispatchQueue(cacheAttachmentQueue),
            .scaleFactor(UIScreen.main.scale)
        ]
        
        ImageCache.default.retrieveImage(forKey: sideLengtKey, options: options, completionHandler: {
            (image, cacheType) in
            
            // 本地查找对应边长的 Image
            if let image = image {
                DispatchQueue.main.async {
                    completion(attachmentURL, image, cacheType)
                }
                
            } else { // 如果没有在本地找到
                
                // 尝试在本地寻找原始图片
                ImageCache.default.retrieveImage(forKey: originKey, options: options, completionHandler: {
                    (image, cacheType) in
                    
                    if let image = image {
                        var resultImage = image
                        
                        // 如果找到,进行切割,并保存
                        if sideLenght != 0 {
                            
                            resultImage = image.scaleToSideLenght(sidLenght: sideLenght)
                            
                            var originalData: Data?
                            
                            switch imageExtesion {
                            case .jpeg:
                                originalData = UIImageJPEGRepresentation(resultImage, 1.0)
                            case .png:
                                originalData = UIImagePNGRepresentation(image)
                                
                            }
                            
                            ImageCache.default.store(resultImage, original: originalData, forKey: sideLengtKey,  toDisk: true, completionHandler: {
                                
                            })
                            
                        }
                        
                        DispatchQueue.main.async {
                            completion(attachmentURL, resultImage, cacheType)
                        }
                        
                    } else {
                        
                   
                        // 如果没有找到, 下载
                       ImageDownloader.default.downloadImage(with: attachmentURL as URL, options: options, progressBlock: { (receivedSize, totalSize) in
                            
                            }, completionHandler: { (image, error, imageURL, originalData) in
                                
                                if let image = image {
                                    
                                    ImageCache.default.store(image, original: originalData, forKey: originKey,  toDisk: true, completionHandler: {
                                        
                                    })
                                    
                                    var resultImage = image
                                    
                                    if sideLenght != 0 {
                                        
                                        resultImage = image.scaleToSideLenght(sidLenght: sideLenght)
                                        
                                        var originalData: Data?
                                        
                                        switch imageExtesion {
                                        case .jpeg:
                                            originalData = UIImageJPEGRepresentation(resultImage, 1.0)
                                        case .png:
                                            originalData = UIImagePNGRepresentation(image)
                                            
                                        }
                                        
                                        ImageCache.default.store(resultImage, original: originalData, forKey: sideLengtKey,  toDisk: true, completionHandler: {
                                            
                                        })
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        completion(attachmentURL, resultImage, cacheType)
                                    }

                                } else {
                                    
                                    DispatchQueue.main.async {
                                        completion(attachmentURL, nil, cacheType)
                                    }

                                }
                        })
                        
                    }
                })
                
            }
    
        })
    }
}
