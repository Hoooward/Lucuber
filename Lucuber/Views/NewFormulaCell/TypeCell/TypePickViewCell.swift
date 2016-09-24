//
//  TypePickViewCell.swift
//  Lucuber
//
//  Created by Howard on 8/9/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class TypePickViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var pickView: UIPickerView!
    
    var typesText = [String]()
    
    var typeDidChanged: ((Type) -> Void)?
    
    var primaryType: Type? {
        
        didSet {
            loadTypeFromMainBundle()
            if let type = primaryType {
                let index = typesText.index(of: type.rawValue) ?? 0
                pickView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickView.delegate = self
        pickView.dataSource = self
        pickView.selectRow(1, inComponent: 0, animated: false)
    }
    
    private func loadTypeFromMainBundle() {
        
        let path = Bundle.main.path(forResource: "CubeType.plist", ofType: nil)!
        let dict = NSDictionary(contentsOfFile: path)!
        
        if let type = primaryType,
            let types = dict[type.rawValue] as? [String] {
            
            self.typesText = types
            
        } else {
            
            self.typesText = dict[Category.x3x3.rawValue] as! [String]
        }
        
        pickView.reloadAllComponents()
        
    }
    
}


extension TypePickViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = CategoryItemView()
        view.configure(category: typesText[row])
        return view
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typesText.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let type = Type(rawValue: typesText[row]) {
            typeDidChanged?(type)
        }
    }
}







