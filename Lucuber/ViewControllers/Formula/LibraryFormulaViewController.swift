//
//  LibraryFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class LibraryFormulaViewController: BaseCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        userMode = .normal
        uploadMode = .library
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
//        
//        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
//            
//            self.collectionView?.reloadData()
//        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            self.collectionView?.reloadData()
        })
    }

}
