//
//  ScoreDetailCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ScoreGroupDetailTimerCell: UITableViewCell {

    private enum IndicatorStyle {
        case normal
        case fastest
        case slowliest
        case dnf
    }
    
    private var indicatorStyle: IndicatorStyle = .normal {
        didSet {
            
            switch indicatorStyle {
                
            case .normal:
                indicatorImageView.isHidden = true
                dnfIndicatorImageView.isHidden = true
                
                timerLabel.textColor = UIColor.scoreGroupNormalLabelTextColor()
                
            case .fastest:
                indicatorImageView.isHidden = false
                dnfIndicatorImageView.isHidden = true
                indicatorImageView.image = UIImage(named: "icon_fastest")
                
                 timerLabel.textColor = UIColor.scoreGroupFastestLabelTextColor()
                
            case .slowliest:
                
                guard let score = score else {
                    indicatorImageView.isHidden = true
                    dnfIndicatorImageView.isHidden = true
                    break
                }
                
                indicatorImageView.isHidden = false
                indicatorImageView.image = UIImage(named: "icon_slowliest")
                
                if score.isDNF {
                    
                    dnfIndicatorImageView.isHidden = false
                    dnfIndicatorImageView.image = UIImage(named: "icon_DNF")
                }
                
                timerLabel.textColor = UIColor.scoreGroupSlowliestLabelTextColor()
                
                
            case .dnf:
                
                indicatorImageView.isHidden = false
                indicatorImageView.image = UIImage(named: "icon_DNF")
                dnfIndicatorImageView.isHidden = true
                
                timerLabel.textColor = UIColor.scoreGroupDNFLabelTextColor()
            }
        }
    }
    
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var scramblingLabel: UILabel!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var dnfIndicatorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private var score: Score?
    
    public func configureCell(with score: Score) {
        
        self.score = score
        
        createdDateLabel.text = Config.timeSectionFormatter().string(from: Date(timeIntervalSince1970: score.createdUnixTime))
        
        scramblingLabel.text = score.scramblingText
        
        timerLabel.text = score.timertext
        
        indicatorStyle = .dnf
        
        guard let scoreGroup = score.atGroup else {
            return
        }
        
        if let fastestScore = scoreGroup.fastestTimer, let slowliestScore = scoreGroup.slowliestTimer {
            
            if fastestScore.timer == score.timer {
                indicatorStyle = .fastest
                
            } else if slowliestScore.timer == score.timer {
                indicatorStyle = .slowliest
                
            } else {
                
                indicatorStyle = score.isDNF ? .dnf : .normal
            }
        }
        
       
    }
}
