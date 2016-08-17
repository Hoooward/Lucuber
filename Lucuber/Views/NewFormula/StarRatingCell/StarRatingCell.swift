//
//  StarRatingCell.swift
//  Lucuber
//
//  Created by Howard on 7/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class StarRatingCell: UITableViewCell {
    
    var formula: Formula? {
        didSet {
            if let _ = formula {
            }
        }
    }

    @IBOutlet weak var starRatingView: StarRatingView!
    
    var ratingDidChanged: ((rating: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        starRatingView.delegate = self
        starRatingView.rating = 3
        starRatingView.maxRating = 5
        starRatingView.editable = true
    }
}

// MARK: - StarRatingDelegate
extension StarRatingCell: StarRatingViewDelegate {
    
    func ratingDidChange(rateView: StarRatingView, rating: Int) {
        
        ratingDidChanged?(rating: rating)
    }
}
