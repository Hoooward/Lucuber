//
//  TypePickViewCell.swift
//  Lucuber
//
//  Created by Howard on 8/9/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit



class TypePickViewCell: UITableViewCell {

    @IBOutlet weak var pickView: UIPickerView!
    
    var typesText = [String]()
    
    
    var typeDidChanged: ((Type) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pickView.delegate = self
        pickView.dataSource = self
        
        pickView.selectRow(1, inComponent: 0, animated: false)
//        pickerView(pickView, didSelectRow: 0, inComponent: 0)
        
    }
    
    
    var category: Category? {
        didSet {
            loadTypeFromMainBundle()
        }
    }

    
    private func loadTypeFromMainBundle() {
        
        let path = NSBundle.mainBundle().pathForResource("CubeType.plist", ofType: nil)!
        let dict = NSDictionary(contentsOfFile: path)!
        
        if let category = category,
            let types = dict[category.rawValue] as? [String] {
            
            self.typesText = types
            
        } else {
            
            self.typesText = dict[Category.x3x3.rawValue] as! [String]
        }
        
        pickView.reloadAllComponents()
        
        
       
        
    }
    
    
}


extension TypePickViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let view = CubeCategoryItemView()
        view.configureWithCategory(typesText[row])
        return view
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typesText.count
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let type = Type(rawValue: typesText[row]) {
            
            typeDidChanged?(type)
        }
    }
}







