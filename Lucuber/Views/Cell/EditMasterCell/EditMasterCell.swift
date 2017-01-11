//
//  EditMasterCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class EditMasterCell: UITableViewCell {
    
    var category: CubeCategoryMaster? {
        didSet {
            
            categoryLabel.text = category?.categoryString
        }
    }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryLabelLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var removeButtonTrailingConstraint: NSLayoutConstraint!
    
    public var removeCategoryAction: ((EditMasterCell, CubeCategoryMaster) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabelLeadingConstraint.constant = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        removeButtonTrailingConstraint.constant = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        
        removeButton.addTarget(self, action: #selector(EditMasterCell.tryRemoveCategoryMaster), for: .touchUpInside)
    }

    func tryRemoveCategoryMaster() {
        
        if let category = category {
            removeCategoryAction?(self, category)
        }
    }
    
}
