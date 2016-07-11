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
        
        
        addSubview(placeholdTextLabel)
        placeholdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholdLeft = NSLayoutConstraint(item: placeholdTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let placeholdTop = NSLayoutConstraint(item: placeholdTextLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([placeholdTop, placeholdLeft])
    }
    
    private func updatePlaceholderLabel(showPlaceholderText: Bool) {
        
        placeholdTextLabel.text = showPlaceholderText ? "输入公式, 系统会自动帮你填充空格。" : ""
    }

    private var placeholdTextLabel: UILabel = {
        let label = UILabel()
        label.text = "输入公式, 系统会自动帮你填充空格。"
        label.textColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFontOfSize(12)
        label.sizeToFit()
        return label
    }()
    
    func insertKeyButtonTitle(keyButtn: KeyButton) {
        guard let type = keyButtn.item?.type else {
            fatalError()
        }
        var newText = keyButtn.titleLabel?.text ?? ""
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
            //如果移动光标到中间，确定中间位置的是否是空格
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
        
        
        spring(0.5) {
            self.placeholdTextLabel.hidden = self.text.characters.count > 0
        }
        
    }
    
    override func becomeFirstResponder() -> Bool {
        userInteractionEnabled = true
        updatePlaceholderLabel(false)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        userInteractionEnabled = false
        updatePlaceholderLabel(true)
        return super.resignFirstResponder()
    }
    
    
    private func replaceCharactersInRange(currentText: String, range: NSRange, newText: String) {
        let resultText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: newText)
        self.attributedText = resultText.setAttributesFitDetailLayout()
        
    }

}
