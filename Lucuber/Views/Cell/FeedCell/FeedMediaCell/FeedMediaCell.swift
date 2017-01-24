
//
//  FeedMediaCell.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    
    var delete:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = UIColor.cubeBackgroundColor()
        imageView.layer.borderWidth = 1.0 / UIScreen.main.scale
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        contentView.backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedMediaCell.deleteImage(sender:)))
        
        deleteImageView.addGestureRecognizer(tapGesture)
    }
    
    func deleteImage(sender: UIGestureRecognizer) {
        delete?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureWithImage(image: UIImage) {
        imageView.image = image
        deleteImageView.isHidden = false
    }

    func configureWithAttachment(_ attachment: ImageAttachment, bigger: Bool) {

        if attachment.isTemporary {
            imageView.image = attachment.image

        } else {
            let size = bigger ? Config.FeedBiggerImageCell.imageSize : Config.FeedAnyImagesCell.imageSize

			imageView.showActivityIndicatorWhenLoading = true
            imageView.cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: size)
        }

        deleteImageView.isHidden = true
    }
}
