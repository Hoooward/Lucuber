//
//  DetailMasterCell.swift
//  Lucuber
//
//  Created by Howard on 7/21/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

class DetailMasterCell: UITableViewCell {

    private enum Master {
        case no
        case yes
    }
    
    @IBOutlet weak var masterLabel: UILabel!
    @IBOutlet weak var indicatorView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.isHidden = true
       
    }
    
    private var master: Master = .no {
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
    
    private var formula: Formula?
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        self.formula = formula
        
        if let masterList = AVUser.current()?.masterList() {
           master = masterList.contains(formula.localObjectID) ? .yes : .no
        }
    
    }
    
    public func changeMasterStatus(with formula: Formula?) {
        
        guard let realm = try? Realm(), let formula = formula else {
            return 
        }
        
        master = master == .no ? .yes : .no
        
        realm.beginWrite()
        switch master {
        case .no:
            deleteMaster(with: formula, inRealm: realm)
        case .yes:
            appendMaster(with: formula, inRealm: realm)
        }
        try? realm.commitWrite()
    }
    
}
