//
//  AddFormulaTextCell.swift
//  Lucuber
//
//  Created by Howard on 7/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NewFormulaTextCell: UITableViewCell {

    @IBOutlet weak var indicaterLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        indicaterLabel.text = "添加新输入框"
        indicaterLabel.textColor = UIColor.cubeTintColor()
        indicaterLabel.highlightedTextColor = UIColor.cubeTintColor()
    }
    
    var active: Bool = true {
        didSet {
            changeIndicaterLabelStatus(active: active)
        }
    }
    
    func changeIndicaterLabelStatus(active: Bool) {
        
        indicaterLabel.textColor = active ? UIColor.cubeTintColor() : UIColor.addFormulaNotActive()
        self.isUserInteractionEnabled = active
        
        self.contentView.backgroundColor = active ? UIColor.white : UIColor.addFormulaNotActive()
        
    }

}
