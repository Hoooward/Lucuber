//
//  FeedFormulaCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/9.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedFormulaCell: FeedBaseCell {
    
    override class func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed: feed) + (100 + 15)
        
        return ceil(height)
    }
    
    public var tapFormulaInfoAction: ((DiscoverFormula) -> Void)?
    
    lazy var feedFormulaContainerView: FeedFormulaContainerView = {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 150)
        let view = FeedFormulaContainerView(frame: rect)
        view.compressionMode = false
        return view
    }()
    
    
    override func configureWithFeed(_ feed: DiscoverFeed, layout: FeedCellLayout, needshowCategory: Bool) {
        
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        if let attachment = feed.attachment {
            
            switch attachment {
                
            case .formula(let formula):
                
                feedFormulaContainerView.configureWithDiscoverFormula(formula: formula)
                
            default:
                break
            }
        }
        
        let _formulaLayout = layout._formulaLayout!
        feedFormulaContainerView.frame = _formulaLayout.formulaContainerViewFrame
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(feedFormulaContainerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
