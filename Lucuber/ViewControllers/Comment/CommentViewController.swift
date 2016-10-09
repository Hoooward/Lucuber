//
//  CommentViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud

class FormulaComment: AVObject, AVSubclassing {
    
    ///对哪个公式的评论
    static let FormulaCommentKey_atFormula = "atFormulaName"
    @NSManaged var atFormulaName: String?
    
    /// 评论内容
    static let FormulaCommentKey_author = "author"
    @NSManaged var content: String?
    
    /// 被喜欢
    static let FormulaCommentKey_likeCount = "likeCount"
    @NSManaged var likeCount: Int
    
    /// 评论作者
    static let FormulaCommentkey_author = "author"
    @NSManaged var author: AVUser?
    
    ///新公式文本
    static let FormulaCommetnKey_fromulaText = "formulaText"
    @NSManaged var formulaText: String?
    
    class func parseClassName() -> String {
        return "FormulaComment"
    }
    
    /*
     init(author: AVUser?, content: String, formulaString: String?, likeCount: Int = 0) {
     self.author = author
     self.content = content
     self.formulaString = formulaString
     self.likeCount = likeCount
     
     super.init()
     }
     */
}

extension FormulaComment {
    class func CuberFormulaCommentQueryIncludeKeys() -> [String] {
        return [FormulaCommentKey_author, FormulaCommentKey_atFormula]
    }
}

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
    
    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var messageToolbarBottomConstraints: NSLayoutConstraint!
    
    private let keyboardMan = KeyboardMan()
    private var giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false
    
    fileprivate let loadMoreCollectionCellIdenfitifier = "LoadMoreCollectionViewCell"
    fileprivate let chatSectionDateCellIdentifier = "ChatSectionDateCell"
    fileprivate let chatLeftTextCellIdentifier = "ChatLeftTextCell"
    fileprivate let chatRightTextCellIdentifier = "ChatRightTextCell"
    fileprivate let chatLeftImageCellIdentifier = "ChatLeftImageCell"
    fileprivate let chatRightImageCellIdentifier = "ChatRightImageCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.titleView = titleView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_more"), style: .plain, target: self, action: #selector(CommentViewController.moreAction))
        
        makeHeaderView(with: formula)
      
        
        commentCollectionView.keyboardDismissMode = .onDrag
        commentCollectionView.alwaysBounceVertical = true
        
        
        commentCollectionView.register(UINib(nibName: loadMoreCollectionCellIdenfitifier, bundle: nil), forCellWithReuseIdentifier: loadMoreCollectionCellIdenfitifier)
        
        commentCollectionView.register(UINib(nibName: chatSectionDateCellIdentifier, bundle: nil), forCellWithReuseIdentifier: chatSectionDateCellIdentifier)
        
        commentCollectionView.register(ChatLeftTextCell.self, forCellWithReuseIdentifier: chatLeftTextCellIdentifier)
        
        commentCollectionView.register(ChatLeftImageCell.self, forCellWithReuseIdentifier: chatLeftImageCellIdentifier)
        
        commentCollectionView.register(ChatRightTextCell.self, forCellWithReuseIdentifier: chatRightTextCellIdentifier)
        
        commentCollectionView.register(ChatRightImageCell.self, forCellWithReuseIdentifier: chatRightImageCellIdentifier)
        
        commentCollectionView.bounces = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.tapToDismissMessageToolbar))
        commentCollectionView.addGestureRecognizer(tap)
        
        
        messageToolbarBottomConstraints.constant = 0
        
        keyboardMan.animateWhenKeyboardAppear = {
            [weak self] apperaPostIndex, keyboardHeight, keyboardHeightIncrement in
            
            guard self?.navigationController?.topViewController == self else {
                return
            }
            
            if let giveUp = self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear {
                
                if giveUp {
                    self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false
                    return
                }
            }
            
            if let strongSelf = self {
                
                if strongSelf.messageToolbarBottomConstraints.constant > 0 {
                    
                    // 第一次出现
                    if apperaPostIndex == 0 {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    } else {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    }
                    
                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height
                    
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    
                    strongSelf.messageToolbarBottomConstraints.constant = keyboardHeight
                    
                    strongSelf.view.layoutIfNeeded()
                    
                } else {
                    
                    strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    
                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height
                    
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    
                    strongSelf.messageToolbarBottomConstraints.constant = keyboardHeight
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = {
            [weak self] keyboardHeight in
            
            guard self?.navigationController?.topViewController == self else {
                return
            }
            
            if let nvc = self?.navigationController {
                if nvc.topViewController != self {
                    self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear = true
                    return
                }
            }
            
            if let strongSelf = self {
                
                if strongSelf.messageToolbarBottomConstraints.constant > 0 {
                    strongSelf.commentCollectionView.contentOffset.y -= keyboardHeight
                    
                    
                    let bottom = strongSelf.messageToolbar.frame.height
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    
                    strongSelf.messageToolbarBottomConstraints.constant = 0
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
        
        
//        commentCollectionView.contentInset.top = 64 + 60 + 20
        commentCollectionView.contentInset = UIEdgeInsets(top: 64 + 60 + 20, left: 0, bottom: 44, right: 0)
        print(commentCollectionView.contentInset)
        
        loadNewComment()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func tapToDismissMessageToolbar() {
        
    }
    
    func makeHeaderView(with formula: Formula?) {
        guard let formula = formula else {
            return
        }
        
        let headerView = CommentHeaderView.creatCommentHeaderViewFormNib()
        headerView.formula = formula
        
        headerView.changeStatusAction = {
            [weak self] status in
            
            switch status {
            case .small:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 60 + 20
                    }, completion: nil)
                
                printLog(self?.commentCollectionView.contentInset)
                
            case .big:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 120 + 20
                    }, completion: nil)
                
                if let messageToolbar = self?.messageToolbar {
                    
                    if !messageToolbar.state.isAtBottom {
                        messageToolbar.state = .normal
                    }
                }
                
                printLog(self?.commentCollectionView.contentInset)
                
                
            }
        }
        
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
    
    var formulaComments: [FormulaComment] = []
    
    func loadNewComment() {
        let query = AVQuery(className: FormulaComment.parseClassName())
        query?.addDescendingOrder("updatedAt")
        query?.whereKey(FormulaComment.FormulaCommentKey_atFormula, equalTo: formula?.name)
        
        query?.findObjectsInBackground({ (result, error) in
            if error == nil {
                self.formulaComments = result as! [FormulaComment]
                self.commentCollectionView.reloadData()
            }
        })
    }
    
}

extension CommentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case loadPrevious
        case message
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
            
        case .loadPrevious:
            return 1
            
        case .message:
            
            return formulaComments.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadMoreCollectionCellIdenfitifier, for: indexPath) as! LoadMoreCollectionViewCell
            return cell
            
        case .message:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatSectionDateCellIdentifier, for: indexPath)
//            return cell
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatLeftTextCellIdentifier, for: indexPath) as! ChatLeftTextCell
            
            let comment = formulaComments[indexPath.item]
            
            let message = Message()
            message.textContent = comment.content!
            message.creatUser = AVUser.current()
            
//            print(message)
            cell.configureWithMessage(message: message, textContentLabelWidth: 200, collectionView: collectionView, indexPath: indexPath as! NSIndexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            return UIEdgeInsets.zero
        case .message:
            return UIEdgeInsets(top: 5, left: 0, bottom: 15, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            return CGSize(width: UIScreen.main.bounds.width, height: 20)
        case .message:
            return CGSize(width: UIScreen.main.bounds.width, height: 50)
        }
    }
    
}

extension CommentHeaderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        printLog(scrollView.contentOffset.y)
    }
}
















