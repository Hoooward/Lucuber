//
//  RotationButton.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class RotationButton: UIButton {
    
    enum Style {
        case square
        case cercle
    }
    
    var rotation: Rotation?
    
    func updateButtonStyle(with rotationStyle: Style, rotation: Rotation, animation: Bool = false) {
        
        var normalImage = ""
        var selectedImage = ""
        
        switch rotation {
            
        case .FR(_, _):
            
            switch rotationStyle {
            case .square:
                normalImage = "FR_square_groy"
                selectedImage = "FR_square"
                
            case .cercle:
                normalImage = "FR_gray"
                selectedImage = "FR"
            }
            setBackgroundImage(UIImage(named: normalImage), for: .normal)
            setBackgroundImage(UIImage(named: selectedImage), for: .selected)
            
            
        case .FL(_, _):
            
            switch rotationStyle {
            case .square:
                
                normalImage = "FL_square_groy"
                selectedImage = "FR_square"
                
            case .cercle:
                normalImage = "FL_gray"
                selectedImage = "FL"
            }
            
            setBackgroundImage(UIImage(named: normalImage), for: .normal)
            setBackgroundImage(UIImage(named: selectedImage), for: .selected)
            
            
        case .BL(_, _):
            
            switch rotationStyle {
                
            case .square:
                normalImage = "BL_square_groy"
                selectedImage = "BL_square"
                
            case .cercle:
                normalImage = "BL_gray"
                selectedImage = "BL"
                
            }
            
            setBackgroundImage(UIImage(named: normalImage), for: .normal)
            setBackgroundImage(UIImage(named: selectedImage), for: .selected)
            
        case .BR(_, _):
            
            switch rotationStyle {
                
            case .square:
                normalImage = "BR_square_groy"
                selectedImage = "BR_square"
                
            case .cercle:
                normalImage = "BR_gray"
                selectedImage = "BR"
                
            }
            
            setBackgroundImage(UIImage(named: normalImage), for: .normal)
            setBackgroundImage(UIImage(named: selectedImage), for: .selected)
            
        }
        
        if animation {
            
            POPAnimation()
        }
        
    }
    
    func POPAnimation() {
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = CFTimeInterval(1)
        animation.isAdditive = true
        self.layer.add(animation, forKey: "pop")
    }
    
    // MARK: - Life Cycle
    init(style: Style, rotation: Rotation) {
        super.init(frame: CGRect.zero)
        self.rotation = rotation
        updateButtonStyle(with: style, rotation: rotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}






















        

