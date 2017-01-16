//
//  FeedImageCellNode.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class FeedImageCellNode: ASCellNode {
    
    lazy var imageNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFill
        node.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        node.borderWidth = 1
        node.borderColor = UIColor.cubeBorderColor().cgColor
        return node
    }()
    
    override init() {
        super.init()
        
        addSubnode(imageNode)
    }
    
    func configureWithAttachment(_ attachment: ImageAttachment, imageSize: CGSize) {
        
        if attachment.isTemporary {
            imageNode.image = attachment.image
            
        } else {
            imageNode.showActivityIndicatorWhenLoading = true
            imageNode.cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: imageSize)
        }
    }
}
