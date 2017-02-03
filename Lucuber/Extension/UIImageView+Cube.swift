//
//  UIImageView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher

private var activityIndicatorKey: Void?
private var showActivityIndicatorWhenLoadingKey: Void?

extension UIImageView {
    
     var activityIndicator: UIActivityIndicatorView? {
        return objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView
    }
    
     func setActivityIndicator(activityIndicator: UIActivityIndicatorView?) {
        objc_setAssociatedObject(self, &activityIndicatorKey, activityIndicator, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var showActivityIndicatorWhenLoading: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, &showActivityIndicatorWhenLoadingKey) as? NSNumber else {
                return false
            }
            
            return result.boolValue
        }
        
        set {
            if showActivityIndicatorWhenLoading == newValue {
                return
            }
            
            if newValue {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
                
                
                indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
                indicator.hidesWhenStopped = true
                addSubview(indicator)
                
                setActivityIndicator(activityIndicator: indicator)
                
            } else {
                activityIndicator?.removeFromSuperview()
                setActivityIndicator(activityIndicator: nil)
            }
            
            objc_setAssociatedObject(self, &showActivityIndicatorWhenLoadingKey, NSNumber(value: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var imageAttachmentURLKey: Void?
extension UIImageView {
    
    fileprivate var imageAttachmentURL: NSURL? {
        return objc_getAssociatedObject(self, &imageAttachmentURLKey) as? NSURL
    }
    
    fileprivate func setImageAttachmentURL(URL: NSURL) {
        objc_setAssociatedObject(self, &imageAttachmentURLKey, URL, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func setImageWithURL(URL: NSURL) {
        
        self.kf.setImage(with: ImageResource(downloadURL: URL as URL), placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receivedSize, totalSize) in
            
            
            }, completionHandler: { (image, error, cacheType, imageURL) in
        })
    }
}

// MARK: - Feed
extension UIImageView {
    
    public func cube_setImageAtFeedCellWithAttachment(attachment: ImageAttachment, withSize size: CGSize?) {
        
        guard let attachmentURL = NSURL(string: attachment.URLString) else {
            return
        }
        
        let showActivityIndicatorWhenLoading = self.showActivityIndicatorWhenLoading
        
        var activityIndicator: UIActivityIndicatorView? = nil
        
        if showActivityIndicatorWhenLoading {
            
            activityIndicator = self.activityIndicator
            activityIndicator?.isHidden = false
            activityIndicator?.startAnimating()
        }
        
        setImageAttachmentURL(URL: attachmentURL)
        
        CubeImageCache.shard.imageOfAttachment(attachment: attachment, withSideLenght: size?.width, imageExtesion: CubeImageCache.imageExtension.jpeg, completion: {
            [weak self] url, image, cacheType in
            guard
                let strongSelf = self,
                let attachmentURL = strongSelf.imageAttachmentURL,
                attachmentURL == url else {
                    return
            }
            
            if cacheType != .memory {
                UIView.transition(with: strongSelf, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    strongSelf.image = image
                }, completion: nil)
            }
            
            strongSelf.image = image
            
            activityIndicator?.stopAnimating()
            
        })
    }
}

// MARK: - Formula
extension UIImageView {
    
    public func cube_setImageAtFormulaCell(with URLString: String, size: CGSize?) {
        guard let URL = NSURL(string: URLString) else {
            return
        }
        let attachment = ImageAttachment(metadata: nil, URLString: URLString, image: nil)
        
        let showActivityIndicatorWhenLoading = self.showActivityIndicatorWhenLoading
        
        var activityIndicator: UIActivityIndicatorView? = nil
        
        if showActivityIndicatorWhenLoading {
            
            activityIndicator = self.activityIndicator
            activityIndicator?.isHidden = false
            activityIndicator?.startAnimating()
        }
        
        setImageAttachmentURL(URL: URL)
        
        CubeImageCache.shard.imageOfAttachment(attachment: attachment, withSideLenght: size?.width,imageExtesion: CubeImageCache.imageExtension.png, completion: {
            [weak self] url, image, cacheType in
            
            guard
                let strongSelf = self,
                let attachmentURL = strongSelf.imageAttachmentURL,
                attachmentURL == url else {
                    return
            }
            
            if cacheType != .memory {
                UIView.transition(with: strongSelf, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    strongSelf.image = image
                }, completion: nil)
            }
            
            strongSelf.image = image
            
            activityIndicator?.stopAnimating()
            
        })
    }
}

// MARK: - Message
private var messageImageAssociatedKey: Void?
extension UIImageView {
    
    private var cube_messageImageKey: String? {
        return objc_getAssociatedObject(self, &messageImageAssociatedKey) as? String
    }
    
    private func cube_setMessageImageKey(messageMapImageKey: String) {
        objc_setAssociatedObject(self, &messageImageAssociatedKey, messageMapImageKey, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func cube_setImage(with message: Message , size: CGSize, direction: MessageImageBubbleDirection, completion: @escaping (Double, UIImage?) -> Void) {
        
        let imageKey = message.imageKey
        
        cube_setMessageImageKey(messageMapImageKey: imageKey)
        
        CubeImageCache.shard.imageOfMessage(message: message, withSize: size, direction: direction, completion: {
            [weak self] progress, image in
            
            guard let strongSelf = self, let _imageKey = strongSelf.cube_messageImageKey, _imageKey == imageKey else {
                return
            }
            
            completion(progress, image)
            
        })
        
    }
}
