//
//  FormulaContentCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/3.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FormulaContentCell: UITableViewCell {
    
    // MARK: - Properties
    var segmentedtitles: [String] = []
    
    private lazy var segmentedControl: TwicketSegmentedControl = {
        let titles = ["FR", "FL", "BR", "BL"]
        let frame = CGRect(x: 28, y: 10, width: UIScreen.main.bounds.width - 28 - 28, height: 40)
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.sliderBackgroundColor = UIColor.cubeTintColor()
        return segmentedControl
    }()

    lazy var indicatorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.inputAccessoryPlaceholderColor()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.inputAccessoryPlaceholderColor()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    var formula: Formula? {
        didSet {
            if let formula = formula {
                
                let rotationsTitle = formula.contents.map { $0.rotation }.map { rotation -> String in
                    
                    switch rotation {
                    case .FR(_, _):
                        return "FR"
                    case .FL(_, _):
                        return "FL"
                    case .BL(_, _):
                        return "BL"
                    case .BR(_, _):
                        return "BR"
                    }
                    
                }
                segmentedControl.setSegmentItems(rotationsTitle)
            }
            didSelect(0)
        }
    }
    
    // MARK: - Left Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(segmentedControl)
        addSubview(contentLabel)
//        addSubview(indicatorLabel)
        
        self.selectionStyle = .none
       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let formula = formula else {
            return
            
        }
        
        var contentLabelMaxHeight: CGFloat = 0
        
        for (_, content) in formula.contents.enumerated() {
            
            if let text = content.text {
                
                let attributesText = text.setAttributesFitDetailLayout(style: .center)
                let rect = attributesText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 38 - 38 , height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                
                
                if rect.height > contentLabelMaxHeight {
                    contentLabelMaxHeight = rect.height
                }
                
            }
        }
        
        
//        
//        let indicatorLabelFrame = CGRect(x: 38 , y: 0, width: UIScreen.main.bounds.width - 38 - 38, height: 25)
//        indicatorLabel.frame = indicatorLabelFrame
        
        
        let rect = CGRect(x: 45, y: 25, width: UIScreen.main.bounds.width - 45 - 45, height: contentLabelMaxHeight)
        contentLabel.frame = rect
        
       
        
        let segmentControlFrame = CGRect(x: 28, y: contentLabel.frame.maxY + 40, width: UIScreen.main.bounds.width - 28 - 28, height: 35)
        
        segmentedControl.frame = segmentControlFrame
        
       
        
        
    }
    
}


extension FormulaContentCell: UIScrollViewDelegate, TwicketSegmentedControlDelegate {
    
    func didSelect(_ segmentIndex: Int) {
        
        guard let formula = formula else {
            return
        }
        
        let content = formula.contents[segmentIndex]
        
        contentLabel.attributedText = content.text?.setAttributesFitDetailLayout(style: .center)
        
        
        switch content.rotation {
        case .FR(_, let text):
            indicatorLabel.text = text
        case .FL(_, let text):
            indicatorLabel.text = text
        case .BL(_, let text):
            indicatorLabel.text = text
        case .BR(_, let text):
            indicatorLabel.text = text
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        printLog("开始滚动")
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        printLog("滑动动画结束")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        printLog("减速结束")
    }
}

















