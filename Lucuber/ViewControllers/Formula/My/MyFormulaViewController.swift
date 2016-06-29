//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class MyFormulaViewController: BaseCollectionViewController {

    let cardLayout = CardCollectionViewLayout()
    let normalLayout = NormalCollectionViewLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = .Normal
    }
    
    override var userMode: FormulaUserMode {
        didSet {
            var currentLayout = collectionViewLayout
            if collectionView?.collectionViewLayout == cardLayout  {
                currentLayout = normalLayout
            } else {
                currentLayout = cardLayout
            }
            UIView.animateWithDuration(0.3, animations: {
                self.collectionView?.reloadData()
                self.collectionView?.setCollectionViewLayout(currentLayout, animated: true)
            
            })
        }
    }
    
   
    
}
