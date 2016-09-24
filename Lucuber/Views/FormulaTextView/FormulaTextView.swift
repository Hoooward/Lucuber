//
//  FormulaTextView.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/25.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

protocol FormulaTextViewDelegate: class {
    
    func formulaContentTextDidChanged()
}

class FormulaTextView: UITextView {
    
    // MARK: - Properties
    
    weak var customDelegate: FormulaTextViewDelegate?
    
    var updateFormulaContentText: (() -> Void)?
    
    private var placeholdTextLabel: UILabel = {
        let label = UILabel()
        label.text = "输入公式, 系统会自动帮你填充空格。"
        label.textColor = UIColor.addFormulaPlaceholderText()
        label.font = UIFont.addFormulaPlaceholderText()
        label.sizeToFit()
        return label
    }()
    
    private func updatePlaceholderLabel(showPlaceholderText: Bool) {
        placeholdTextLabel.text = showPlaceholderText ? "输入公式, 系统会自动帮你填充空格。" : ""
    }
    
    // MARK: - Life Cycle
    
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
        font = UIFont.formulaDetailContent()
        
        
        addSubview(placeholdTextLabel)
        placeholdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholdLeft = NSLayoutConstraint(item: placeholdTextLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let placeholdTop = NSLayoutConstraint(item: placeholdTextLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([placeholdTop, placeholdLeft])
    }
    
   
    override func becomeFirstResponder() -> Bool {
        isUserInteractionEnabled = true
        self.alpha = 1
        updatePlaceholderLabel(showPlaceholderText: false)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        isUserInteractionEnabled = false
        self.alpha = 0
        updatePlaceholderLabel(showPlaceholderText: true)
        return super.resignFirstResponder()
    }
    
    
    // MARK: - Action & Traget
    
    func insertKeyButtonTitle(keyButtn: KeyButton) {
        
        guard let type = keyButtn.item?.type else {
            fatalError()
        }
        
        var newText = keyButtn.titleLabel?.text ?? ""
        var currentText = self.text ?? ""
        
        switch type {
            
        case .deleteKey:
            
            deleteBackward()
            
        case .defaultKey:
            
            newText += " "
            let range = self.selectedRange
            replaceCharactersInRange(currentText: currentText, range: range, newText: newText)
            self.selectedRange = NSRange(location: range.location + (newText.characters.count == 2 ? 2 : 3), length: 0)
            
        case .bracketKey, .numberKey:
            
            var range = self.selectedRange
            //如果移动光标到中间，确定中间位置的是否是空格
            let seletedText = (currentText as NSString).substring(with: range)
            //记录改变之前的字符串长度
            let currentLength = currentText.characters.count
            if newText == ")" || newText == "2" || seletedText == " " {
                newText += " "
                //如果是）去除尾部的宫格
                currentText = currentText.trimming(trimmingType: .whitespace)
                //记录去除空格后的字符串长度
                let newLenght = currentText.characters.count
                //设置新的插入位置 -1 是因为字符串总长度-一个空格，变短了
                range = NSRange(location: selectedRange.location - (currentLength - newLenght), length: selectedRange.length)
            }
            //插入括弧
            replaceCharactersInRange(currentText: currentText, range: range, newText: newText)
            //重置光标位置， 如果是(向后移动1 如果是) 向后移动2
            self.selectedRange = NSRange(location: range.location + (newText.characters.count == 1 ? 1 : 2), length: 0)
            
        case .spaceKey:
            newText += " "
            let range = self.selectedRange
            replaceCharactersInRange(currentText: currentText, range: range, newText: newText)
            self.selectedRange = NSRange(location: range.location + 1, length: 0)
            
        default:
            break
        }
        
        customDelegate?.formulaContentTextDidChanged()
        
        spring(duration: 1.0) {
            self.placeholdTextLabel.isHidden = self.text.characters.count > 0
        }
        
    }
    
   
    private func replaceCharactersInRange(currentText: String, range: NSRange, newText: String) {
        let resultText = (currentText as NSString).replacingCharacters(in: range, with: newText)
        self.attributedText = resultText.setAttributesFitDetailLayout(style: .detail)
        
    }
    
}
