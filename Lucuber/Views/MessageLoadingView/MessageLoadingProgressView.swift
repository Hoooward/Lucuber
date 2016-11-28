//
//  MessageLoadingProgressView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MessageLoadingProgressView: UIView {
    
    var progress: Double = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if progress <= 0 || progress == 1.0 {
            return
        }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let linewidth: CGFloat = 4
        let radius = min(rect.width, rect.height) * 0.5 - linewidth * 0.5
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        context?.beginPath()
        
        context?.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
        context?.setLineWidth(linewidth)
        
        
        context?.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: false)
        
        context?.drawPath(using: CGPathDrawingMode.stroke)
        context?.restoreGState()
        
        // progress arc
        
        context?.saveGState()
        context?.beginPath()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(linewidth)
        context?.setLineCap(CGLineCap.round)
        
        context?.addArc(center: center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI * 2 * progress - M_PI_2), clockwise: false)
        
        context?.drawPath(using: CGPathDrawingMode.stroke)
        context?.restoreGState()
        
        
        
    }
    
}
