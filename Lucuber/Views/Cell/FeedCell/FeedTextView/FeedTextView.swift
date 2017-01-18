//
//  FeedTextView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedTextView: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    var touchesBeganAction: (() -> Void)?
    var touchesEndedAction: (() -> Void)?
    var touchesCancelledAction: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganAction?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedAction?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesCancelledAction?()
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        // iOS9 以上, 强制取消添加文字长按手势
        // 四种长按手势, iOS9 中分别加了两次: 0.1 Reveal，0.12 tap link，0.5 selection， 0.75 press link
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if longPressGestureRecognizer.minimumPressDuration == 0.5 {
                return
            }
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}
