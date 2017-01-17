//
//  SearchFeedFormulaCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/17.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
final class SearchFeedFormulaCell: SearchFeedBasicCell {
    
    override class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        let height = super.heightOfFeed(feed) + (10 + 20)
        return ceil(height)
    }
    
    var tapFormulaInfoAction: ((_ formula: DiscoverFormula) -> Void)?
    
    lazy var feedFormulaContainerView: IconTitleContainerView = {
        let view = IconTitleContainerView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        return view
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(feedFormulaContainerView)
        
        feedFormulaContainerView.iconImageView.image = UIImage(named: "icon_formulaInfo")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureCell(with feed: DiscoverFeed, layout: SearchFeedCellLayout, keyword: String?) {
        super.configureCell(with: feed, layout: layout, keyword: keyword)
        
        if let attachment = feed.attachment {
            
            switch attachment {
                
            case .formula(let formula):
                
                feedFormulaContainerView.titleLabel.text = formula.name
                
                feedFormulaContainerView.tapAction = { [weak self] in
                    self?.tapFormulaInfoAction?(formula)
                }
                
            default:
                break
            }
        }
        
        let _formulaLayout = layout._formulaLayout!
        
        feedFormulaContainerView.frame = _formulaLayout.formulaContainerViewFrame
    }
    
}





