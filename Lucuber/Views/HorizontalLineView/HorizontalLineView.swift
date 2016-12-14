//
//  HorizontalLineView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/14.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class HorizontalLineView: UIView {

    var lineColor: UIColor = UIColor.cubeBorderColor() {
        didSet {
            setNeedsDisplay()
        }
    }

    var lineWidth: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            setNeedsDisplay()
        }
    }

    var leftMargin: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var rightMargin: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var atBottom: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        lineColor.setStroke()

        let context = UIGraphicsGetCurrentContext()!

        context.setLineWidth(lineWidth)

        let y: CGFloat
        let fullHeight = rect.height

        if atBottom {

            y = fullHeight - lineWidth * 0.5

        } else {

            y = lineWidth * 0.5
        }

        context.__moveTo(x: leftMargin, y: y)

        let targetPoint = CGPoint(x: rect.width - rightMargin, y: y)

        context.addLine(to: targetPoint)

        context.strokePath()

    }


}

