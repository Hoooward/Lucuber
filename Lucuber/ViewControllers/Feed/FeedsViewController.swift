//
//  FeedsViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedsViewController: UIViewController {
    
    // MARK: - Properties
    
//    private var newFeedAttachmentType: NewFeedViewController.Attachment = .Media
    
    var feeds = [Feed]()
    var uploadingFeeds = [Feed]()
    
    @IBOutlet weak var loadingFeedsIndicator: UIActivityIndicatorView!
    private lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedsViewController.tryRefreshOrGetNewFeeds), for: .valueChanged)
        return refreshControl
        
    }()
    
    private lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), for: .normal)
        searchBar.delegate = self
        return searchBar
        
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var newFeedActionSheetView: ActionSheetView = {
        
        let view = ActionSheetView(items: [
            .Option(
                title: "文字和图片",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
//                    strongSelf.newFeedAttachmentType = .media
                    strongSelf.performSegue(withIdentifier: "ShowAddFeed", sender: nil)
                }
            ),
            .Option(
                title: "公式",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    let navigationVC = UIStoryboard(name: "AddFormula", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let newVc = navigationVC.viewControllers.first as! NewFormulaViewController
                    
                    /// 由于初始化顺序,下面三行代码先后顺序不可改变
                    newVc.editType = NewFormulaViewController.EditType.newAttchment
                    newVc.view.alpha = 1
                    newVc.formula = Formula.creatNewDefaultFormula()
                    
                    strongSelf.present(navigationVC, animated: true, completion: nil)
                    
                }
            ),
            .Option(
                title: "复原成绩",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                }
            ),
            .Cancel
            
            ]
        )
        return view
        
    }()
    
    // MARK: - Target & Action
    
    func tryRefreshOrGetNewFeeds() {
        
    }
    
    @IBAction func creatNewFeed(_ sender: AnyObject) {
    }
    
    // MARK: - PrepareForSegue
    
 
}

// MARK: - Searchbar Delegaate
extension FeedsViewController: UISearchBarDelegate {
    
}
