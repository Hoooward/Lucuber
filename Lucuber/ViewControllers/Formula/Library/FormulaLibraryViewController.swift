//
//  FormulaLibraryViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaLibraryViewController: BaseCollectionViewController {
   
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = FormulaUserMode.Normal
        
        print("libraryData = \(formulasData)" )
        
        FormulaManager.shardManager().loadNewFormulas { [weak self] in
            self?.formulasData = FormulaManager.shardManager().Alls
            self?.collectionView?.reloadData()
        }
  
        refreshControl.addTarget(self, action: #selector(FormulaLibraryViewController.refreshFormula), forControlEvents: .ValueChanged)
        refreshControl.layer.zPosition = -1
        collectionView!.alwaysBounceVertical = true
        self.collectionView!.addSubview(refreshControl)
    }
    
    

    func refreshFormula() {
        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        formulaFile.getDataInBackgroundWithBlock { (data, error) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                dispatch_async(dispatch_get_main_queue(), {
                    print(json)
                    self.refreshControl.endRefreshing()
                    
                })
            }catch {
            }
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.refreshControl.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.refreshControl.beginRefreshing()
        
    }
    



    
}


















