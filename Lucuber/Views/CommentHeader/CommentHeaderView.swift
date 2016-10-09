//
//  CommentHeaderView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/9.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CommentHeaderView: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var categoryIndicatorView: CategoryIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var creatTimeLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatUserLabel: UILabel!
    
    var heightConstraint: NSLayoutConstraint?
    @IBOutlet weak var nameLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorViewCenterYConstraint: NSLayoutConstraint!
    
    enum Status {
        case small
        case big
    }
    
    var changeStatusAction: ((Status) -> Void)?
    
    var status: Status = .small {
        willSet {
            
            switch newValue {
            case .small:
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.init(rawValue: 0), animations: { [weak self] in
                    
                    self?.indicatorViewCenterYConstraint.constant = 0
                    self?.heightConstraint?.constant = 60
                    self?.nameLabelCenterYConstraint.constant = 0
                    self?.imageViewHeightConstraint.constant = 40
                    
                    self?.creatUserLabel.alpha = 0
                    self?.creatTimeLabel.alpha = 0
                    self?.starRatingView.alpha = 0
                    
                    self?.layoutIfNeeded()
                    
                    }, completion: {  _ in
//                        self?.layoutIfNeeded()
                        
                    })
                
            case .big:
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.init(rawValue: 0), animations: { [weak self] in
                    
                    self?.indicatorViewCenterYConstraint.constant = -30
                    self?.heightConstraint?.constant = 120
                    self?.nameLabelCenterYConstraint.constant = -6
                    self?.imageViewHeightConstraint.constant = 100
                    
                    self?.creatUserLabel.alpha = 1
                    self?.creatTimeLabel.alpha = 1
                    self?.starRatingView.alpha = 1
                    
                    self?.layoutIfNeeded()
               
                    }, completion: { _ in
//                        self?.layoutIfNeeded()
                        
                })
            }
        }
    }
    
    var formula: Formula? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Life Cycle
    
    private func makeUI() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentHeaderView.changeStatus))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        
        clipsToBounds = true
        
    }
    
    class func creatCommentHeaderViewFormNib() -> CommentHeaderView {
        let view = Bundle.main.loadNibNamed("CommentHeaderView", owner: nil, options: nil)!.last! as! CommentHeaderView
        return view
    }
    
    // MARK: - Target & Action
    
    func changeStatus() {
        status = status == .small ? .big : .small
        
        changeStatusAction?(status)
    }
    
    private func updateUI() {
        guard let formula = formula else {
           return
        }
        
        imageView.image = UIImage(named: formula.imageName)
        nameLabel.text = formula.name
        categoryIndicatorView.configureWithCategory(category: formula.category.rawValue)
        creatTimeLabel.text = "更新时间: \(formula.updatedAt)"
        creatUserLabel.text = "创建者: \(formula.creatUser.getUserNickName())"
    }
    
    
    
}
