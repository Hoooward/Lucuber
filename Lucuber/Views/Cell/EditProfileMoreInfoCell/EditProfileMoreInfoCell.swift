//
//  EditProfileMoreInfoCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/13.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class EditProfileMoreInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    public var infoTextViewBeginEditingAction: ((UITextView) -> Void)?
    public var infoTextViewIsDirtyAction: (() -> Void)?
    public var infoTextViewDidEndEditingAction: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        infoTextView.font = Config.EditProfile.infoFont
        
        infoTextView.autocapitalizationType = .none
        infoTextView.autocorrectionType = .no
        infoTextView.spellCheckingType = .no
        
        infoTextView.textContainer.lineFragmentPadding = 0
        infoTextView.textContainerInset = UIEdgeInsets.zero
        
        infoTextView.delegate = self
    }
}

extension EditProfileMoreInfoCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        infoTextViewBeginEditingAction?(textView)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        infoTextViewIsDirtyAction?()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let text = textView.text.trimming(trimmingType: .whitespaceAndNewLine)
        textView.text = text
        infoTextViewDidEndEditingAction?(text)
    }
}
