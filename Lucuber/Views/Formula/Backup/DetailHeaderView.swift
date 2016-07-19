//
//  DetailHeaderView.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailHeaderView: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var creatUserLabel: UILabel!
    @IBOutlet var creatTimeLabel: UILabel!

    @IBOutlet var ratingView: StarRatingView!
    
    var formula: Formula? {
        didSet {
            if let _ = formula {
                
            }
        }
    }

}
