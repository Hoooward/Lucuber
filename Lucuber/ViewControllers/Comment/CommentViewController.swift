//
//  CommentViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    var formula: Formula?
    
    
    private lazy var sectionDateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    private lazy var sectionDateInCurrentWeekFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter
    }()
    
    private lazy var titleView: ConversationTitleView = {
        let titleView = ConversationTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))
        
//        if nameOfConversation(self.conversation) != "" {
//            titleView.nameLabel.text = nameOfConversation(self.conversation)
//        } else {
//            titleView.nameLabel.text = NSLocalizedString("Discussion", comment: "")
//        }
//        
//        self.updateStateInfoOfTitleView(titleView)
//        
//        titleView.userInteractionEnabled = true
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.showFriendProfile(_:)))
//        
//        titleView.addGestureRecognizer(tap)
        
        titleView.nameLabel.text = "讨论"
        titleView.stateInfoLabel.textColor = UIColor.gray
        titleView.stateInfoLabel.text = "上次见是一周以前"
        
        return titleView
    }()
    
    
    var headerView: CommentHeaderView?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_more"), style: .plain, target: self, action: #selector(CommentViewController.moreAction))
        
        makeHeaderView(with: formula)
        
    }
    
    func makeHeaderView(with formula: Formula?) {
//        guard let formula = formula else {
//            return
//        }
        
        let headerView = CommentHeaderView.creatCommentHeaderViewFormNib()
        headerView.formula = formula
        
        headerView.status = .small
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let views: [String: AnyObject] = [
            "headerView": headerView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", options: [], metrics: nil, views: views)
        
        let top = NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 64)
        
        let height = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate([top, height])
        
        headerView.heightConstraint = height
        
        self.headerView = headerView
        
    }
    
    func moreAction() {
        printLog("")
        
    }
    
}
















