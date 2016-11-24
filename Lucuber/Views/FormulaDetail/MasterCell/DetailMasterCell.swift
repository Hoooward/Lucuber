//
//  DetailMasterCell.swift
//  Lucuber
//
//  Created by Howard on 7/21/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud

class DetailMasterCell: UITableViewCell {

    enum Master {
        case no
        case yes
    }
    
    @IBOutlet weak var masterLabel: UILabel!
    @IBOutlet weak var indicatorView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.isHidden = true
       
    }
    
    var master: Master = .no {
        
        didSet {
            
            switch master {
                
            case .no:
                indicatorView.isHidden = true
                 masterLabel.text = "未掌握"
                
            case .yes:
                indicatorView.isHidden = false
                 masterLabel.text = "已掌握"
            }
        }
        
    }
    
    
    
    var formula: Formula? {
        
        didSet {
            if
                let formula = formula,
                let currentUset = AVUser.current(),
                let list = currentUset.masterList() {
                
                master = list.contains(formula.localObjectID) ? .yes : .no
            }
        }
    }
    
    func changeMasterStatus(with formula: Formula?) {
       
        master = master == .no ? .yes : .no
        
        switch master {
            
        case .no:
           
            if let currentUser = AVUser.current(), let formula = formula {
                
//                currentUser.deleteMasterFormula(formula)
                masterLabel.text = "未掌握"
            }
            
        case .yes:
            
            if let currentUser = AVUser.current(), let formula = formula {
                
//                currentUser.addNewMasterFormula(formula)
                masterLabel.text = "已掌握"
            }
        }
        
    }
    
}
