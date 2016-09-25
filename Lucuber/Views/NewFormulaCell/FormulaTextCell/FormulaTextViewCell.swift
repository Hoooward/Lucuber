//
//  FormulaTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaTextViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var rotationButton: RotationButton!
    @IBOutlet weak var textView: FormulaTextView!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var indicaterImageView: UIImageView!
    
    var updateInputAccessoryView: ((FormulaContent) -> Void)?
    
    var saveFormulaContent: ((FormulaContent) -> Void)?
    
    var didEndEditing: (() -> Void)?
    
    var formulaContent: FormulaContent? {
        didSet {
            
            if let _ = formulaContent {
                updateUI()
            }
        }
    }
    
    // MARK: -  Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.customDelegate = self
        makeUI()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        formulaLabel.text = ""
        textView.text = ""
        placeholderLabel.isHidden = false
        
    }
    
    private func makeUI() {
        
        textView.delegate = self
        formulaLabel.textColor = UIColor.formulaDetailText()
        formulaLabel.font = UIFont.formulaDetailContent()
        
        placeholderLabel.text = "输入公式, 系统会自动帮你填充空格。"
        placeholderLabel.textColor = UIColor.addFormulaPlaceholderText()
        placeholderLabel.font = UIFont.addFormulaPlaceholderText()
        
    }
    
    private func updateUI() {
        
        if let formulaContent = formulaContent {
            
            rotationButton.updateButtonStyle(with: .cercle, rotation: formulaContent.rotation)
            
            
            if let formulaText = formulaContent.text {
                
                
                formulaLabel.attributedText = formulaText.setAttributesFitDetailLayout(style: .center)
                formulaLabel.isHidden = textView.isFirstResponder
                placeholderLabel.isHidden = !formulaText.isEmpty
                
            } else {
                formulaLabel.isHidden = true
                placeholderLabel.isHidden = false
                
            }
            
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
            
            placeholderLabel.text = placeholderText
            
        }
    
    }
  
}

extension FormulaTextViewCell: UITextViewDelegate , FormulaTextViewDelegate {
    
    func formulaContentTextDidChanged() {
        
        formulaContent?.text = textView.text
        
        if let content = formulaContent {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if let formulaText = formulaLabel.text {
            
            if !formulaText.isEmpty {
                
                textView.text = formulaText
            }
        }
        
        placeholderLabel.isHidden = true
        self.formulaLabel.isHidden = true
        
        self.rotationButton.isSelected = true
        self.rotationButton.POPAnimation()
        
        if let content = formulaContent {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        placeholderLabel.isHidden = textView.text.characters.count > 0
        self.formulaLabel.attributedText = textView.text.setAttributesFitDetailLayout(style: .center)
        self.formulaLabel.isHidden = false
        
        
        formulaContent?.text = textView.text
        self.rotationButton.isSelected = false
        
        if let content = formulaContent {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
            
            didEndEditing?()
        }
        
    }
}
