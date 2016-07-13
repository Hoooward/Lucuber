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
    @IBOutlet var indicaterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    
    var formulaContent: FormulaContent? {
        didSet {
            updateUI()
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
    
    private func updateUI() {
        if let formulaContent = formulaContent {
            
            //                formulaLabel.attributedText = text.setAttributesFitDetailLayout()
            var indicaterImagename = ""
            var placeholderText = ""
            switch formulaContent.rotation {
            case .FR(let imageName, let placeText):
                indicaterImagename = imageName
                placeholderText = placeText
            case .FL(let imageName, let placeText):
                indicaterImagename = imageName
                placeholderText = placeText
            case .BL(let imageName, let placeText):
                indicaterImagename = imageName
                placeholderText = placeText
            case .BR(let imageName, let placeText):
                indicaterImagename = imageName
                placeholderText = placeText
            }
            indicaterImageView.image = UIImage(named: indicaterImagename)
            placeholderLabel.text = placeholderText
            
        }
        

    
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        formulaLabel.text = ""
        textView.text = ""
        placeholderLabel.hidden = false
        updateUI()
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