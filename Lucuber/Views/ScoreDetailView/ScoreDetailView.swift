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
    
    @IBOutlet weak var fastyLabel: ScoreTimerLabel!
    @IBOutlet weak var slowlyLabel: ScoreTimerLabel!
    @IBOutlet weak var totalStepsLabel: ScoreTimerLabel!
    @IBOutlet weak var dnfLabel: ScoreTimerLabel!
    
    public var scoreGroup: ScoreGroup? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        guard let scoreGroup = scoreGroup else {
            return
        }
        fastyLabel.text = scoreGroup.realFastestTimerString
        slowlyLabel.text = scoreGroup.realSlowliestTimerString
        totalStepsLabel.text = scoreGroup.totalAverageString
        dnfLabel.text = scoreGroup.dnfCountString
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

    }
}
