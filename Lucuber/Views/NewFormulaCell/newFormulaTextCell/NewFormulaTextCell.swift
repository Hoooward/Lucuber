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
    
    var active: Bool = true {
        didSet {
            changeIndicaterLabelStatus(active: active)
        }
    }
    func changeIndicaterLabelStatus(active: Bool) {
        indicaterLabel.textColor = active ? UIColor.addFormulaActive() : UIColor.addFormulaNotActive()
        self.isUserInteractionEnabled = active
    }

}
