//
//  CategoryPickViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CategoryPickViewCell: UITableViewCell {
    
    @IBOutlet var pickView: UIPickerView!
    let categorys = ["二阶", "三阶", "四阶", "五阶","六阶", "七阶", "五魔方", "Square One", "Megaminx", "Pyraminx", "Rubik's Clock", "八阶", "九阶", "十阶", "十一阶", "其它"]
    override func awakeFromNib() {
        super.awakeFromNib()
        pickView.delegate = self
        pickView.dataSource = self
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
extension CategoryPickViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if let view = view as? CubeCategoryItemView {
            view.configureWithCategory(categorys[row])
            return view
        } else {
            let view = CubeCategoryItemView()
            view.configureWithCategory(categorys[row])
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
        print("seleted")
        NSNotificationCenter.defaultCenter().postNotificationName(CategotyPickViewDidSeletedRowNotification, object: nil, userInfo: nil)
    }
    
}
