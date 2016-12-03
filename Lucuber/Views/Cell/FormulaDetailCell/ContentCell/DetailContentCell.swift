//
//  FormulaContentCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/3.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DetailContentCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var indicatorLabel: UILabel!
    
//    fileprivate var segmentedtitles: [String] = []
    
    @IBOutlet weak var segmentedControl: TwicketSegmentedControl!
    

    private let titles = ["FR", "FL", "BR", "BL"]
    override func awakeFromNib() {
        super.awakeFromNib()
        

        self.selectionStyle = .none
        segmentedControl.delegate = self
        segmentedControl.sliderBackgroundColor = UIColor.cubeTintColor()
        segmentedControl.setSegmentItems(titles)
        
        
    }
    
    fileprivate var formula: Formula?
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        self.formula = formula
        
        printLog(formula)
        let rotations: [String] = formula.contents.map {
            $0.rotation
        }
        
        segmentedControl.setSegmentItems(rotations)
        
        didSelect(0)
        
    }

}

extension DetailContentCell: UIScrollViewDelegate, TwicketSegmentedControlDelegate {
    
    func didSelect(_ segmentIndex: Int) {
        
        guard let formula = formula else {
            return
        }
        
        let content = formula.contents[segmentIndex]
        let rotation = Rotation(rawValue: content.rotation)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.contentLabel.attributedText = content.text.setAttributesFitDetailLayout(style: .center)
            self.indicatorLabel.text = rotation?.placeholderText
        })
        
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

















