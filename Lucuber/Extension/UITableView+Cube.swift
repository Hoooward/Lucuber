//
//  UITableView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

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
