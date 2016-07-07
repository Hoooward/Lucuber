//
//  CategoryPickViewCellTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 16/7/7.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class CategoryPickViewCell: UITableViewCell {

    @IBOutlet var pickView: UIPickerView!
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
        return 44
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if let view = view as? CubeCategoryItemView {
            view.configureWithCategory("test")
            return view
        } else {
            let view = CubeCategoryItemView()
            view.configureWithCategory("test")
            return view
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
}
