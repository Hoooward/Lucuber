//
//  ShowDetailCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import CoreGraphics

class ShowDetailCell: UICollectionViewCell {

    @IBOutlet var containerScrollerView: UIScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
//        formulaImageView.frame = CGRectMake(10, 74, 160, 160)
        containerScrollerView.addSubview(formulaImageView)
        containerScrollerView.contentSize = CGSize(width: screenWidth, height: 1000)
        containerScrollerView.showsVerticalScrollIndicator = false
        
        containerScrollerView.addSubview(formulaNameLabel)
        
        let image = getFormulasImage(["(R U' U' R' U)2 y' (R' U' R)",
            "(U R U' R' U') y' (R' U R)"])
        let imageView = UIImageView(image: image)
        imageView.frame.origin = CGPoint(x: 10, y: CGRectGetMaxY(formulaNameLabel.frame) + 10)
        containerScrollerView.addSubview(imageView)
        containerScrollerView.addSubview(backView)
        
        containerScrollerView.backgroundColor = UIColor.whiteColor()
    }

    var nameLabelRect: CGPoint {
        return CGPoint(x: 10, y: formulaImageView.frame.size.height + 10)
    }

    
    private lazy var backView: UIView = {
        
        let view = UIView()
        view.size = CGSize(width: screenWidth, height: screenWidth)
        view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        return view
    }()
    private lazy var formulaImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "F2L10"))
        imageView.size = CGSize(width: screenWidth, height: screenWidth)
//        imageView.layer.cornerRadius = 12
//        imageView.frame = CGRectMake(10, 74, 160, 160)
        return imageView
    }()
    
    private lazy var formulaNameLabel: UILabel = {
        let label = UILabel()
        label.text = "FLL 21"
        label.font = UIFont.systemFontOfSize(14)
        label.sizeToFit()
        label.frame.origin = self.nameLabelRect
        return label
    }()
    
    func getFormulasImage(formulas: [String]) -> UIImage {
        let maxWidth = screenWidth - 40
        let marginTop: CGFloat = 10
        
        var formulasLabels = [CGRect]()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: 50), false, UIScreen.mainScreen().scale)
        
        for (index, formula) in formulas.enumerate() {
            let textRect = CGRectMake(0, 0, 0, 17)
            let textTextContent = NSString(string: formula)
            let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .Center
            
            let textFontAttributes: [String: AnyObject] = {
                return [NSFontAttributeName:UIFont(name: "Menlo-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor(),
                        NSParagraphStyleAttributeName: textStyle]
            }()
            
            let textTextWidth: CGFloat = textTextContent.boundingRectWithSize(CGSizeMake(CGFloat.infinity, 19), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.width + 10
            
            var rect = CGRectMake(0, marginTop, textTextWidth, textRect.height + 10)
            
            let y = CGFloat(index) * (rect.height + 10)
            
            rect = CGRectMake(0, y, rect.width, rect.height)
            
            let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
            
            UIColor.cubeTintColor().setFill()
            rectanglePath.fill()
            formulasLabels.append(rect)
            
            textTextContent.drawInRect(rect, withAttributes: textFontAttributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
