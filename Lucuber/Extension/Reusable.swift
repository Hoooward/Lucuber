//
//  Reusable.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/13.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var cube_reuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    static var cube_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: Reusable {
    
    static var cube_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {
    static var cube_reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol NibLoad {
    static var cube_nibName: String { get }
}

extension UITableViewCell: NibLoad {
    
    static var cube_nibName: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: NibLoad {
    static var cube_nibName: String {
        return String(describing: self)
    }
}
