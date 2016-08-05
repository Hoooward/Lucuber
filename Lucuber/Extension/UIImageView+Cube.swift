//
//  UIImageView+Cube.swift
//  Lucuber
//
//  Created by Howard on 7/26/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation
import Kingfisher


private var activityIndicatorKey: Void?
private var showActivityIndicatorWhenLoadingKey: Void?

extension UIImageView {
    
    private var activityIndicator: UIActivityIndicatorView? {
        return objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView
    }
    
    private func setActivityIndicator(activityIndicator: UIActivityIndicatorView?) {
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
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                indicator.center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
                
                indicator.hidden = true
                indicator.hidesWhenStopped = true
                addSubview(indicator)
                
                setActivityIndicator(indicator)
                
            } else {
                activityIndicator?.removeFromSuperview()
                setActivityIndicator(nil)
            }
            
            objc_setAssociatedObject(self, &showActivityIndicatorWhenLoadingKey, NSNumber(bool: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


private var imageAttachmentURLKey: Void?

extension UIImageView {
    
    public func setImageWithURL(URL: NSURL) {
        kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))], progressBlock: { (receivedSize, totalSize) in
            
            }) { (image, error, cacheType, imageURL) in
                
        }
    }
    
    private var imageAttachmentURL: NSURL? {
        return objc_getAssociatedObject(self, &imageAttachmentURLKey) as? NSURL
    }
    
    private func setImageAttachmentURL(URL: NSURL) {
        objc_setAssociatedObject(self, &imageAttachmentURLKey, URL, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func cube_setImageAtFeedCellWithAttachment(attachment: ImageAttachment, withSize size: CGSize?) {
        
        guard let attachmentURL = NSURL(string: attachment.URLString) else {
            return
        }
        
        showActivityIndicatorWhenLoading = true
        
        
        if showActivityIndicatorWhenLoading {
           activityIndicator?.hidden = false
           activityIndicator?.startAnimating()
        }
        
        setImageAttachmentURL(attachmentURL)
        
        ImageCache.shardInstance.imageOfAttachment(attachment, withSideLenght: size?.width) { [weak self] (url, image, cacheType) in
        
            guard let strongSelf = self, let attachmentURL = strongSelf.imageAttachmentURL where attachmentURL == url else {
                return
            }
            
            if cacheType != .Memory {
                UIView.transitionWithView(strongSelf, duration: 0.2, options: .TransitionCrossDissolve, animations: { 
                    strongSelf.image = image
                    }, completion: nil)
            }
            
            strongSelf.image = image
            
            self?.activityIndicator?.stopAnimating()
        }
     
    }
}