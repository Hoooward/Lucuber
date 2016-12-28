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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ScoreGroupCell
        cell.setSelected(true, animated: false)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
