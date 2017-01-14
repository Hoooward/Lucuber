//
//  SettingViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

final class SettingViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView! {
        didSet {
            settingsTableView.registerNib(of: SettingsUserCell.self)
            settingsTableView.registerNib(of: SettingsMoreCell.self)
            
        }
    }
    
    struct Annotation {
        let name: String
        let segue: String
    }
    
    let moreAnnotations: [Annotation] = [
        
        Annotation(
            name: "反馈",
            segue: "showFeedback"
        ),
        Annotation(
            name: "关于",
            segue: "showAbout"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        navigationItem.backBarButtonItem?.title = "个人主页"
        
        if let gestures = navigationController?.view.gestureRecognizers {
            for recognizer in gestures {
                if recognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    settingsTableView.panGestureRecognizer.require(toFail: recognizer as! UIScreenEdgePanGestureRecognizer)
                    break
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
}
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case user
        case ui
        case more
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
        case .user:
            return 1
        case .ui:
            return 0
        case .more:
            return moreAnnotations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
            
        case .user:
            
            let cell: SettingsUserCell = tableView.dequeueReusableCell(for: indexPath)
            
            guard let realm = try? Realm(), let me = currentUser(in: realm) else {
                return UITableViewCell()
            }
            
            cell.configureCell(with: me)
            
            return cell
            
        case .ui:
            return UITableViewCell()
            
        case .more:
            let cell: SettingsMoreCell = tableView.dequeueReusableCell(for: indexPath)
            let annotation = moreAnnotations[indexPath.row]
            cell.annotationLabel.text = annotation.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
        case .user:
            
            guard let realm = try? Realm() else {
                return 0
            }
            
            guard let me = currentUser(in: realm) else {
                return 0
            }
            
            let tableViewWidth = settingsTableView.bounds.width
            let introLabelMaxWidth = tableViewWidth - Config.Settings.introInset
            
            let introducation = me.introduction ?? ""
            
            let rect = (introducation as NSString).boundingRect(with:  CGSize(width: introLabelMaxWidth, height: CGFloat(FLT_MAX)), options:  [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: Config.Settings.introFont], context: nil)
            
            let height = max(20 + 8 + 22 + 8 + ceil(rect.height) + 20, 20 + Config.Settings.userCellAvatarSize + 20)
            
            return height
            
        case .ui:
            return 60
            
        case .more:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
            
        case .user:
            performSegue(withIdentifier: "showEditProfile", sender: nil)
            
        case .ui:
            break
            
        case .more:
            let annotation = moreAnnotations[indexPath.row]
            let segue = annotation.segue
            performSegue(withIdentifier: segue, sender: nil)
        }
    }
    
}


















