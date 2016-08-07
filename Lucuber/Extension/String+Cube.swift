//
//  String+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

enum ContentStyle {
    case Detail
    case Normal
}

extension String {
    
    


    
    func setAttributesFitDetailLayout(style: ContentStyle) -> NSMutableAttributedString {
        let attributeText = NSMutableAttributedString(string: self)
        
        var attributes = [String: AnyObject]()
        let textStyle = NSMutableParagraphStyle()
        textStyle.lineSpacing = 5
        switch style {
        case .Normal:
            attributes = [
                NSForegroundColorAttributeName: UIColor.cubeFormulaNormalTextColor(),
                NSFontAttributeName: UIFont.cubeFormulaNormalContentFont()]
        case .Detail:
            attributes = [
                NSForegroundColorAttributeName: UIColor.cubeFormulaDetailTextColor(),
                NSFontAttributeName: UIFont.cubeFormulaDetailTextFont()]
//            textStyle.alignment = .Center
        }
        attributeText.addAttributes(attributes, range: NSRange(location: 0, length: self.characters.count))
       
        attributeText.addAttributes([NSParagraphStyleAttributeName: textStyle], range: NSRange(location: 0, length: self.characters.count))
        
        return setBracketsColor(attributeText, style: style)
    }
    
    
    
    private func setBracketsColor(attributeText: NSMutableAttributedString, style: ContentStyle) -> NSMutableAttributedString {
        let pattern = "\\(|\\)"
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
            let checkingResult = regular.matchesInString(self, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            for result in checkingResult {
                
                var attributes = [String: AnyObject]()
                switch style {
                case .Normal:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.cubeFormulaNormalBracketsColor(),
                        NSFontAttributeName: UIFont.cubeFormulaNormalBracketsFont()]
                case .Detail:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.cubeFormulaDetailBracketsColor(),
                        NSFontAttributeName: UIFont.cubeFormulaDetailBracketsFont()]
                }
                attributeText.addAttributes(attributes, range: result.range)
            }
        } catch {
            print("设置括弧颜色失败")
        }
        
        return setNumbersColor(attributeText, style: style)
    }
    
    
    private func setNumbersColor(attributeText: NSMutableAttributedString, style: ContentStyle) -> NSMutableAttributedString {
        let pattern = "2"
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
            let checkingResult = regular.matchesInString(self, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            for result in checkingResult {
                var attributes = [String: AnyObject]()
                switch style {
                case .Normal:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.cubeFormulaNormalNumberColor()]
                case .Detail:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.cubeFormulaDetailNumberColor()]
                }
                attributeText.addAttributes(attributes, range: result.range)
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
    
    ///只有空格
    var isDirty: Bool {
        if self.characters.count == 0 {
            return true
        }
        if self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count == 0 {
            return true
        }
        
        return false
    }
}










