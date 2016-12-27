//
//  ScoreGroupCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/25.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ScoreGroupCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fastestLabel: UILabel!
    @IBOutlet weak var slowliestLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 238/255.0, blue: 252/255.0, alpha: 1)
        selectedBackgroundView = view
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter
    }()
    
    public func configureCell(with scoreGroup: ScoreGroup) {
        
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: scoreGroup.createdUnixTime))
        fastestLabel.text = scoreGroup.realFastestTimerString
        slowliestLabel.text = scoreGroup.realSlowliestTimerString
        countLabel.text = "\(scoreGroup.timerList.count)"
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.isHighlighted = selected
    }

    
 
}
