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


let scoreCellIdentifier = "ScoreCell"
public class ScoreView: SpringView {
    
    public var scoreGroup: ScoreGroup? {
        didSet {
           tableView.reloadData()
        }
    }
    
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
            let nib = UINib(nibName: scoreCellIdentifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: scoreCellIdentifier)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: scoreCellIdentifier, for: indexPath) as! ScoreCell
        
        if timerList.count == 0 {
            cell.scoreLabel.text = "成绩记录"
        } else {
            let score = timerList[indexPath.row]
            cell.scoreLabel.text = score.timertext
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}


















