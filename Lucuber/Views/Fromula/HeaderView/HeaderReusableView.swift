//
//  HeaderReusableView.swift
//  Lucuber
//
//  Created by Howard on 16/7/2.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class HeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor.cubeTintColor()
        titleLabel.textColor = color
        countLabel.textColor = color
    }
    
    var type: Type? {
        didSet {
            
            if let type = type {
                
                
                var titleText = ""
                switch type.rawValue {
                    
                case "Cross":
                    titleText = type.rawValue + " - 中心块与底部十字"
                case "F2L":
                    titleText = type.rawValue + " - 中间层"
                case "OLL":
                    titleText = type.rawValue + " - 顶层定向"
                case "PLL":
                    titleText = type.rawValue + " - 顶层排列"
                default:
                    break
                }
                titleLabel.text = titleText
            }
        }
        
    }
    
    var count: Int? {
        didSet {
            
            if let count = count {
                countLabel.text = "共 \(count) 个"
            }
            
        }
    }
    
}

