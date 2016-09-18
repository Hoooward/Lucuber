//
//  CategoryButton.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CategoryButton: UIBarButtonItem {

    var seletedCategory: Category? {
        willSet {
            
            if let category = newValue {
                self.title = category.rawValue + " ▾"
//                setTitle(category.rawValue + " ▾", for: .normal)
            }
        }
    }
    
//    init() {
//        super.init(frame: CGRect.zero)
//        setTitle(Category.x3x3.rawValue + " ▾", for: .normal)
//        setTitleColor(UIColor.cubeTintColor(), for: .normal)
//        sizeToFit()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
