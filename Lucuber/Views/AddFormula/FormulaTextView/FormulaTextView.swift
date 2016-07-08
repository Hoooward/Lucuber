//
//  FormulaTextView.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class FormulaTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        makeUI()
    }
    
    private func makeUI() {
        textContainer.lineFragmentPadding = 0
        tintColor = UIColor.cubeTintColor()
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        allowsEditingTextAttributes = true
    }

}
