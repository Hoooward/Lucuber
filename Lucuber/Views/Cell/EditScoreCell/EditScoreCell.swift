//
//  EditScoreCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/21.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class EditScoreCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var deletedButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var deletedButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var cubeScores: CubeScores? {
        didSet {
            guard let cubeScores = cubeScores else {
                return
            }
            categoryLabel.text = cubeScores.categoryString
            scoreLabel.text = cubeScores.scoreTimerString
        }
    }
    public var deleteScoreAction: ((EditScoreCell, CubeScores) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabelLeadingConstraint.constant = CubeRuler.iPhoneHorizontal(5, 10, 15).value
        deletedButtonTrailingConstraint.constant = CubeRuler.iPhoneHorizontal(5, 10, 15).value
        
        deletedButton.addTarget(self, action: #selector(EditScoreCell.tryRemoveScore), for: .touchUpInside)
    }

    func tryRemoveScore() {
        
        if let cubeScores = cubeScores {
            deleteScoreAction?(self, cubeScores)
        }
    }
    
}
