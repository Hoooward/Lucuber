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
        //        super.touchesBegan(touches, withEvent: event)
        touchesBeganAction?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        super.touchesEnded(touches, withEvent: event)
        touchesEndedAction?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        //        super.touchesCancelled(touches, withEvent: event)
        touchesCancelledAction?()
    }
}
