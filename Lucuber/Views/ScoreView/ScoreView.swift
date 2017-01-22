//
//  ScoreTableView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import LucuberTimer
import RealmSwift
import Spring


public class ScoreView: SpringView {
    
    public var scoreGroup: ScoreGroup? {
        didSet {
           tableView.reloadData()
        }
    }
    
    public var afterChangeScoreToDNF: (() -> Void)?
    
    fileprivate var timerList: [Score] {
        if let scoreGroup = scoreGroup {
            return scoreGroup.timerList.sorted(byProperty: "createdUnixTime", ascending: false).map { $0 }
        }
        return [Score]()
    }
    
    public func updateTableView(with newScore: Score, inRealm realm: Realm) {
        let newScoreIndexPath = IndexPath(item: 0, section: 0)
        if timerList.count == 1 {
            tableView.reloadRows(at: [newScoreIndexPath], with: .right)
        } else {
            tableView.insertRows(at: [newScoreIndexPath], with: .left)
        }
    }
    
    public var scores: [Score] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.showsVerticalScrollIndicator = false
            tableView.registerNib(of: ScoreCell.self)
        }
    }
}

extension ScoreView: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerList.count == 0 ? 1 : timerList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScoreCell = tableView.dequeueReusableCell(for: indexPath)
        
        if timerList.count == 0 {
            cell.scoreLabel.text = "成绩记录"
        } else {
            cell.configreCell(with: timerList[indexPath.row])
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let score = timerList[safe: indexPath.row] else {
            return nil
        }
        
        let dnfAction = UITableViewRowAction(style: .normal, title: score.isDNF ? "恢复" : "DNF", handler: {[weak self] action, indexPath in
            
            
            guard let strongSelf = self, let realm = strongSelf.scoreGroup?.realm else {
                return
            }
            let score = strongSelf.timerList[indexPath.row]
            try? realm.write {
                score.isDNF = !score.isDNF
                score.isPushed = false
            }
            
            tableView.reloadRows(at: [indexPath], with: .right)
            
            strongSelf.afterChangeScoreToDNF?()
            
            
        })
        
        return [dnfAction]
    }
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return timerList.count != 0 
    }
    
  
    
    
}


















