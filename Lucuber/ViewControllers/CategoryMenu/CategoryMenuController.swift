//
//  CategoryMenuController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CategoryMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var formulasData: [Formula] = []
    
    var categorys: [Category] = [.x3x3, .Megaminx, .x4x4, .RubiksClock, .SquareOne]
        
    
    var seletedCateogry: Category = .x3x3
    
    var categoryDidChanged: ((Category) -> Void)?
    
    private var seletedIndexPath: IndexPath {
        return IndexPath(row: categorys.index(of: seletedCateogry)!, section: 0)
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CategoryMenuCell.self, forCellReuseIdentifier: CategoryMenuCell.reuseIdentifier)
        tableView.rowHeight = Config.CategoryMenu.rowHeight
    }
    
    deinit {
        printLog("\(self) is dead")
    }
    
    // MARK: - TableView Delegate & DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryMenuCell.reuseIdentifier, for: indexPath) as! CategoryMenuCell
        
        let category = categorys[indexPath.row]
        cell.colorTitleLabel.text = category.rawValue
        cell.colorTitleLabelTextColor = UIColor.cubeTintColor()
        cell.checkImageView.isHidden = !(seletedCateogry == category)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let oldCell = tableView.cellForRow(at: seletedIndexPath) as! CategoryMenuCell
        oldCell.checkImageView.isHidden = true
        
        let newCell = tableView.cellForRow(at: indexPath) as! CategoryMenuCell
        seletedCateogry = categorys[indexPath.row]
        newCell.checkImageView.isHidden = false
        
        categoryDidChanged?(categorys[indexPath.row])
        
        delay(0.25) {
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}















