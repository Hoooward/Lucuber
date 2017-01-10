//
//  ProfileSeparationLineCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ProfileSeparationLineCell: UICollectionViewCell {

    var leftEdgeInset: CGFloat = Config.Profile.leftEdgeInset
    var rightEdgeInset: CGFloat = Config.Profile.rightEdgeInset
    var lineColor: UIColor = UIColor.cubeBorderColor()
    var lineWidth: CGFloat = 1.0 / UIScreen.main.scale
   
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        lineColor.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(lineWidth)
        
        let y = ceil(rect.height * 0.5)
        
        context?.move(to: CGPoint(x: leftEdgeInset, y: y))
        context?.addLine(to: CGPoint(x: rect.width - rightEdgeInset, y: y))
        
        context?.strokePath()
    }

}
