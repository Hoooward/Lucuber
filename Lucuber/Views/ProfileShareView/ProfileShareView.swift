//
//  ProfileShareView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/31.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

final class ProfileShareView: UIView {
    
    public var progress: CGFloat = 0
    
    var animating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        layer.cornerRadius = frame.height / 2.0
        layer.masksToBounds = true
        
        let rect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        let imageView = UIImageView(frame: rect)
        
        imageView.image = UIImage(named: "icon_share")
        imageView.transform = CGAffineTransform.identity.scaledBy(x: 0.4, y: 0.4)
        
        imageView.tintColor = UIColor.cubeTintColor()
        
        imageView.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ progressNew: CGFloat) {
        
        if animating {
            return
        }
        
        alpha = progressNew
        
        self.progress = progressNew
        
        if alpha > 1 {
            return
        }
        
        transform = CGAffineTransform.identity.translatedBy(x: alpha, y: alpha)
        
    }
    
    func shareActionAnimationAndDoFurther(_ further: @escaping () -> Void) {
        animating = true
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
            self?.alpha = 0
            
            }, completion: { [weak self] finished in
                
                delay(0.5, clouser: {
                    further()
                    self?.animating = false
                })
                
                
        })
        
    }
    
    
    
}
