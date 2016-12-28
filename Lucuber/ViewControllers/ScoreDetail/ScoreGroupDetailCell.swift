//
//  ScoreGroupDetailCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ScoreGroupDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailLabel.textAlignment = .right
    }
    
    public func configureCell(with scoreGroup: ScoreGroup?, title: String) {
        
        titleLabel.text = title
        
        guard let scoreGroup = scoreGroup else {
            return
        }
        var detailText = ""
        
        switch title {
        case "还原次数":
            detailText = "\(scoreGroup.timerList.count)"
            
        case "单次最快":
            detailText = scoreGroup.realFastestTimerString
            detailLabel.textColor = UIColor.scoreGroupFastestLabelTextColor()
            
        case "单次最慢":
            detailText = scoreGroup.realSlowliestTimerString
            detailLabel.textColor = UIColor.scoreGroupSlowliestLabelTextColor()
            
        case "后5次平均":
            detailText = scoreGroup.fiveStepsAverageString
            
        case "后10次平均":
            detailText = scoreGroup.tenStepsAverageString
            
        case "去头尾平均":
            detailText = scoreGroup.excludeFastestAndSlowliestOnAverage
            
        case "所有平均(去DNF)":
            detailText = scoreGroup.totalAverageString
            
        case "DNF":
            detailText = scoreGroup.dnfCountString
        default:
            break
        }
        
        detailLabel.text = detailText
    }
    
}
