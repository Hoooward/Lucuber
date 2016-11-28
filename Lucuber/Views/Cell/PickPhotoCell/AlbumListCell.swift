//
//  AlbumListCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class AlbumListCell: UITableViewCell {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.text = nil
        titleLabel.text = nil
        posterImageView.image = nil
    }
    
    
}
