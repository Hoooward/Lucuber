//
//  DeletedSuscribeFeedCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class DeletedSuscribeFeedCell: UITableViewCell {

    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteLabel.text = "[被删除]"
        deleteLabel.textColor = UIColor.lightGray
        
        selectionStyle = .none
    }
    
    func configureCell(with conversation: Conversation) {
        guard let feed = conversation.withGroup?.withFeed else {
            return
        }
        
        nameLabel.text = feed.body
        chatLabel.text = "此话题已被作者删除"
    }

    
}
