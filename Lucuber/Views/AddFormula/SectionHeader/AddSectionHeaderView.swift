//
//  AddSectionHeaderVIew.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddSectionHeaderView: UIView {

    @IBOutlet var titleLabel: UILabel!
    class func creatHeaderView() -> AddSectionHeaderView {
        return NSBundle.mainBundle().loadNibNamed("AddSectionHeaderView", owner: nil, options: nil).last! as! AddSectionHeaderView
    }

}
