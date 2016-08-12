//
//  CategorySeletedCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CategorySeletedCell: UITableViewCell {

    @IBOutlet weak var indicaterView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    

    
    var categorys: [CategoryItem] = []
    
    var primaryCategory: Category? {
        didSet {
            
            if let category = primaryCategory {
                
                let index = categorys.map {$0.chineseText}.indexOf(category.rawValue) ?? 0
                
                let title = categorys.map {$0.englishText}[index]
                
                categoryLabel.text = title
                categoryLabel.layoutIfNeeded()
                indicaterView.layoutIfNeeded()
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadCategoryFromMainBundle()
    }
    
    private func loadCategoryFromMainBundle() {
        let path = NSBundle.mainBundle().pathForResource("CubeCategory.plist", ofType: nil)!
        let dict = NSDictionary(contentsOfFile: path)!
        let categorysInEnglish = dict["English"] as! [String]
        let categorysInChinese = dict["Chinese"] as! [String]
        for (index, text) in categorysInEnglish.enumerate() {
            let englishtText = text
            let chineseText = categorysInChinese[index]
            let item = CategoryItem(eText: englishtText, cText: chineseText)
            categorys.append(item)
        }
    }
    
}
