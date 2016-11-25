//
//  StarRatingCell.swift
//  Lucuber
//
//  Created by Howard on 7/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class StarRatingCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var starRatingView: StarRatingView!
    
    var formula: Formula?
    
    var ratingDidChanged: ((_ rating: Int) -> Void)?
    
    // MARK: - Life Cycle
    
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

extension StarRatingCell: StarRatingViewDelegate {
    
    func ratingDidChange(rateView: StarRatingView, rating: Int) {
        
        ratingDidChanged?(rating)
    }
}
