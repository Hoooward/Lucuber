//
//  BorderButton.swift
//  Lucuber
//
//  Created by Howard on 9/13/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class BorderButton: UIButton {

    // MARK: - Properties
    
    var cornerRadius: CGFloat = 6
    var borderColor: UIColor = UIColor.cubeTintColor()
    var borderWidth: CGFloat = 1
    
    override var isEnabled: Bool {
        
        willSet {
            let newBorderColor = newValue ? borderColor : UIColor(white: 0.8, alpha: 1.0)
            layer.borderColor = newBorderColor.cgColor
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
    
    
    // MARK: - Life Cycle
    
    override func didMoveToSuperview() {
         super.didMoveToSuperview()
        
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        
    }
    
    // MARK: - Action & Target
    
    func showAccessory() {
        
        accessoryImageView.tintColor = borderColor
        
        addSubview(accessoryImageView)
        
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailing = NSLayoutConstraint(item: accessoryImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10)
        
        let centerY = NSLayoutConstraint(item: accessoryImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([trailing, centerY])
        
    }
    
    
    
}





















