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


let scoreCellIdentifier = "ScoreCell"
public class ScoreView: UIView {
    
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
        tableView.insertRows(at: [newScoreIndexPath], with: .automatic)
    }
    
    public var scores: [Score] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
//        tableView.backgroundColor = UIColor.white
        let nib = UINib(nibName: scoreCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: scoreCellIdentifier)
        return tableView
    }()
    
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        makeUI()
        layoutIfNeeded()
    }
    func makeUI() {
        
        backgroundColor = UIColor.white
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "tableView": tableView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views)
        let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate(constraintV)
        
    }
}

extension ScoreView: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: scoreCellIdentifier, for: indexPath) as! ScoreCell
        
        let score = timerList[indexPath.row]
        cell.scoreLabel.text = score.timertext
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}


















