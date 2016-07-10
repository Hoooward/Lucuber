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
        let attributes = [
            NSForegroundColorAttributeName: UIColor.cubeFormulaDefaultTextColor(),
            NSFontAttributeName: UIFont.cubeFormulaDefaultTextFont()]
        attributeText.addAttributes(attributes, range: NSRange(location: 0, length: self.characters.count))
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
                let attributes = [
                    NSForegroundColorAttributeName: UIColor.cubeFormulaBracketsColor(),
                    NSFontAttributeName: UIFont.cubeFormulaBracketsFont()]
                attributeText.addAttributes(attributes, range: result.range)
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
                attributeText.addAttributes([NSForegroundColorAttributeName: UIColor.cubeFormulaNumberColor()], range: result.range)
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
            }
        } catch {
            print("设置括弧颜色失败")
        }
        return attributeText
        
    }
}


extension String {
    ///整理字符串的方式
    enum TrimmingType {
        ///去除两端空格
        case Whitespace
        ///去除换行和两端空格
        case WhitespaceAndNewLine
        ///去除所有空格
        case SquashingWhiteSpace
    }
    
    func trimming(trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .Whitespace:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        case .WhitespaceAndNewLine:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        case .SquashingWhiteSpace:
            let components = componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                .filter { !$0.isEmpty
            }
            return components.joinWithSeparator("")
        }
    }
}










