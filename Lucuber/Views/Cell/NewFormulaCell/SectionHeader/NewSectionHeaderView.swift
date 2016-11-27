//
//  AddSectionHeaderVIew.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NewSectionHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    class func creatHeaderView() -> NewSectionHeaderView {
        return Bundle.main.loadNibNamed("NewSectionHeaderView", owner: nil, options: nil)!.last! as! NewSectionHeaderView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        rightButton.isHidden = true
    }

}
