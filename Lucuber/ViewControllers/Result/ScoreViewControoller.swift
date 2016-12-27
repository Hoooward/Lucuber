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
