//
//  RotationButton.swift
//  Lucuber
//
//  Created by Howard on 8/8/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RotationButton: UIButton {
    
    enum Style {
        case Square
        case Cercle
    }

    var rotation: Rotation? {
        didSet {
//            if let rotation = rotation {
//                upDateButtonStyleWithRotation(rotation)
//            }
        }
    }

    func upDateButtonStyleWithRotation(style: Style , rotation: Rotation, animation: Bool = false) {

        switch rotation {
           
        case .FR(_, _):
            
            var normalImage = ""
            var seletcedImage = ""
            
            switch style {
            case .Square:
                normalImage = "FR_square_groy"
                seletcedImage = "FR_square"
                
            case .Cercle:
                normalImage = "FR_gray"
                seletcedImage = "FR"
     
            }
            
            setBackgroundImage(UIImage(named: normalImage), forState: .Normal)
            setBackgroundImage(UIImage(named: seletcedImage), forState: .Selected)

            
         
        case .FL(_, _):
            
            var normalImage = ""
            var seletcedImage = ""
            
            switch style {
            case .Square:
                normalImage = "FL_square_groy"
                seletcedImage = "FR_square"
                
            case .Cercle:
                normalImage = "FL_gray"
                seletcedImage = "FL"
                
            }
            
            setBackgroundImage(UIImage(named: normalImage), forState: .Normal)
            setBackgroundImage(UIImage(named: seletcedImage), forState: .Selected)

        
        case .BL(_, _):
            
            var normalImage = ""
            var seletcedImage = ""
            
            switch style {
            case .Square:
                normalImage = "BL_square_groy"
                seletcedImage = "BL_square"
                
            case .Cercle:
                normalImage = "BL_gray"
                seletcedImage = "BL"
                
            }
            
            setBackgroundImage(UIImage(named: normalImage), forState: .Normal)
            setBackgroundImage(UIImage(named: seletcedImage), forState: .Selected)

            
        case .BR(_, _):
            
            var normalImage = ""
            var seletcedImage = ""
            
            switch style {
            case .Square:
                normalImage = "BR_square_groy"
                seletcedImage = "BR_square"
                
            case .Cercle:
                normalImage = "BR_gray"
                seletcedImage = "BR"
                
            }
            
            setBackgroundImage(UIImage(named: normalImage), forState: .Normal)
            setBackgroundImage(UIImage(named: seletcedImage), forState: .Selected)
        }
        
        if animation { POPAnimation() }
 
    }
    
    func POPAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = CFTimeInterval(1)
        animation.additive = true
        self.layer.addAnimation(animation, forKey: "pop")
    }
    
    override func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
        super.setBackgroundImage(image, forState: state)
        
    }
    
    
    // frome storyboard dont use this
    init(style: Style, rotation: Rotation) {
        super.init(frame: CGRectZero)
        self.rotation = rotation
        upDateButtonStyleWithRotation(style, rotation: rotation)
        
    }
    
    // to formula inputAccessoryView
    func makeSquareButton(rotation: Rotation) {
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
  

}
