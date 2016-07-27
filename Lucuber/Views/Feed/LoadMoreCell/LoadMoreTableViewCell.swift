//
//  LoadMoreTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/27/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {
    
    var isLoading: Bool = false {
        
        didSet {
            if isLoading {
               loadingActivityIndicator.startAnimating()
                noMoreResultLabel.hidden = true
            } else {
                delay(0.3) {
                    self.loadingActivityIndicator.stopAnimating()
                    
                    self.noMoreResultLabel.hidden = false
                }
            }
        }
    }

    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
  
    @IBOutlet weak var noMoreResultLabel: UILabel! {
        didSet {
            noMoreResultLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsets(top: 0, left: screenWidth, bottom: 0, right: 0)
//        noMoreResultLabel.hidden = true
    }

 
    
}
