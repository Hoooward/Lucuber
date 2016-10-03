//
//  BaseFormulaLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class BaseFormulaLayout: UICollectionViewFlowLayout {
    
    var userMode: FormulaUserMode?
    
    override func prepare() {
        
        if let userMode = userMode {
            
            switch userMode {
            case .card:
                
                itemSize = CGSize(width: (UIScreen.main.bounds.width - (10 + 10 + 10)) * 0.5, height: 280)
                sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                
            case .normal:
                
                itemSize = CGSize(width: UIScreen.main.bounds.width, height: 80)
                sectionInset = UIEdgeInsets.zero
            }
        }
        
        headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 15)
    }
}

