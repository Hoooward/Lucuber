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
    
    var updateInputAccessoryView: ((FormulaContent) -> Void)?
    
    var saveFormulaContent: ((FormulaContent) -> Void)?
       
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.customDelegate = self
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
            
            rotationButton.upDateButtonStyleWithRotation(RotationButton.Style.Cercle, rotation: formulaContent.rotation)
            
            var placeholderText = ""
            
            switch formulaContent.rotation {
                
            case .FR(_, let placeText):
                placeholderText = placeText
                
                
            case .FL(_, let placeText):
                placeholderText = placeText
                
            case .BL(_, let placeText):
                placeholderText = placeText
                
            case .BR(_, let placeText):
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

extension FormulaTextViewCell: UITextViewDelegate , FormulaTextViewDelegate{
    
    func formulaContentTextDidChanged() {
        formulaContent?.text = textView.text
        
        if let content = formulaContent {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.hidden = true
        self.formulaLabel.alpha = 0
        
        self.rotationButton.selected = true
        self.rotationButton.POPAnimation()
        
        if let content = formulaContent {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
        
    }
    
    
    
    func textViewDidEndEditing(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count > 0
        self.formulaLabel.attributedText = textView.text.setAttributesFitDetailLayout(.Detail)
        self.formulaLabel.alpha = 1
        
        
        formulaContent?.text = textView.text
        self.rotationButton.selected = false
        
        if let content = formulaContent {
            printLog(content)
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
        
        
        
    }
}