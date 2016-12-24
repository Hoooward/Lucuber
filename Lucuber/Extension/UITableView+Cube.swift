//
//  UITableView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


extension UITableView {
    
    func registerClass<T: UITableViewCell>(of _: T.Type) where T: Reusable {
        register(T.self, forCellReuseIdentifier: T.cube_reuseIdentifier)
    }
    
    func registerNib<T: UITableViewCell>(of _: T.Type) where T: Reusable, T: NibLoad {
        let nib = UINib(nibName: T.cube_nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.cube_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
        
        guard let cell = dequeueReusableCell(withIdentifier: T.cube_reuseIdentifier, for: indexPath) as? T else {
            fatalError("无法重用 identifier 为: \(T.cube_reuseIdentifier) 的 cell ")
        }
        return cell
    }
}

extension UITableView {
    
    enum WayToUpdata {
        
        case none
        case reloadData
        case insert([IndexPath])
        case reloadAtIndexPath([IndexPath])
        
        
        func performWithTableView(tableView: UITableView) {
            
            switch self {
            case .none:
                printLog("tableView WayToUpdata: None")
                
            case .reloadData:
                printLog("tableView WayToUpdata: ReloadData")
                tableView.reloadData()
                
            case .reloadAtIndexPath(let indexPaths):
                printLog("tableView WayToUpdata: ReloadAtIndexPath")
                tableView.reloadRows(at: indexPaths, with: .none)
                
            case .insert(let indexPaths):
                printLog("tableView WayToUpdata: Insert")
                tableView.insertRows(at: indexPaths, with: .none)
                
            }
        }
    }
    
    
    
    
    
}
