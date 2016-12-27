//
//  ScoreDetailView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Spring

public class ScoreDetailView: SpringView {
    
    @IBOutlet weak var fastyLabel: UILabel!
    @IBOutlet weak var slowlyLabel: UILabel!
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var dnfLabel: UILabel!
    
    public var scoreGroup: ScoreGroup? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        guard let scoreGroup = scoreGroup else {
            return
        }
        fastyLabel.text = scoreGroup.fastestTimerString
        slowlyLabel.text = scoreGroup.slowliestTimerString
        totalStepsLabel.text = scoreGroup.totalAverageString
        dnfLabel.text = scoreGroup.dnfCountString
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        fastyLabel.textColor = UIColor.gray
        slowlyLabel.textColor = UIColor.gray
        totalStepsLabel.textColor = UIColor.gray
        dnfLabel.textColor = UIColor.gray
        
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

    }
}
