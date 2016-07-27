//
//  UITableView+Cube.swift
//  Lucuber
//
//  Created by Howard on 7/27/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation

extension UITableView {
    
    enum WayToUpdata {
        
        case None
        case ReloadData
        case Insert([NSIndexPath])
        case ReloadAtIndexPath([NSIndexPath])
        
        
        func performWithTableView(tableView: UITableView) {
            
            switch self {
            case .None:
                printLog("tableView WayToUpdata: None")
                
            case .ReloadData:
                printLog("tableView WayToUpdata: ReloadData")
                tableView.reloadData()
                
            case .ReloadAtIndexPath(let indexPaths):
                printLog("tableView WayToUpdata: ReloadAtIndexPath")
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                
            case .Insert(let indexPaths):
                printLog("tableView WayToUpdata: Insert")
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                
            }
        }
    }
    
    

    
    
}