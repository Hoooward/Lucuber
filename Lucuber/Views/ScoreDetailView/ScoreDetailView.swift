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
    @IBOutlet weak var popLabel: UILabel!
    
    public var scoreGroup: ScoreGroup? {
        didSet {
            recalculateScoreData()
        }
    }
    
    private var timerList: [Score] {
        if let scoreGroup = scoreGroup {
            return scoreGroup.timerList.sorted(byProperty: "createdUnixTime", ascending: false).map { $0 }
        }
        return [Score]()
    }
    
    public func recalculateScoreData() {
        
        let cacheResult = timerList.sorted(by: { $0.timer < $1.timer })
        
        fastyLabel.text = cacheResult.first?.timertext ?? "00:00:00"
        slowlyLabel.text = cacheResult.last?.timertext ?? "00:00:00"
        
        let total = cacheResult.map { $0.timer }.reduce(0) { total, num in total + num } / Double(cacheResult.count)
        printLog(total)
        let totalDate = Date(timeIntervalSince1970: total)
        totalStepsLabel.text = Config.timerDateFormatter().string(from: totalDate)
        
        if total == 0 {
            totalStepsLabel.text = "00:00:00"
        }
        
        popLabel.text = "\(cacheResult.filter { $0.isPop == true }.count)"
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        fastyLabel.textColor = UIColor.gray
        slowlyLabel.textColor = UIColor.gray
        totalStepsLabel.textColor = UIColor.gray
        popLabel.textColor = UIColor.gray
        
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

    }
}
