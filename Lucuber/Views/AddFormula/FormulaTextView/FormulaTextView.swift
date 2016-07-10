//
//  FormulaTextView.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class FormulaTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        makeUI()
    }
    
    private func makeUI() {
        textContainer.lineFragmentPadding = 0
        tintColor = UIColor.cubeTintColor()
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        allowsEditingTextAttributes = true
        font = UIFont.cubeFormulaDefaultTextFont()
    }
    
    func insertKeyButtonTitle(keyButtn: KeyButton) {
        guard let type = keyButtn.item?.type else {
            return
        }
        var newText = keyButtn.titleLabel?.text ?? ""
//        let currentAttributeText = NSMutableAttributedString(attributedString: self.attributedText)
        var currentText = self.text
        switch type {
        case .Delete:
            deleteBackward()
        case .Default:
            newText += " "
            let range = self.selectedRange
            replaceCharactersInRange(currentText, range: range, newText: newText)
            self.selectedRange = NSRange(location: range.location + (newText.characters.count == 2 ? 2 : 3), length: 0)
        case .Bracket, .Number:
            var range = self.selectedRange
            let seletedText = (currentText as NSString).substringWithRange(range)
            //记录改变之前的字符串长度
            let currentLength = currentText.characters.count
            if newText == ")" || newText == "2" || seletedText == " " {
                newText += " "
                //如果是）去除尾部的宫格
                currentText = currentText.trimming(String.TrimmingType.Whitespace)
                //记录去除空格后的字符串长度
                let newLenght = currentText.characters.count
                //设置新的插入位置 -1 是因为字符串总长度-一个空格，变短了
                range = NSRange(location: selectedRange.location - (currentLength - newLenght), length: selectedRange.length)
            }
            //插入括弧
            replaceCharactersInRange(currentText, range: range, newText: newText)
            //重置光标位置， 如果是(向后移动1 如果是) 向后移动2
            self.selectedRange = NSRange(location: range.location + (newText.characters.count == 1 ? 1 : 2), length: 0)
        case .Space:
            newText += " "
            let range = self.selectedRange
            replaceCharactersInRange(currentText, range: range, newText: newText)
            self.selectedRange = NSRange(location: range.location + 1, length: 0)
        default:
            break
        }
    }
    
    private func replaceCharactersInRange(currentText: String, range: NSRange, newText: String) {
        let resultText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: newText)
        self.attributedText = resultText.setAttributesFitDetailLayout()
        
    }

}
