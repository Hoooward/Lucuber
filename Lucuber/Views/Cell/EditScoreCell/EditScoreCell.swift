//
//  EditScoreCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/21.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class EditScoreCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var scoreTextFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTextField: UITextField!
    
    public var scoreTextFiledDidBeginEditingAction: (() -> Void)?
    public var scoreTextFiledDidEndEditingAction: ((String, EditScoreCell) -> Void)?
    public var scoreTextFiledDidChangedTextAction: (() -> Void)?
    
    var scoreTimerString: String = ""
    
    var cubeScores: CubeScores? {
        didSet {
            guard let cubeScores = cubeScores else {
                return
            }
            categoryLabel.text = cubeScores.categoryString
            scoreTextField.text = cubeScores.scoreTimerString == "" ? "" : cubeScores.scoreTimerString + "秒"
            scoreTimerString = cubeScores.scoreTimerString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scoreTextField.delegate = self
        
        categoryLabelLeadingConstraint.constant = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        scoreTextFieldTrailingConstraint .constant = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        
    }
    

}

extension EditScoreCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        categoryLabel.textColor = UIColor.cubeTintColor()
        
        scoreTextFiledDidBeginEditingAction?()
        
        var text = textField.text ?? ""
        if text.contains("秒") {
            let endOfDomain = text.index(text.startIndex, offsetBy: text.characters.count - 1)
            let rangeOfDomain = text.startIndex ..< endOfDomain
            text = text[rangeOfDomain]
        }
        textField.text = text
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        categoryLabel.textColor = UIColor.black
        
        scoreTextFiledDidEndEditingAction?(textField.text ?? "", self)
        
        guard let text = textField.text, !text.isEmpty else {
           return
        }
        textField.text = text + "秒"
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text ?? ""
        if text.characters.count > 4 {
            return false
        }
        
        return true
    }
    
    
    
    
}
