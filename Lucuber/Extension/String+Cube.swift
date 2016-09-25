//
//  String+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

enum FormulaContentShowStyle {
    case normal
    case detail
    case center
}

typealias AttributesDict = [String: AnyObject]

extension String {
    
    func setAttributesFitDetailLayout(style: FormulaContentShowStyle) -> NSMutableAttributedString {
        
        let attributeText = NSMutableAttributedString(string: self)
        
        var attributes = AttributesDict()
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.lineSpacing = 5
        
        switch style {
            
        case .normal:
            attributes = [
                NSForegroundColorAttributeName: UIColor.formulaNormalText(),
                NSFontAttributeName: UIFont.formulaNormalContent()
            ]
            
        case .detail:
            attributes = [
                NSForegroundColorAttributeName: UIColor.formulaDetailText(),
                NSFontAttributeName: UIFont.formulaDetailContent()
            ]
            
        case .center:
            attributes = [
                NSForegroundColorAttributeName: UIColor.formulaDetailText(),
                NSFontAttributeName: UIFont.formulaDetailContent()
            ]
            
            textStyle.alignment = .center
        }
        
        let range = NSRange(location: 0, length: self.characters.count)
        attributeText.addAttributes(attributes, range: range)
        
        attributeText.addAttributes([NSParagraphStyleAttributeName: textStyle], range: range)
        
        return setBracketsColor(attributesText: attributeText, style: style)
        
    }
    
    private func setBracketsColor(attributesText: NSMutableAttributedString, style: FormulaContentShowStyle) -> NSMutableAttributedString {
        
        let pattern = "\\(|\\)"
        
        let range = NSRange(location: 0, length: self.characters.count)
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let checkingResult = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: range)
            
            checkingResult.forEach {
                result in
                
                var attributes = AttributesDict()
                
                switch style {
                    
                case .normal:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.formulaNormalBrackets(),
                        NSFontAttributeName: UIFont.formulaNormalBrackets()
                    ]
                    
                case .detail:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.formulaDetailBrackets(),
                        NSFontAttributeName: UIFont.formulaDetailBrackets()
                    ]
                    
                case .center:
                    attributes = [
                        NSForegroundColorAttributeName: UIColor.formulaDetailBrackets(),
                        NSFontAttributeName: UIFont.formulaDetailBrackets()
                    ]
                    
                }
                
                
                attributesText.addAttributes(attributes, range: result.range)
            }
            
        } catch {
            
            printLog("设置括弧颜色失败")
        }
        
        
        return setNumberColor(attributesText: attributesText, style: style)
    }
    
    private func setNumberColor(attributesText: NSMutableAttributedString, style: FormulaContentShowStyle) -> NSMutableAttributedString {
        
        let pattern = "2"
        let range = NSRange(location: 0, length: self.characters.count)
        
        do {
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let checkingResult = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: range)
            
            checkingResult.forEach {
                result in
                
                var attributes = AttributesDict()
                
                switch style {
                    
                case .normal:
                    attributes = [NSForegroundColorAttributeName: UIColor.formulaNormalNumber()]
                    
                case .detail:
                    attributes = [NSForegroundColorAttributeName: UIColor.formulaDetailNumber()]
                    
                case .center:
                    attributes = [NSForegroundColorAttributeName: UIColor.formulaDetailNumber()]
                }
                
                attributesText.addAttributes(attributes, range: result.range)
            }
            
        } catch {
            
            printLog("设置数字颜色失败")
        }
        
        return setQuotationMarksColor(attributeText: attributesText)
        
    }
    
    private func setQuotationMarksColor(attributeText: NSMutableAttributedString) -> NSMutableAttributedString {
        
        let pattern = "'"
        let range = NSRange(location: 0, length: self.characters.count)
        
        do {
            
            let regular = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let checkingResult = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: range)
            
            checkingResult.forEach { result in
                
            }
            
        } catch {
            
            printLog("设置括弧颜色失败")
        }
        
        return attributeText
    }

}


extension String {
    
    public enum TrimmingType {
        ///去除两端空格
        case whitespace
        
        ///去除换行和两端空格 
        case whitespaceAndNewLine
        
        ///去除所有空格
        case squashingWhiteSpace
    }
    
    public func trimming(trimmingType: TrimmingType) -> String {
        
        switch trimmingType {
            
        case .whitespace:
            
            return trimmingCharacters(in: NSCharacterSet.whitespaces)
            
        case .whitespaceAndNewLine:
            
            return trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
        case .squashingWhiteSpace:
            
            let compoents = components(separatedBy: NSCharacterSet.whitespaces).filter {
                !$0.isEmpty
            }
            
            return compoents.joined(separator: "")
            
        }
    }
    
    /// 只有空格
    public var isDirty: Bool {
        
        if self.characters.count == 0 || self.trimmingCharacters(in: NSCharacterSet.whitespaces).characters.count == 0  {
            return true
        }
        
        return false
    }
}




















