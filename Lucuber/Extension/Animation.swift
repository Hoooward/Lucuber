//
//  Animation.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

private let duration = 0.7
private let delay = 0.0
private let damping = 0.7
private let velocity = 0.7


typealias animation = ()->Void
typealias completion = (()->Void)?

func spring(duration: TimeInterval, animations: @escaping animation){
    
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
        animations()
        }, completion: { finished in
    })
    
}

func animate(duration: TimeInterval, animations:@escaping animation){
    UIView.animate(withDuration: duration) {
        animations()
    }
}

func animateWithCompletion(duration: TimeInterval, animations: @escaping animation, completions: @escaping (Bool) -> Void) {
    
    UIView.animate(withDuration: duration,  animations: {
        animations()
        }, completion: { finished in
            completions(finished)
    })
}

func springWithCompletion(duration: TimeInterval, animations: @escaping animation, completions: @escaping (Bool) -> Void) {
    
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
        animations()
        }, completion: { finished in
            completions(finished)
    })
    
}


