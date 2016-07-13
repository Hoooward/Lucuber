//
//  FormulaTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaTextViewCell: UITableViewCell {

    
    @IBOutlet var textView: FormulaTextView!
    @IBOutlet var formulaLabel: UILabel!
    @IBOutlet var placeholderLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        makeUI()
    }
    
    var formulaContent: FormulaContent? {
        didSet {
            if let formulaContent = formulaContent, let text = formulaContent.text {
               
                formulaLabel.attributedText = text.setAttributesFitDetailLayout()
                
            }
        }
    }
    
    private func makeUI() {
        self.formulaLabel.alpha = 0
        textView.delegate = self
        formulaLabel.textColor = UIColor.cubeFormulaDefaultTextColor()
        formulaLabel.font = UIFont.cubeFormulaDefaultTextFont()
        
        placeholderLabel.text = "输入公式, 系统会自动帮你填充空格。"
        placeholderLabel.textColor = UIColor.addFormulaPlaceholderTextColor()
        placeholderLabel.font = UIFont.addFormulaPlaceholderTextFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        formulaLabel.text = ""
        textView.text = ""
        placeholderLabel.hidden = false
    }
  
}

extension FormulaTextViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.hidden = true
            self.formulaLabel.alpha = 0
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count > 0
        self.formulaLabel.attributedText = textView.text.setAttributesFitDetailLayout()
        self.formulaLabel.alpha = 1
        
        
        formulaContent?.text = textView.text
        
        
    }
}