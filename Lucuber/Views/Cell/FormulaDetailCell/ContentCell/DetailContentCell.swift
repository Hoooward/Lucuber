//
//  FormulaContentCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/3.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DetailContentCell: UITableViewCell {
    
    // MARK: - Properties
    fileprivate var segmentedtitles: [String] = []
    
    fileprivate lazy var segmentedControl: TwicketSegmentedControl = {
        let titles = ["FR", "FL", "BR", "BL"]
        let frame = CGRect(x: 28, y: 10, width: UIScreen.main.bounds.width - 28 - 28, height: 40)
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.sliderBackgroundColor = UIColor.cubeTintColor()
        return segmentedControl
    }()

    fileprivate lazy var indicatorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.inputAccessoryPlaceholderColor()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.inputAccessoryPlaceholderColor()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    fileprivate var formula: Formula?
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        self.formula = formula
        
        let rotations: [String] = formula.contents.map {
            $0.rotation
        }
        
        segmentedControl.setSegmentItems(rotations)
        
        didSelect(0)
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(segmentedControl)
        addSubview(contentLabel)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let formula = formula else { return }
        
        let screenWidth = UIScreen.main.bounds.width
//        let rect = CGRect(x: 45, y: 25, width: screenWidth - 45 - 45, height: formula.contentMaxCellHeight)
        let rect = CGRect(x: 45, y: 25, width: screenWidth - 45 - 45, height: 100)
        contentLabel.frame = rect
        
        let segmentControlFrame = CGRect(x: 28, y: contentLabel.frame.maxY + 40, width: screenWidth - 28 - 28, height: 35)
        
        segmentedControl.frame = segmentControlFrame
    }
    
}


extension DetailContentCell: UIScrollViewDelegate, TwicketSegmentedControlDelegate {
    
    func didSelect(_ segmentIndex: Int) {
        
        guard let formula = formula else {
            return
        }
        
        let content = formula.contents[segmentIndex]
        let rotation = Rotation(rawValue: content.rotation)
        contentLabel.attributedText = content.text.setAttributesFitDetailLayout(style: .center)
        
        indicatorLabel.text = rotation?.placeholderText
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

















