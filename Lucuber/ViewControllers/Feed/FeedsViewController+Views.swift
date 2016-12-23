//
//  FeedsViewController+Views.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

extension FeedsViewController {
    
    func makeSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), for: .normal)
        searchBar.delegate = self
        return searchBar
    }
    
    func makeFeedActionSheetView() -> ActionSheetView {
        
        let view = ActionSheetView(items: [
            .Option(
                title: "文字和图片",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    //                    strongSelf.newFeedAttachmentType = .media
                    strongSelf.cube_performSegue(with: .newFeed, sender: nil)
                }
            ),
            
            .Option(
                title: "公式",
                titleColor: UIColor.cubeTintColor(),
                action: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    let beforeUploadingFeedAction: (DiscoverFeed, NewFeedViewController) -> Void = {
                        [weak self] feed, newFeedViewController in
                        
                        self?.newFeedViewController = newFeedViewController
                        
                        DispatchQueue.main.async {
                            
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.tableView.customScrollsToTop()
                            strongSelf.tableView.beginUpdates()
                            
                            strongSelf.uploadingFeeds.insert(feed, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: Section.uploadingFeed.rawValue)
                            strongSelf.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                            
                            printLog("已刷新")
                            strongSelf.tableView.endUpdates()
                        }
                    }
                    
                    let afterCreatedFeedAction: (DiscoverFeed)-> Void = {
                        [weak self] feed in
                        
                        self?.newFeedViewController = nil
                        
                        DispatchQueue.main.async {
                            
                            guard let strongSelf = self else {
                                return
                            }
                            
                            feed.parseAttachmentsInfo()
                            
                            strongSelf.tableView.customScrollsToTop()
                            
                            strongSelf.tableView.beginUpdates()
                            
                            var animation: UITableViewRowAnimation = .automatic
                            
                            if !strongSelf.uploadingFeeds.isEmpty {
                                
                                strongSelf.uploadingFeeds = []
                                
                                let indexSet = IndexSet(integer: Section.uploadingFeed.rawValue)
                                
                                strongSelf.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
                                
                                animation = .none
                            }
                            
                            strongSelf.feeds.insert(feed, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: Section.feed.rawValue)
                            strongSelf.tableView.insertRows(at: [indexPath], with: animation)
                            
                            strongSelf.tableView.endUpdates()
                            
                        }
                        
                        // TODO: - joinGroup
                    }
                    
                    let getFeedsViewController: () -> FeedsViewController? = {
                        [weak self] in
                        return self
                    }
                    
                    
                    let navigationVC = UIStoryboard(name: "NewFormula", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let vc = navigationVC.viewControllers.first as! NewFormulaViewController
                    
                    /// 由于初始化顺序,下面三行代码先后顺序不可改变
                    guard let realm = try? Realm() else {
                        return
                    }
                    
                    vc.editType = NewFormulaViewController.EditType.newAttchment
                    vc.view.alpha = 1
                    
                    try? realm.write {
                        vc.formula = Formula.new(inRealm: realm)
                    }
                    vc.realm = realm
                    
                    vc.beforUploadingFeedAction = beforeUploadingFeedAction
                    vc.afterUploadingFeedAction = afterCreatedFeedAction
                    vc.getFeedsViewController = getFeedsViewController
                    
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
    }
}
