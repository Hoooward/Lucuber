//
//  RotationButton.swift
//  Lucuber
//
//  Created by Howard on 8/8/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RotationButton: UIButton {


    func upDateButtonStyleWithRotation(rotation: Rotation) {
        
        switch rotation {
        case .FR(_, _):
            setImage(UIImage(named: "FR_gray"), forState: .Normal)
            setImage(UIImage(named: "FR"), forState: .Selected)
            break
            
        case .FL(_, _):
            setImage(UIImage(named: "FL_gray"), forState: .Normal)
            setImage(UIImage(named: "FL"), forState: .Selected)
            break
            
        case .BL(_, _):
            setImage(UIImage(named: "BL_gray"), forState: .Normal)
            setImage(UIImage(named: "BL"), forState: .Selected)
            break
            
        case .BR(_, _):
            setImage(UIImage(named: "BR_gray"), forState: .Normal)
            setImage(UIImage(named: "BR"), forState: .Selected)
            break
        }
 
    }
    
    init(rotation: Rotation) {
        super.init(frame: CGRectZero)
        
        upDateButtonStyleWithRotation(rotation)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
  

}
