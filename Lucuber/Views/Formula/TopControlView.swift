//
//  TopControlView.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class TopControlView: UIView {
    
    @IBOutlet var myFormulaBtn: UIButton!
    lazy var tipView: UIView = {
        let view = UIView()
        view.frame = CGRectMake(0, self.height - 6.0, self.myFormulaBtn.width * 0.5, 3.0)
        view.center.x = self.myFormulaBtn.titleLabel!.center.x
        view.backgroundColor = UIColor.cubeTintColor()
        return view
    }()
    class func creatTopControl() -> TopControlView {
        return NSBundle.mainBundle().loadNibNamed("TopControlView", owner: nil, options: nil).last! as! TopControlView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(tipView)
    }


}
