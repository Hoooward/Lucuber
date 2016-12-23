//
//  SearchFeedsViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

private let screenHeight: CGFloat = UIScreen.main.bounds.height

final class SearchFeedsViewController: UIViewController, SearchAction {
    
    var originalNavigationControllerDelegate: UINavigationControllerDelegate?
    var searchTransition: SearchTransition?
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), for: .normal)
            searchBar.returnKeyType = .done
        }
    }
    
    @IBOutlet weak var searchBarBottomLineView: HorizontalLineView! {
        didSet {
            searchBarBottomLineView.lineColor = UIColor(white: 0.68, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
            tableView.backgroundColor = UIColor.white
            tableView.tableFooterView = UIView()
//            tableView.separatorColor = 
            tableView.separatorStyle = .singleLine
        }
    }
    
    var feeds = [DiscoverFeed]() {
        didSet {
            if feeds.isEmpty {
                
                
            }
        }
    }
    
    var keyword: String? {
        didSet {
            if keyword == nil {
                
            }
            if let keyword = keyword, keyword.isEmpty {
                
            }
        }
    }
    
    func clearSearchResults() {
        feeds = []
    }
    
    var isFirstAppear = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isFirstAppear {
            
            delay(0.3) { [weak self] in
                self?.searchBar.setShowsCancelButton(true, animated: true)
            }
            delay(0.4) { [weak self] in
                self?.searchBar.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        recoverSearchTransition()
        moveUpsearchBar()
        
        isFirstAppear = false
    }
}


extension SearchFeedsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] _ in
            self?.searchBarBottomLineView.alpha = 1
            
        }, completion: nil)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        
        searchBar.resignFirstResponder()
        
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] _ in
            self?.searchBarBottomLineView.alpha = 0
            }, completion: { finished in
        })
        
        _ = navigationController?.popViewController(animated: true)
    }
    
}







