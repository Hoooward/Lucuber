//
//  FormulaTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import RealmSwift

class FormulaTextViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var rotationButton: RotationButton!
    @IBOutlet weak var textView: FormulaTextView!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var indicaterImageView: UIImageView!
    
    public var updateInputAccessoryView: ((Content) -> Void)?
    public var saveFormulaContent: ((Content) -> Void)?
    public var didEndEditing: (() -> Void)?
    
    fileprivate var content: Content?
    
    fileprivate var realm: Realm?
    
    public func configCell(with formula: Formula?, indexPath: IndexPath, inRealm realm: Realm) {
        
        guard let formula = formula else {
            return
        }
        
        let content = formula.contents[indexPath.item]
        self.content = content
        self.realm = realm
        
        guard let rotation = Rotation(rawValue: content.rotation) else {
            return
        }
        
        rotationButton.updateButtonStyle(with: .cercle, rotation: rotation)
        
        let contentText = content.text
        
        if contentText.isEmpty {
            
            formulaLabel.isHidden = true
            placeholderLabel.isHidden = false
            
        } else {
            
            formulaLabel.attributedText = contentText.setAttributesFitDetailLayout(style: .center)
            formulaLabel.isHidden = textView.isFirstResponder
            placeholderLabel.isHidden = !contentText.isEmpty
        }
        
        placeholderLabel.text = rotation.placeholderText
        
        
        
    }
    
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
  
}

extension FormulaTextViewCell: UITextViewDelegate , FormulaTextViewDelegate {
    
    func formulaContentTextDidChanged() {
        
        guard let realm = realm , let content = content else {
            return
        }
        realm.beginWrite()
        content.text = textView.text
//        content.saveNewCellHeight(inRealm: realm)
        try? realm.commitWrite()
        
        updateInputAccessoryView?(content)
        saveFormulaContent?(content)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if let formulaText = formulaLabel.text {
            
            if !formulaText.isEmpty {
                
                textView.attributedText = formulaText.setAttributesFitDetailLayout(style: .detail)
            }
        }
        
        placeholderLabel.isHidden = true
        self.formulaLabel.isHidden = true
        
        self.rotationButton.isSelected = true
        self.rotationButton.POPAnimation()
        
        if let content = content {
            updateInputAccessoryView?(content)
            saveFormulaContent?(content)
        }
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        placeholderLabel.isHidden = textView.text.characters.count > 0
        self.formulaLabel.attributedText = textView.text.setAttributesFitDetailLayout(style: .center)
        
        self.formulaLabel.isHidden = false
        self.rotationButton.isSelected = false
        
        guard let realm = realm , let content = content else {
            return
        }
        
        realm.beginWrite()
        content.text = textView.text
//        content.saveNewCellHeight(inRealm: realm)
        try? realm.commitWrite()
      
        updateInputAccessoryView?(content)
        saveFormulaContent?(content)
        didEndEditing?()
        
    }
}
