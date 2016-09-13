//
//  BorderButton.swift
//  Lucuber
//
//  Created by Howard on 9/13/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class BorderButton: UIButton {


    var cornerRadius: CGFloat = 6
    var borderColor: UIColor = UIColor.cubeTintColor()
    var borderWidth: CGFloat = 1
    
    
    override var enabled: Bool {
        
        willSet {
            let newBorderColor = newValue ? borderColor : UIColor(white: 0.8, alpha: 1.0)
            layer.borderColor = newBorderColor.CGColor
        }
    }
    
    var needShowAccessory: Bool = false {
        
        willSet {
            
            if newValue != needShowAccessory {
                
                if newValue {
                    showAccessory()
                    
                } else {
                    
                    accessoryImageView.removeFromSuperview()
                }
            }
            
        }
    }
    
    
    lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_accessory_mini"))
        return imageView
    }()
    
    
    override func didMoveToSuperview() {
         super.didMoveToSuperview()
        
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func showAccessory() {
        
        accessoryImageView.tintColor = borderColor
        addSubview(accessoryImageView)
        
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailing = NSLayoutConstraint(item: accessoryImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10)
        
        let centerY = NSLayoutConstraint(item: accessoryImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([trailing, centerY])
    }
    
    
    
}





















