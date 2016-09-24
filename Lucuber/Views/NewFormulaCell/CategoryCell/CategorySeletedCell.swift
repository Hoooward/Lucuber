//
//  CategorySeletedCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CategorySeletedCell: UITableViewCell {

    @IBOutlet weak var indicatorView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!

    var categorys: [CategoryItem] = []
    
    var primaryCategory: Category? {
        didSet {
            
            if let category = primaryCategory {
                
                let index = categorys.map {$0.chineseText}.index(of: category.rawValue) ?? 0
                
                let title = categorys.map {$0.englishText}[index]
                
                categoryLabel.text = title
                categoryLabel.layoutIfNeeded()
                indicatorView.layoutIfNeeded()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadCategoryFromMainBundle()
    }
    
    private func loadCategoryFromMainBundle() {
        let path = Bundle.main.path(forResource: "CubeCategory.plist", ofType: nil)!
        let dict = NSDictionary(contentsOfFile: path)!
        let categorysInEnglish = dict["English"] as! [String]
        let categorysInChinese = dict["Chinese"] as! [String]
        
        for (index, text) in categorysInEnglish.enumerated() {
            let englishtText = text
            let chineseText = categorysInChinese[index]
            let item = CategoryItem(eText: englishtText, cText: chineseText)
            categorys.append(item)
        }
    }
    
}
