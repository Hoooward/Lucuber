//
//  MediaViewCell.swift
//  Lucuber
//
//  Created by Howard on 8/1/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class MediaViewCell: UICollectionViewCell {

    @IBOutlet weak var mediaView: MediaView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mediaView.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        printLog(mediaView.scrollView)
//        mediaView.imageView.image = nil
    }

}
