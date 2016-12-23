//
//  SearchTrigger.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

protocol SearchTrigeer: class {
    var originalNavigationControllerDelegate: UINavigationControllerDelegate? { get set }
    var searchTransition: SearchTransition { get }
}

extension SearchTrigeer where Self: UIViewController {
    
    func prepareSearchTransition() {
        
        originalNavigationControllerDelegate = navigationController?.delegate
        navigationController?.delegate = searchTransition
    }
    
    func recoverOriginalNavigationDelegate() {
        if let originalNavigationControllerDelegate = originalNavigationControllerDelegate {
            navigationController?.delegate = originalNavigationControllerDelegate
        }
    }
}

protocol SearchAction: class {
    var searchBar: UISearchBar! { get }
    var searchBarTopConstraint: NSLayoutConstraint! { get }
    
    var originalNavigationControllerDelegate: UINavigationControllerDelegate? { get }
    var searchTransition: SearchTransition? { get set }
}

extension SearchAction where Self: UIViewController {
    
    func recoverSearchTransition() {
        if let delegate = searchTransition {
            navigationController?.delegate = delegate
        }
    }
    
    func moveUpsearchBar() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            [weak self] _ in
            self?.searchBarTopConstraint.constant = 20
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func prepareOriginalNavigationControllerDelegate() {
        searchTransition = navigationController?.delegate as? SearchTransition
        navigationController?.delegate = originalNavigationControllerDelegate
    }
}
