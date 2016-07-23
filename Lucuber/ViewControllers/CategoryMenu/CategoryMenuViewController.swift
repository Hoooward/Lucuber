//
//  TypeMenuViewController.swift
//  Lucuber
//
//  Created by Howard on 16/6/30.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit


class CategoryMenuViewController: UIViewController {

    // MARK: Properties
    @IBOutlet var tableView: UITableView!
    var formulsData: [Formula] = []
    
    var cubeCategorys = [Category.x3x3, Category.Megaminx, Category.x4x4, Category.RubiksClock, Category.SquareOne]
//    var cubeCategorys = [Category.x3x3]
    
    var seletedCategory = Category.x3x3
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.registerClass(CategoryCheckCell.self, forCellReuseIdentifier: CategoryCheckCell.reuseIdentifier)
        tableView.rowHeight = CubeConfig.CagetoryMenu.rowHeight
        
        
        /// 尝试获取所有公式的Map
        let _ = FormulaManager.shardManager().Alls.map {
            formulas in
            formulas.map { formula in
                
                self.formulsData.append(formula)
            }
        }
        
    }
}

// MARK: - TableView Delegate&DataSource
extension CategoryMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cubeCategorys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CategoryCheckCell.reuseIdentifier, forIndexPath: indexPath) as! CategoryCheckCell
        
        let category = cubeCategorys[indexPath.row]
        cell.colorTitleLabel.text = category.rawValue
        cell.colorTitleLabelTextColor = UIColor.cubeTintColor()
        cell.checkImageView.hidden = !(seletedCategory == category)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
}












































