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
            }
        }
    }

}
