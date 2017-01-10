//
//  ProfileHeaderCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import Navi

class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarBlurImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    public var updatePrettyColorAction: ((UIColor) -> Void)?
    
    var askedForPermission = false
    
    deinit {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var blurredAvatarImage: UIImage? {
        willSet {
            avatarBlurImageView.image = newValue
        }
    }
    
    public func configureCell(with discoverUser: AVUser) {
        
    }
    
    private func blurImage(_ image: UIImage, completion: @escaping (UIImage) -> Void) {
        
        if let blurredAvatarImage = blurredAvatarImage {
            completion(blurredAvatarImage)
            
        } else {
            DispatchQueue.global(qos: .default).async {
                let blurredImage = image.blurredImage(withRadius: 20, iterations: 20, tintColor: UIColor.black)
                completion(blurredImage!)
            }
        }
    }
    
    private func updateAvatar(with avatarURLString: String) {
        
        if avatarImageView.image == nil {
            avatarImageView.alpha = 0
            avatarBlurImageView.alpha = 0
        }
        
        let avatarStyle = AvatarStyle.original
        let plainAvatar = CubeAvatar(avatarUrlString: avatarURLString, avatarStyle: avatarStyle)
        
        AvatarPod.wakeAvatar(plainAvatar, completion: { [weak self] finished, image, _ in
            
            if finished {
                self?.blurImage(image, completion: { blurredImage in
                    DispatchQueue.main.async {
                        self?.blurredAvatarImage = blurredImage
                    }
                })
            }
            
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
                
                let avatarAvarageColot = 
               
            }
            
        })
        
    }

}



















