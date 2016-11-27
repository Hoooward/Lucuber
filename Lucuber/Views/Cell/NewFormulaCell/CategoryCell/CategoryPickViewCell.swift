//
//  CategoryPickViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CategoryPickViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var pickView: UIPickerView!
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        if categorys.isEmpty { return }
        
        let category = formula.category
        
        let index = categorys.map { $0.chineseText }.index(of: category.rawValue) ?? 0
        pickView.selectRow(index, inComponent: 0, animated: true)
        
    }
    
//    var primaryCategory: Category? {
//        
//        didSet {
//            
//            if categorys.isEmpty {
//                return
//            }
//            
//            if let primaryCategory = primaryCategory {
//                
//                let index = categorys.map { $0.chineseText }.index(of: primaryCategory.rawValue) ?? 0
//                pickView.selectRow(index, inComponent: 0, animated: true)
//            }
//        }
//    }
    
    fileprivate var categorys: [CategoryItem] = []
    public var categoryDidChanged: ((_ category: CategoryItem) -> Void)?
    
    // MARK: - Life Cycle
    
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


extension CategoryPickViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let view = view as? CategoryItemView {
            view.configure(category: categorys[row].englishText)
            return view
            
        } else {
            let view = CategoryItemView()
            view.configure(category: categorys[row].englishText)
            return view
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        NotificationCenter.default.post(name: .categotyPickViewDidSeletedRowNotification, object: nil, userInfo: [Config.NewFormulaNotificationKey.category : categorys[row]])
        
        categoryDidChanged?(categorys[row])
    }
    
}
