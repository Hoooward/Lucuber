//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MyFormulaViewController: BaseCollectionViewController {
    
//    override func loadView() {
////        super.loadView()
//        
//        let view = MyFormulaVisitorView()
//        
//        view.backgroundColor = UIColor.black
//        
//        self.view = view
//        
//        printLog("")
//    }
//    


    override func viewDidLoad() {
        super.viewDidLoad()

        
        userMode = .card
        uploadMode = .my
        
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            self.collectionView?.reloadData()
        })
      
    }


}
