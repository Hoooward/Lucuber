//
//  ConversationIndicatorTitleView.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class ConversationIndicatorTitleView: UIView {


    enum State {
        case Normal
        case Active
    }
    
    var state: State = .Normal {
        willSet {
            switch newValue {
            case .Normal:
                activityIndicator?.stopAnimating()
                
                singletitleLabel?.hidden = false
                rightTitleLabel?.hidden = true
                
            case .Active:
                activityIndicator?.startAnimating()
                
                singletitleLabel?.hidden = true
                rightTitleLabel?.hidden = false
            }
        }
    }
    
    private var singletitleLabel: UILabel?
    private var activityIndicator: UIActivityIndicatorView?
    private var rightTitleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        
        do {
            let label = UILabel()
            label.text = "Yep"
            label.textColor = UIColor.cubeNavgationBarTitleColor()
            label.font = UIFont.navigationBarTitleFont()
            label.textAlignment = .Center
            
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            self.singletitleLabel = label
            
            let viewsDictionary: [String: AnyObject] = [
                "label": label
            ]
            
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary)
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary)
            
            NSLayoutConstraint.activateConstraints(constraintsH)
            NSLayoutConstraint.activateConstraints(constraintsV)
        }
        
        do {
            let helperView = UIView()
            helperView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(helperView)
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicator.tintColor = UIColor.cubeNavgationBarTitleColor()
            activityIndicator.hidesWhenStopped = true
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            self.activityIndicator = activityIndicator
            
            helperView.addSubview(activityIndicator)
            
            let label = UILabel()
            label.text = NSLocalizedString("Fetching", comment: "")
            label.textColor = UIColor.cubeNavgationBarTitleColor()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            self.rightTitleLabel = label
            
            helperView.addSubview(label)
            
            let helperViewCenterX = NSLayoutConstraint(item: helperView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            let helperViewCenterY = NSLayoutConstraint(item: helperView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([helperViewCenterX, helperViewCenterY])
            
            let viewDictionary: [String: AnyObject] = [
                "activityIndicator": activityIndicator,
                "label": label
            ]
            
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H|[activityIndicator]-[label]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewDictionary)
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V|[activityIndicator]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewDictionary)
            
            NSLayoutConstraint.activateConstraints(constraintsV)
            NSLayoutConstraint.activateConstraints(constraintsH)
        }
        
        state = .Normal
        
    }

}





















