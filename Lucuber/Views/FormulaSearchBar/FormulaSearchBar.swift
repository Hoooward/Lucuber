//
//  FormulaSearchBar.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FormulaSearchBar: UISearchBar {
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI () {
        
        searchBarStyle = .minimal
        tintColor = UIColor.cubeTintColor()
        barTintColor = UIColor.cubeInputTextColor()
        placeholder = "搜索"
    }
    
    // MARK: - Action & Target
    
    private func changeRightButtonTitle(text: String) {
        
        self.subviews[0].subviews.forEach {
            subView in
            if subView.isKind(of: UIButton.classForCoder()) {
                let cancelButton = subView as! UIButton
                cancelButton.setTitle(text, for: .normal)
            }
        }
    }
    
    func dismissCancelButton() {
        
        self.setShowsCancelButton(false, animated: true)
    }
    
    func showCancelButton() {
        
        self.setShowsCancelButton(true, animated: true)
        changeRightButtonTitle(text: "取消")
    }
}
