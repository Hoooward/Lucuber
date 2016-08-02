//
//  FeedTextView.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedTextView: UITextView {

    override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    
    var touchesBeganAction: (() -> Void)?
    var touchesEndedAction: (() -> Void)?
    var touchesCancelledAction: (() -> Void)?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
        touchesBeganAction?()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesEnded(touches, withEvent: event)
        touchesEndedAction?()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        super.touchesCancelled(touches, withEvent: event)
        touchesCancelledAction?()
    }
}
