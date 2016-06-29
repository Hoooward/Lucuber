//
//  FormulaSearchBar.swift
//  Lucuber
//
//  Created by Howard on 16/6/29.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class FormulaSearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func makeUI() {
        searchBarStyle = .Minimal
        tintColor = UIColor.cubeTintColor()
        barTintColor = UIColor.cubeInputTextColor()
        placeholder = "搜索"
    }
    
    private func changeRightButtonTitle(text: String) {
        for subView in self.subviews[0].subviews {
            if subView.isKindOfClass(UIButton.classForCoder()) {
                let cancelButton = subView as! UIButton
                cancelButton.setTitle(text, forState: .Normal)
            }
        }
    }
    
    func dismissCancelButton() {
        self.setShowsCancelButton(false, animated: true)
    }
    
    func showCancelButton() {
        self.setShowsCancelButton(true, animated: true)
        changeRightButtonTitle("取消")
    }
    
}
