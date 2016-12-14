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
    
 
    public func trimmingSearchtext() -> String {
       return self.lowercased().trimming(trimmingType: .squashingWhiteSpace)
        
    }
}


// OpenGrop

extension String {
    
    func truncate(length: Int, trailing: String? = nil) -> String {
        if self.characters.count > length {
            return self.substring(to: self.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
    var truncateForFeed: String {
        return truncate(length: 120, trailing: "...")
    }
    
    var opengraph_removeAllWhitespaces: String {
        return self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: " ", with: "")
    }
    
    var opengraph_removeAllNewLines: String {
        return self.components(separatedBy: CharacterSet.newlines).joined(separator: "")
    }
    
    var opengraph_embeddedURLs: [URL] {
        
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        
        var URLs = [URL]()
        
        detector.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length)) {
           result, flags, stop in
            
            if let URL = result?.url {
                URLs.append(URL)
            }
        }
        return URLs
    }
    
    var opengraph_firstImageURL: URL? {
        
        let URLs = opengraph_embeddedURLs
        
        guard !URLs.isEmpty else {
            return nil
        }
        
        let imageExtentions = [
            "png",
            "jpg",
            "jpeg"
        ]
        
        for URL in URLs {
            let pathExtension = URL.pathExtension.lowercased()
            if imageExtentions.contains(pathExtension) {
                return URL
            }
        }
        return nil
    }
    
}


extension String {
    
    static func random(length: Int = 15) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}

















