//
//  ASImageNode+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import Navi
import Kingfisher
import AsyncDisplayKit

fileprivate var activityIndicatorKey: Void?
fileprivate var showActivityIndicatorWhenLoadingKey: Void?

extension ASImageNode {
    
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
                view.addSubview(indicator)
                
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

extension ASImageNode {
    
    fileprivate var imageAttachmentURL: NSURL? {
        return objc_getAssociatedObject(self, &imageAttachmentURLKey) as? NSURL
    }
    
    fileprivate func setImageAttachmentURL(URL: NSURL) {
        objc_setAssociatedObject(self, &imageAttachmentURLKey, URL, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension ASImageNode {
    
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
                UIView.transition(with: strongSelf.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    strongSelf.image = image
                }, completion: nil)
            }
            
            strongSelf.image = image
            
            activityIndicator?.stopAnimating()
            
        })
    }
}
