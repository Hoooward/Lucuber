//
//  AddFormulaTextCell.swift
//  Lucuber
//
//  Created by Howard on 7/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddFormulaTextCell: UITableViewCell {

    var active: Bool = true {
        didSet {
            changeIndicaterLabelStatus(active)
        }
    }
    @IBOutlet var indicaterLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func changeIndicaterLabelStatus(active: Bool) {
        indicaterLabel.textColor = active ? UIColor.addFormulaActiveColor() : UIColor.addFormulaNotActiveColor()
        self.userInteractionEnabled = active
    }


}
