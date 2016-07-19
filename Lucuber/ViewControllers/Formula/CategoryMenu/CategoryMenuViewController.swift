//
//  TypeMenuViewController.swift
//  Lucuber
//
//  Created by Howard on 16/6/30.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

final private class CategoryCheckCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_location_checkmark"))
        return imageView
    }()
    
    var colorTitleLabelTextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitleLabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(checkImageView)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        tintColor = UIColor.cubeTintColor()
        
        do {
            let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activateConstraints([centerY, centerX])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activateConstraints([centerY, trailing])
        }
    }
}

class CategoryMenuViewController: UIViewController {

    var formulsData: [Formula] = []
    
    var cubeCategorys = [Category.x3x3, Category.Megaminx, Category.x4x4, Category.RubiksClock, Category.SquareOne]
    
//    lazy var actionSheetView = ActionSheetView(items: cubeCategorys)
    
    var items: [ActionSheetView.Item] = []
    

    var seletedCategory = Category.x3x3
    
    var actionSheetView: ActionSheetView?
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.tintColor = UIColor.cubeTintColor()
        
        
        tableView.registerClass(CategoryCheckCell.self, forCellReuseIdentifier: CategoryCheckCell.reuseIdentifier)
        for category in cubeCategorys {
            let item = ActionSheetView.Item.Default(title: category.rawValue, titleColor: UIColor.cubeTintColor(), action: {
                
                return false
            })
            items.append(item)
        }
        
//        actionSheetView = ActionSheetView(items: items)
//        view.addSubview(actionSheetView!)
       
//        actionSheetView?.showInView(view)

        
       /// 尝试获取所有公式的Map
       let _ = FormulaManager.shardManager().Alls.map {
            formulas in
            formulas.map { formula in
                
                self.formulsData.append(formula)
            }
        }
        
        //遍历所有元素, 判断其类型
        var catetory = Category.x3x3
        for formula in formulsData {
            if formula.category != catetory {
                print("")
            }
        }
        
        print(formulsData.count)
    }
}

extension CategoryMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cubeCategorys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CategoryCheckCell.reuseIdentifier, forIndexPath: indexPath) as! CategoryCheckCell
        
        cell.colorTitleLabel.text = cubeCategorys[indexPath.row].rawValue
        cell.colorTitleLabelTextColor = UIColor.cubeTintColor()
        
        return cell
    }
    
    
}












































