//
//  ScoreHeaderView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/25.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import LucuberTimer
import RealmSwift
import ScrollableGraphView


class ScoreHeaderView: UIView {

    var totalHeight: CGFloat = 200
    
    @IBOutlet weak var graphView: ScrollableGraphView!
    @IBOutlet weak var topView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topView.backgroundColor = UIColor.cubeTintColor()
    }
    
    func makeUI() {
        
        addSubview(graphView)
        
        let views: [String: Any] = [
            "graphView": graphView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[graphView]|", options: [], metrics: nil, views: views)
        let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[graphView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate(constraintV)
    }
    
}
