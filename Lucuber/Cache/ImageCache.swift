//
//  ImageCache.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import Alamofire

final class CubeImageCache {
   
    static let shard = CubeImageCache()
    
    var cache = NSCache<AnyObject, AnyObject>()
    let cacheQueue = DispatchQueue(label: "cacheQueue")
    let cacheAttachmentQueue = DispatchQueue(label: "ImageCacheAttachmentQueue")
    
    
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

    func imageOfMessage(message: Message, withSize size: CGSize, direction: MessageImageBubbleDirection, completion: @escaping ( _ loadingProgress : Double, UIImage?) -> Void) {

        let imageKey = message.imageKey as NSString

        // 查看缓存
        if let image = cache.object(forKey: imageKey) as? UIImage {
            completion(1.0, image)

        } else {

            let messageID = message.localObjectID

            var fileName = message.localAttachmentName
            if message.mediaType == MessageMediaType.video.rawValue {
                fileName = message.localThumbnailName
            }

            var imageUrlString = message.attachmentURLString
            if message.mediaType == MessageMediaType.video.rawValue {
                imageUrlString = message.thumbnailURLString
            }

            let imageDownloadState = message.downloadState

            let progress: Double = fileName.isEmpty ? 0.01 : 0.5

            // 优先显示缩略图

            let thumbnailKey = ("thumbnail" + (imageKey as String)) as NSString

            if let thumbnail = cache.object(forKey: thumbnailKey ) as? UIImage {
                completion(progress, thumbnail)

            } else {

                cacheQueue.async {

                    guard let realm = try? Realm() else {
                        return
                    }

                    if let message = messageWith(messageID, inRealm: realm) {

                        if let blurThumbnailImage = blurThumbnailImageOfMessage(message) {
                            
                            let bubbleThumbnailImage = blurThumbnailImage.bubbleImage(with: direction, size: size).decodedImage()

                            self.cache.setObject(bubbleThumbnailImage, forKey: thumbnailKey)
                            
                            DispatchQueue.main.async {
                                
                                completion(progress, bubbleThumbnailImage)
                            }
                            
                            
                            
                        }
                        
                    } else {
                        
                        // 可以设置个占位图片
                    }

                }
            }
            
            cacheQueue.async {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                if imageDownloadState == MessageDownloadState.downloaded.rawValue {
                    
                    if !fileName.isEmpty, let imageFileUrl = FileManager.cubeMessageImageURL(with: fileName), let image = UIImage(contentsOfFile: imageFileUrl.path) {
                        
                        let messageImage = image.bubbleImage(with: direction, size: size).decodedImage()
                        
                        self.cache.setObject(messageImage, forKey: imageKey)
                        
                        DispatchQueue.main.async {
                            completion(1.0, messageImage)
                        }
                        
                        return
                        
                    } else {
                        
                        // 下载
                        
                        if let message = messageWith(messageID, inRealm: realm) {
                            
                            try? realm.write {
                                message.downloadState = MessageDownloadState.noDownload.rawValue
                            }
                        }
                    }
                }
                
                if imageUrlString.isEmpty {
                    DispatchQueue.main.async {
                        completion(1.0, nil)
                    }
                    return
                }


                if let message = messageWith(messageID, inRealm: realm) {

                    // 先下载 atachment
                    let attachmentUrlString = message.attachmentURLString
                    
                    if !attachmentUrlString.isEmpty, let url = URL(string: attachmentUrlString) {
                        
                        Alamofire.request(url).downloadProgress(queue: self.cacheQueue, closure: {
                            progress in
                            
                        }).responseData(queue: self.cacheQueue, completionHandler: { dataResponse in
                            
                            if let data = dataResponse.data {
                                
                                var fileName = message.localAttachmentName
                                
                                if fileName.isEmpty {
                                    fileName = UUID().uuidString
                                }
                                
                                realm.beginWrite()
                                switch message.mediaType {
                                    
                                case MessageMediaType.image.rawValue:
                                    
                                    _ = FileManager.saveMessageImageData(data, withName: fileName)
                                    
                                    message.localAttachmentName = fileName
                                    message.downloadState = MessageDownloadState.downloaded.rawValue
                                    
                                    // 如果是 image 类型的 Message 任务完成
                                    if let image = UIImage(data: data) {
                                        
                                        let messageImage = image.bubbleImage(with: direction, size: size).decodedImage()
                                        
                                        self.cache.setObject(messageImage, forKey: imageKey)
                                        
                                        DispatchQueue.main.async {
                                            completion(1.0, messageImage)
                                        }
                                    }
                                    
                                case MessageMediaType.video.rawValue:
                                    
                                    _ = FileManager.saveMessageVideoData(data, withName: fileName)
                                    message.localAttachmentName = fileName
                                    if !message.localThumbnailName.isEmpty {
                                        message.downloadState = MessageDownloadState.downloaded.rawValue
                                    }
                                    
                                case  MessageMediaType.audio.rawValue:
                                    
                                    _ = FileManager.saveMessageAudioData(messageAudioData: data, withName: fileName)
                                    message.localAttachmentName = fileName
                                    message.downloadState = MessageDownloadState.downloaded.rawValue
                                    
                                default: break
                                    
                                }
                                try? realm.commitWrite()
                            }
                            
                            // attachment 下载完成后, 如果是 video 类型的 Message, 下载缩略图
                            
                            if message.mediaType == MessageMediaType.video.rawValue {
                                
                                let thumbnailUrlString = message.thumbnailURLString
                                
                                if !thumbnailUrlString.isEmpty, let url = URL(string:thumbnailUrlString) {
                                    
                                    Alamofire.request(url).downloadProgress(queue: self.cacheQueue, closure: { progress in
                                        
                                    }).responseData(queue: self.cacheQueue, completionHandler: { dataResponse in
                                        
                                        
                                        if let data = dataResponse.data {
                                            
                                            var fileName = message.localThumbnailName
                                            
                                            if fileName.isEmpty {
                                                fileName = UUID().uuidString
                                            }
                                            
                                            realm.beginWrite()
                                            _ = FileManager.saveMessageImageData(data, withName: fileName)
                                            message.localThumbnailName = fileName
                                            if !message.localAttachmentName.isEmpty {
                                                message.downloadState = MessageDownloadState.downloaded.rawValue
                                            }
                                            
                                            if let image = UIImage(data: data) {

                                                let messageImage = image.bubbleImage(with: direction, size: size).decodedImage()
                                                
                                                self.cache.setObject(messageImage, forKey: imageKey)
                                                
                                                DispatchQueue.main.async {
                                                    completion(1.5, messageImage)
                                                    
                                                }
                                            }
                                        }
                                        
                                    })
                                    
                                }
                                
                            }
                            
                        })
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        completion(1.0, nil)
                    }
                }
                
            }
            
        }
        
    }
    
}
