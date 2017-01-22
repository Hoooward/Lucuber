//
//  ScoreViewControoller.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/25.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift


class ScoreViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(of: ScoreGroupCell.self)
            let view = UIView()
            tableView.tableFooterView = view
        }
    }
    
    @IBOutlet weak var scoreHeaderView: ScoreHeaderView!
    
    lazy var scoreGroups: Results<ScoreGroup>? = {
       return scoreGroupWith(user: currentUser(in: self.realm), inRealm: self.realm)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
        
        guard let scoreGroups = scoreGroups else {
            return
        }
        
        if scoreGroups.count == 1 {
            let indexPath = IndexPath(row: 0, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ScoreGroupCell {
                cell.setSelected(true, animated: false)
                tableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarLine.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "ShowScoreGroupDetail":
            
            let vc = segue.destination as! ScoreDetailViewController
            vc.scoreGroup = sender as? ScoreGroup
            
        default:
            break
        }
    }
}

extension ScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreGroups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScoreGroupCell = tableView.dequeueReusableCell(for: indexPath)
        
        if let scoreGroups = scoreGroups {
            cell.configureCell(with: scoreGroups[indexPath.row])
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ScoreGroupCell else {
            return
        }
        
        cell.showDetailAction = { [weak self] in
            self?.performSegue(withIdentifier: "ShowScoreGroupDetail", sender: self?.scoreGroups?[indexPath.row])
        }
        
//        if indexPath.row % 2 == 0 {
//            
//            cell.contentView.backgroundColor = UIColor.white
//        } else {
//            cell.contentView.backgroundColor = UIColor(red: 220/255.0, green: 238/255.0, blue: 252/255.0, alpha: 1)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let firstRowIndexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: firstRowIndexPath )
        
        if indexPath.row != 0 {
            cell?.setSelected(false, animated: true)
        }
        
        if let scoreGroups = scoreGroups {
            scoreHeaderView.configureGraphView(with: scoreGroups[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deletedGroupAction = UITableViewRowAction(style: .destructive, title: "删除", handler: { [weak self] action, indexPath in
            
            guard let strongSelf = self , let scoreGroups = strongSelf.scoreGroups else {
                return
            }
            
            CubeAlert.confirmOrCancel(title: "删除分组", message: "确定要删除这个分组吗? 与其关联的所有成绩将一起被删除!", confirmTitle: "删除", cancelTitles: "取消", inViewController: self, confirmAction: {
                
                let scoreGroup = scoreGroups[indexPath.row]
                try? strongSelf.realm.write {
                    scoreGroup.isDeleteByCreator = true
                    scoreGroup.timerList.forEach({
                        $0.isDeleteByCreator = true
                        $0.isPushed = false
                    })
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }, cancelAction: {
                
            })
            
        })
        
        
        
        return [deletedGroupAction]
    }
}


