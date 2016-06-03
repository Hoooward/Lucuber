//
//  UIBarButtonItem+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

// MARK: - 提供快速生成navigationBar上按钮的方法
extension UIBarButtonItem {
    class func itemWithCustomButton(normalImage:UIImage?, seletedImage: UIImage?,targer: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .Custom)
        button.setImage(normalImage, forState: .Normal)
        button.setImage(seletedImage, forState: .Selected)
        button.sizeToFit()
        button.addTarget(targer, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: button)
    }
}