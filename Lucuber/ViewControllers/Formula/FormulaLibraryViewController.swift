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

//    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = .Card
        
  
        self.collectionView!.addSubview(refreshControl)
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        refreshControl.beginRefreshing()
        
    }
}
