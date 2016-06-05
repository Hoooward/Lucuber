//
//  FormulaLibraryViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FormulaLibraryViewController: BaseCollectionViewController {

    let cardLayout = CardCollectionViewLayout()
    let normalLayout = NormalCollectionViewLayout()
//    var currentLayout: UICollectionViewFlowLayout!
   
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = .Card
//         currentLayout = normalLayout
        
  
        self.collectionView!.addSubview(refreshControl)
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        refreshControl.beginRefreshing()
        
    }
}
