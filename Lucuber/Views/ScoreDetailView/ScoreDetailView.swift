//
//  ScoreDetailView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class ScoreDetailView: UIView {
    
    @IBOutlet weak var fastyLabel: UILabel!
    @IBOutlet weak var slowlyLabel: UILabel!
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var popLabel: UILabel!
    
//    lazy var tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.registerNib(of: ScoreDetailCell.self)
//        tableView.showsVerticalScrollIndicator = false
//        tableView.separatorStyle = .none
//        return tableView
//    }()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        fastyLabel.textColor = UIColor.gray
        slowlyLabel.textColor = UIColor.gray
        totalStepsLabel.textColor = UIColor.gray
        popLabel.textColor = UIColor.gray
        
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
//        makeUI()
//        layoutIfNeeded()
    }
    
//    func makeUI() {
//        
//        backgroundColor = UIColor.white
//        
//        addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let views: [String: Any] = [
//            "tableView": tableView
//        ]
//        
//        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views)
//        let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views)
//        
//        NSLayoutConstraint.activate(constraintH)
//        NSLayoutConstraint.activate(constraintV)
//    }
    
}

//extension ScoreDetailView: UITableViewDelegate, UITableViewDataSource {
//    
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 6
//    }
//    
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: ScoreDetailCell = tableView.dequeueReusableCell(for: indexPath)
//        return cell
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 20
//    }
//}
