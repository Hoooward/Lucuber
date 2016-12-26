//
//  NewScoreGroupViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/26.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class NewScoreGroupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var afterSelectedNewCategory: ((String) -> Void)?

    fileprivate lazy var categorys: [String] = {
        return self.loadCategoryFormMainBundle()
    }()
    
    private func loadCategoryFormMainBundle() -> [String] {
        let path = Bundle.main.path(forResource: "CubeCategory.plist", ofType: nil)!
        let dict = NSDictionary(contentsOfFile: path)!
        let categorysInChinese = dict["Chinese"] as! [String]
        return categorysInChinese
    }
}
extension NewScoreGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CategoryCell = tableView.dequeueReusableCell(for: indexPath)
        cell.categoryLabel.text = categorys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        afterSelectedNewCategory?(categorys[indexPath.row])
        
        dismiss(animated: true, completion: nil)
    }
}

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
}
