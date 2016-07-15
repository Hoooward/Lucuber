//
//  Animation.swift
//  Lucuber
//
//  Created by Howard on 16/7/1.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

private let duration = 0.7
private let delay = 0.0
private let damping = 0.7
private let velocity = 0.7


typealias animation = ()->Void
typealias completion = (()->Void)?

func spring(duration: NSTimeInterval, animations:animation){
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
        animations()
        }, completion: { finished in
    })
    
}

func animate(duration: NSTimeInterval, animations:animation){
    UIView.animateWithDuration(duration) { 
        animations()
    }
    
}


func animateWithCompletion(duration: NSTimeInterval, animations: animation, completions: (Bool) -> Void) {
    
    UIView.animateWithDuration(duration,  animations: {
        animations()
        }, completion: { finished in
            completions(finished)
    })
    
    
}



func springWithCompletion(duration: NSTimeInterval, animations: animation, completions: (Bool) -> Void) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: { 
        animations()
        }, completion: { finished in
            completions(finished)
    })
    
    
}

