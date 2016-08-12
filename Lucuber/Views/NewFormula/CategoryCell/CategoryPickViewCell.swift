//
//  CategoryPickViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

///魔方类型 english - 3x3x3, Chinese - 三阶
class CategoryItem {
    var englishText = ""
    var chineseText = ""
    init(eText: String, cText: String) {
        self.englishText = eText
        self.chineseText = cText
    }
}

class CategoryPickViewCell: UITableViewCell {
    
// MARK: - Properties
    @IBOutlet weak var pickView: UIPickerView!
    
    var primaryCategory: Category? {
        didSet {
            
            if categorys.isEmpty {
                return
            }
            
            
            if let primaryCategory = primaryCategory {
                
                let index = categorys.map { $0.chineseText }.indexOf(primaryCategory.rawValue) ?? 0
                pickView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    var categorys: [CategoryItem] = []
    
    var categoryDidChanged: ((category: CategoryItem) -> Void)?
    
// MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        loadCategoryFromMainBundle()
        makeUI()
    }
    
    private func makeUI() {
        pickView.delegate = self
        pickView.dataSource = self
        pickView.selectRow(1, inComponent: 0, animated: true)
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

//MARK: - UIPickerViewDelegate&DataSource
extension CategoryPickViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if let view = view as? CubeCategoryItemView {
            view.configureWithCategory(categorys[row].englishText)
            return view
        } else {
            let view = CubeCategoryItemView()
            view.configureWithCategory(categorys[row].englishText)
            return view
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorys.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //发送通知到HeaderView
        NSNotificationCenter.defaultCenter().postNotificationName(CategotyPickViewDidSeletedRowNotification, object: nil, userInfo: [AddFormulaNotification.CategoryChanged.rawValue : categorys[row]])
        
        categoryDidChanged?(category: categorys[row])
    }
    
}
