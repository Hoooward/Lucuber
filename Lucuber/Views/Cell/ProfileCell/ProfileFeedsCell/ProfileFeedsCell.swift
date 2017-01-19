//
//  ProfileFeedsCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ProfileFeedsCell: UICollectionViewCell {

    @IBOutlet weak var iconImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var accessoryImageViewtrailingConstraint: NSLayoutConstraint!
    
    fileprivate var enabled: Bool = false {
        willSet {
            if newValue {
                iconImageView.tintColor = UIColor.cubeTintColor()
                nameLabel.textColor = UIColor.cubeTintColor()
                accessoryImageView.isHidden = false
                accessoryImageView.tintColor = UIColor.lightGray
            } else {
                iconImageView.tintColor = UIColor.lightGray
                nameLabel.textColor = UIColor.lightGray
                accessoryImageView.isHidden = true
            }
        }
    }
    
    var feedAttachments: [ImageAttachment?]? {
        willSet {
            guard let _attachments = newValue else {
                return
            }
            
            enabled = !_attachments.isEmpty
            
            // 对于从左到右排列，且左边的最新，要处理数量不足的情况
            var attachments = _attachments
            
            let imageViews = [
                imageView1,
                imageView2,
                imageView3,
                imageView4,
                ]
            
            let shortagesCount = max(imageViews.count - attachments.count, 0)
            
            // 不足补空
            if shortagesCount > 0 {
                let shortages = Array<ImageAttachment?>(repeating: nil, count: shortagesCount)
                attachments.insert(contentsOf: shortages, at: 0)
            }
            
            for i in 0..<imageViews.count {
                if i < shortagesCount {
                    imageViews[i]?.image = nil
                } else {
                    if let thumbnailImage = attachments[i] {
                        // 暂时使用 URL 下载, 之后可以考虑再上传 Feeds 时生成缩略图
                        imageViews[i]?.cube_setImageAtFeedCellWithAttachment(attachment: thumbnailImage, withSize: imageViews[i]?.frame.size ?? CGSize.zero)
                    } else {
                        imageViews[i]?.image = UIImage(named:"icon_feed_text")
                    }
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        enabled = false
        
        nameLabel.text = "话题"
        
        iconImageViewLeadingConstraint.constant = Config.Profile.leftEdgeInset
        accessoryImageViewtrailingConstraint.constant = Config.Profile.rightEdgeInset
        
        imageView1.contentMode = .scaleAspectFill
        imageView2.contentMode = .scaleAspectFill
        imageView3.contentMode = .scaleAspectFill
        imageView4.contentMode = .scaleAspectFill
        
        let cornerRadius: CGFloat = 2
        imageView1.layer.cornerRadius = cornerRadius
        imageView2.layer.cornerRadius = cornerRadius
        imageView3.layer.cornerRadius = cornerRadius
        imageView4.layer.cornerRadius = cornerRadius
        
        imageView1.clipsToBounds = true
        imageView2.clipsToBounds = true
        imageView3.clipsToBounds = true
        imageView4.clipsToBounds = true
    }

    func configureWithProfileUser(_ profileUser: ProfileUser?, feedAttachments: [ImageAttachment?]?, completion: ((_ feeds: [DiscoverFeed], _ feedAttachments: [ImageAttachment?]) -> Void)?) {
        
        if let feedAttachments = feedAttachments {
            self.feedAttachments = feedAttachments
            
        } else {
            guard let profileUser = profileUser else {
                return
            }
            
            fetchDiscoverFeedFromUser(profileUser, category: nil, limitCount: 6, failureHandler: nil, completion: { feeds in
                
                let feedAttachments = feeds.map({ feed -> ImageAttachment? in
                    if let attachment = feed.attachment {
                        if case let .images(attachments) = attachment {
                            return attachments.first
                        }
                    }
                    return nil
                })
                
                self.feedAttachments = feedAttachments
                
                completion?(feeds, feedAttachments)

            })
        }
    }
}
