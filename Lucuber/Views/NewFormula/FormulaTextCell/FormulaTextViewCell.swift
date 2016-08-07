//
//  FormulaTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaTextViewCell: UITableViewCell {

    
    @IBOutlet weak var rotationButton: RotationButton!
    @IBOutlet weak var textView: FormulaTextView!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var indicaterImageView: UIImageView!
    
    var contentDidChanged: ((FormulaContent) -> Void)?
    
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
        formulaLabel.textColor = UIColor.cubeFormulaDetailTextColor()
        formulaLabel.font = UIFont.cubeFormulaDetailTextFont()
        
        placeholderLabel.text = "输入公式, 系统会自动帮你填充空格。"
        placeholderLabel.textColor = UIColor.addFormulaPlaceholderTextColor()
        placeholderLabel.font = UIFont.addFormulaPlaceholderTextFont()
        
    }
    
    private func updateUI() {
        if let formulaContent = formulaContent {
            
            rotationButton.upDateButtonStyleWithRotation(formulaContent.rotation)
            
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
            
//            indicaterImageView.image = UIImage(named: indicaterImagename)
            placeholderLabel.text = placeholderText
            
        }
        

    
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        formulaLabel.text = ""
        textView.text = ""
        placeholderLabel.hidden = false
        
//        updateUI()
    }
  
}

extension FormulaTextViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.hidden = true
        self.formulaLabel.alpha = 0
        self.rotationButton.selected = true
        
        if let content = formulaContent {
            contentDidChanged?(content)
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count > 0
        self.formulaLabel.attributedText = textView.text.setAttributesFitDetailLayout(.Detail)
        self.formulaLabel.alpha = 1
        
        
        formulaContent?.text = textView.text
        self.rotationButton.selected = false
        
        if let content = formulaContent {
            contentDidChanged?(content)
        }
        
        
        
    }
}