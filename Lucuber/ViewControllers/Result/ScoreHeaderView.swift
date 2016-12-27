//
//  ScoreHeaderView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/25.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import LucuberTimer
import RealmSwift
import ScrollableGraphView

class ScoreHeaderView: UIView {

    var totalHeight: CGFloat = 200
    
    @IBOutlet weak var graphView: ScrollableGraphView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var subTimerLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topView.backgroundColor = UIColor.cubeTintColor()
        
        graphView.shouldAdaptRange = true
        
        graphView.showsHorizontalScrollIndicator = false
        graphView.lineStyle = .smooth
        graphView.backgroundFillColor = UIColor.cubeTintColor()
        graphView.lineColor = UIColor.white
        graphView.lineWidth = 1
        graphView.dataPointSpacing = 80
        graphView.dataPointSize = 2
        graphView.dataPointFillColor = UIColor.white
        graphView.shouldFill = true
        
        graphView.fillGradientType = .linear
        graphView.fillColor = UIColor.white.withAlphaComponent(0.4)
        
        graphView.fillGradientStartColor = UIColor.white.withAlphaComponent(0.5)
        graphView.fillGradientEndColor = UIColor.white.withAlphaComponent(0.3)
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.dataPointLabelColor = UIColor.white
        
        graphView.rangeMax = 20
        
        prepareUseCraphView()
    }
    
    private func prepareUseCraphView() {
        let date = Array(repeating: 0.0, count: 10)
        let label = Array(repeating: "00:00:00", count: 10)
        graphView.set(data: date, withLabels: label)
    }
    
    public func configureGraphView(with scoreGroup: ScoreGroup) {
        
        let date: [Double] = scoreGroup.timerList.map { $0.timer }
        let labels: [String] = scoreGroup.timerList.map { $0.timertext }
        
        if date.isEmpty && labels.isEmpty {
            prepareUseCraphView()
        } else {
            graphView.set(data: date, withLabels: labels)
        }
        
        if let category = Category(rawValue: scoreGroup.category) {
            categoryLabel.text = category.indicatorString
        } else {
            categoryLabel.text = "3x3x3"
        }
        
        dateLabel.text = scoreGroup.dateSectionString
        
        subTimerLabel.text = scoreGroup.totalSubString
    }
    
    func makeUI() {
        
        addSubview(graphView)
        
        let views: [String: Any] = [
            "graphView": graphView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[graphView]|", options: [], metrics: nil, views: views)
        let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[graphView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate(constraintV)
    }
    
}
