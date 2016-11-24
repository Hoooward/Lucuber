//
//  TypeSelectedCell.swift
//  Lucuber
//
//  Created by Howard on 8/9/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class TypeSelectedCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    
    
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        typeLabel.text = formula.type.rawValue
    
    }
    
 

}
