//
//  RotationButton.swift
//  Lucuber
//
//  Created by Howard on 8/8/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RotationButton: UIButton {

    var rotation: Rotation? {
        didSet {
            if let rotation = rotation {
                upDateButtonStyleWithRotation(rotation)
            }
        }
    }

    func upDateButtonStyleWithRotation(rotation: Rotation) {
        
        switch rotation {
        case .FR(_, _):
            setBackgroundImage(UIImage(named: "FR_gray"), forState: .Normal)
            setBackgroundImage(UIImage(named: "FR"), forState: .Selected)

            
        case .FL(_, _):

            setBackgroundImage(UIImage(named: "FL_gray"), forState: .Normal)
            setBackgroundImage(UIImage(named: "FL"), forState: .Selected)
        
            
        case .BL(_, _):
            setBackgroundImage(UIImage(named: "BL_gray"), forState: .Normal)
            setBackgroundImage(UIImage(named: "BL"), forState: .Selected)

            break
            
        case .BR(_, _):
            setBackgroundImage(UIImage(named: "BR_gray"), forState: .Normal)
            setBackgroundImage(UIImage(named: "BR"), forState: .Selected)

            break
        }
 
    }
    
    init(rotation: Rotation) {
        super.init(frame: CGRectZero)
        self.rotation = rotation
        upDateButtonStyleWithRotation(rotation)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
  

}
