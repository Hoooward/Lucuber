//
//  UpdateLibraryErrorView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/2.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class UpdateLibraryErrorView: UIView {
    
    
    var retryUpdateLibrary: (() -> Void)?
    
    enum Status {
        case normal
        case updateing
        case error
        case done
    }
    
    var status: Status = .updateing {
        
        didSet {
            
            switch status {
                
            case .normal:
                indicatorLabel.text = "公式库中暂无数据\n\n连接互联网后重新加载"
                retryButton.setTitle("重新加载", for: .normal)
                retryButton.isHidden = false
                
            case .done:
                indicatorLabel.text = "更新成功"
                retryButton.isHidden = true
                
            case .error:
                indicatorLabel.text = "更新失败"
                retryButton.isHidden = false
                retryButton.setTitle("重新加载", for: .normal)
                
            case .updateing:
                indicatorLabel.text = "更新中..."
                retryButton.isHidden = true
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var indicatorLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.lightGray.withAlphaComponent(0.6)
        label.numberOfLines = 0
        label.text = "更新中"
        label.sizeToFit()
        return label
        
    }()
    
    lazy var retryButton: BorderButton = {
        
        let button = BorderButton()
        button.setTitle("重新加载", for: .normal)
        button.backgroundColor = UIColor.cubeTintColor()
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.lightGray.withAlphaComponent(0.7), for: .highlighted)
        button.addTarget(self, action: #selector(UpdateLibraryErrorView.retry), for: .touchUpInside)
//        button.isEnabled = true
        return button
        
    }()
    
    
    func retry() {
        
        retryUpdateLibrary?()
    }
  
    private func makeUI() {
        
        addSubview(indicatorLabel)
        addSubview(retryButton)
        
        self.isUserInteractionEnabled = true
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        let labelCenterY = NSLayoutConstraint(item: indicatorLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -20)
        
        let labelCenterX = NSLayoutConstraint(item: indicatorLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([labelCenterX, labelCenterY])
        
        let buttonWidht = NSLayoutConstraint(item: retryButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150)
        
        let buttonHeight = NSLayoutConstraint(item: retryButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 37)
        
        let buttonTop = NSLayoutConstraint(item: retryButton, attribute: .top, relatedBy: .equal, toItem: indicatorLabel, attribute: .bottom, multiplier: 1, constant: 25)
        
        let buttonCenterX = NSLayoutConstraint(item: retryButton, attribute: .centerX, relatedBy: .equal, toItem: indicatorLabel, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([buttonWidht, buttonHeight, buttonTop, buttonCenterX])
        
    }
}















