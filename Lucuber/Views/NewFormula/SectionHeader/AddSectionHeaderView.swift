//
//  AddSectionHeaderVIew.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddSectionHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    class func creatHeaderView() -> AddSectionHeaderView {
        return NSBundle.mainBundle().loadNibNamed("AddSectionHeaderView", owner: nil, options: nil).last! as! AddSectionHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        rightButton.hidden = true
    }

}
