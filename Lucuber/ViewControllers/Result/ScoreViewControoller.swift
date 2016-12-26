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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var date: [Double] = realm.objects(Score.self).map {
            $0.timer
        }
        
        var labels: [String] = realm.objects(Score.self).map {
            $0.timertext
        }
        
        scoreHeaderView.graphView.set(data: date, withLabels: labels)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreHeaderView.graphView.shouldAdaptRange = true
        
        scoreHeaderView.graphView.showsHorizontalScrollIndicator = false
        scoreHeaderView.graphView.lineStyle = .smooth
        scoreHeaderView.graphView.backgroundFillColor = UIColor.cubeTintColor()
        scoreHeaderView.graphView.lineColor = UIColor.white
        scoreHeaderView.graphView.lineWidth = 1
        scoreHeaderView.graphView.dataPointSpacing = 80
        scoreHeaderView.graphView.dataPointSize = 2
        scoreHeaderView.graphView.dataPointFillColor = UIColor.white
        scoreHeaderView.graphView.shouldFill = true
        
        scoreHeaderView.graphView.fillGradientType = .linear
        scoreHeaderView.graphView.fillColor = UIColor.white.withAlphaComponent(0.4)

        scoreHeaderView.graphView.fillGradientStartColor = UIColor.white.withAlphaComponent(0.5)
        scoreHeaderView.graphView.fillGradientEndColor = UIColor.white.withAlphaComponent(0.3)
        
        scoreHeaderView.graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        scoreHeaderView.graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        scoreHeaderView.graphView.referenceLineLabelColor = UIColor.white
        scoreHeaderView.graphView.dataPointLabelColor = UIColor.white
        
        scoreHeaderView.graphView.rangeMax = 20
        
        let date: [Double] = realm.objects(Score.self).map {
            $0.timer
        }
        
        let labels: [String] = realm.objects(Score.self).map {
            $0.timertext
        }
        
        scoreHeaderView.graphView.set(data: date, withLabels: labels)

        
        
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScoreGroupCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}
