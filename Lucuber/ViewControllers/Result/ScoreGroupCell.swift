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
    @IBOutlet weak var detailButton: UIButton!
    
    public var showDetailAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 238/255.0, blue: 252/255.0, alpha: 1)
        selectedBackgroundView = view
        
        detailButton.addTarget(self, action: #selector(ScoreGroupCell.showDetail(sender:)), for: .touchUpInside)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter
    }()
    
    private var scoreGroup: ScoreGroup?
    
    public func configureCell(with scoreGroup: ScoreGroup) {
        
        self.scoreGroup = scoreGroup
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: scoreGroup.createdUnixTime))
        fastestLabel.text = scoreGroup.realFastestTimerString
        slowliestLabel.text = scoreGroup.realSlowliestTimerString
        countLabel.text = "\(scoreGroup.timerList.count)"
        
        if scoreGroup.timerList.isEmpty {
            detailButton.isEnabled = false
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.isHighlighted = selected
        
        detailButton.isEnabled = selected
        
        guard let scoreGroup = scoreGroup else { return }
        if scoreGroup.timerList.isEmpty {
            detailButton.isEnabled = false
        }
    }
    
    @objc private func showDetail(sender: UIButton) {
        showDetailAction?()
    }

    
 
}
