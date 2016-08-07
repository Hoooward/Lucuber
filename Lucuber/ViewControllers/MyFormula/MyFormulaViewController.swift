//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class MyFormulaViewController: BaseFormulaViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = FormulaUserMode.Card
        seletedCategory = Category.x3x3
        
        //测试数据
//        var formulas = [Formula]()
//        for index in 1...12 {
//            let formula = Formula.creatNewDefaultFormula()
//            formula.name = "F2L - " + "\(index)"
//            let content = FormulaContent()
//            content.text = "r' (R2 U R' U)(R U' U' R' U) (r R')"
//            formula.contents.append(content)
//            formula.imageName = "cube_Placehold_image_" + "\(index)"
//            formulas.append(formula)
//        }
//        formulasData.append(formulas)
        
        
      
        
        
        uploadFormulas(.My) {
            [weak self] in
            
            self?.collectionView?.reloadData()
        }
            
        
    }
    
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        if let button = parentViewController?.navigationItem.rightBarButtonItem as? CategoryBarButtonItem  {
//            button.seletedCategory = seletedCategory
//        }
//    
//    }
    
    
    

   
    func rightBarButtonClick(sender: CategoryBarButtonItem) {
        
    }
    
}
