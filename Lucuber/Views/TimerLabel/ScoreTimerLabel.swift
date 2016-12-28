//
//  TimerLabel.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ScoreTimerLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        self.textColor = UIColor.timerLabelTextColor()
    }
}
