//
//  BaseCollectionViewController.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let CardCellIdentifier = "CardFormulaCell"
private let NormalCellIdentifier = "NormalFormulaCell"
private let DetailCellIdentifier = "DetailFormulaCell"

enum FormulaUserMode: Int {
    case Normal = 0
    case Card
    case Detail
}




class BaseCollectionViewController: UICollectionViewController {
     let refreshControl = UIRefreshControl()

     var userMode: FormulaUserMode = .Card {
        didSet {
            switch userMode {
            case .Card:
                view.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
            case .Normal:
                view.backgroundColor = UIColor.whiteColor()
            case .Detail:
                view.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.backgroundColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
      
        userMode = .Card
        collectionView!.registerNib(UINib(nibName: CardCellIdentifier, bundle: nil), forCellWithReuseIdentifier: CardCellIdentifier)
        collectionView!.registerNib(UINib(nibName: NormalCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NormalCellIdentifier)
        collectionView!.registerNib(UINib(nibName: DetailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailCellIdentifier)
        
        
        refreshControl.addTarget(self, action: #selector(BaseCollectionViewController.refreshFormula), forControlEvents: .ValueChanged)
       
        refreshControl.layer.zPosition = -1
        collectionView!.alwaysBounceVertical = true

    }
    
    func refreshFormula() {
        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/7CWYnFKC7ZPLMDJJ1jZPPuA.json")
        
        formulaFile.getDataInBackgroundWithBlock { (data, error) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(json)
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    
                })
            }catch {
            }
        }
        
    }





}
extension BaseCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OLLFormulas.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch userMode {
        case .Card:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCellIdentifier, forIndexPath: indexPath) as! CardFormulaCell
            return cell
        case .Normal:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NormalCellIdentifier, forIndexPath: indexPath) as! NormalFormulaCell
            return cell
        case .Detail:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DetailCellIdentifier, forIndexPath: indexPath)
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // 设置cell要显示数据
        let formula = OLLFormulas[indexPath.item]
        switch userMode {
        case .Normal:
            let cell = cell as! NormalFormulaCell
            cell.formulaLabel.text = formula
            cell.formulaNameLabel.text = "OLL " + "\(indexPath.item + 1)"
            cell.formulaImageView.image = UIImage(named: "OLL" + "\(indexPath.item + 1)")
        case .Card:
            let cell = cell as! CardFormulaCell
            cell.formulaLabel.text = formula
            cell.formulaNameLabel.text = "OLL " + "\(indexPath.item + 1)"
            cell.formulaImageView.image = UIImage(named: "OLL" + "\(indexPath.item + 1)")
        case .Detail:
            let cell = cell as! DetailFormulaCell
//            cell.formulaLabel.text = formula
            cell.formulaNameLabel.text = "OLL " + "\(indexPath.item + 1)"
            cell.formulaImageView.image = UIImage(named: "OLL" + "\(indexPath.item + 1)")
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch userMode {
        case .Normal:
            return CGSize(width: screenWidth, height: 80)
        case .Card:
            return CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
        case .Detail:
            return CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        switch userMode {
        case .Normal:
            return UIEdgeInsetsZero
        case .Card:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        case .Detail:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        
    }
}
