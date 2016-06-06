//
//  String+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


extension String {
    
    func setAttributesFitDetailLayout() -> NSMutableAttributedString {
        let attributeText = NSMutableAttributedString(string: self)
        
        attributeText.addAttributes([NSFontAttributeName: UIFont(name: "Menlo-Regular", size: 15)!], range: NSRange(location: 0, length: self.characters.count))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attributeText.addAttributes([NSParagraphStyleAttributeName: style], range: NSRange(location: 0, length: self.characters.count))
        
        return setBracketsColor(attributeText)
    }
    
    
    
    private func setBracketsColor(attributeText: NSMutableAttributedString) -> NSMutableAttributedString {
        let pattern = "\\(|\\)"
        
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
            let checkingResult = regular.matchesInString(self, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            for result in checkingResult {
                attributeText.addAttributes([NSForegroundColorAttributeName: UIColor ( red: 0.669, green: 0.7313, blue: 0.9489, alpha: 1.0 )], range: result.range)
            }
        } catch {
            print("设置括弧颜色失败")
        }
        
        return setNumbersColor(attributeText)
    }
    
    
    private func setNumbersColor(attributeText: NSMutableAttributedString) -> NSMutableAttributedString {
        let pattern = "2"
        
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
            let checkingResult = regular.matchesInString(self, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            for result in checkingResult {
                attributeText.addAttributes([NSForegroundColorAttributeName: UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )], range: result.range)
            }
        } catch {
            print("设置括弧颜色失败")
        }
        return setQuotationMarksColor(attributeText)
    }
    
    private func setQuotationMarksColor(attributeText: NSMutableAttributedString) -> NSMutableAttributedString {
        let pattern = "'"
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
            let checkingResult = regular.matchesInString(self, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            for _ in checkingResult {
//                attributeText.addAttributes([NSForegroundColorAttributeName: UIColor.cubeTintColor()], range: result.range)
            }
        } catch {
            print("设置括弧颜色失败")
        }
        return attributeText
        
    }
}


extension String {
    enum TrimmingType {
        case Whitespace
        case WhitespaceAndNewLine
    }
    
    func trimming(trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .Whitespace:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        case .WhitespaceAndNewLine:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }
}









