//
//  FeedHeaderView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedHeaderView: UIView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameLabelCenterYConstraint: NSLayoutConstraint!

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mediaView: FeedMediaView!
    
    @IBOutlet weak var messageTextView: FeedTextView! {
        didSet {
            messageTextView.isScrollEnabled = false
        }
    }
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var attachmentContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!

    var feed: DiscoverFeed? {
        willSet {
            if let feed = newValue {
                configureWithFeed(feed: feed)
            }
        }
    }
    
    public var imageAttachments = [ImageAttachment]() {
        didSet {
            mediaCollectionView.reloadData()
            mediaView.setImagesWithAttachments(imageAttachments)
        }
    }
    

    var tapUrlInfoAction: ((URL) -> Void)?
    var tapFormulaInfoAction: ((DiscoverFormula) -> Void)?
    var tapImagesAction: ((_ transitionViews: [UIView?], _ attachments: [ImageAttachment], _ image: UIImage?, _ index: Int) -> Void)?
    
    static let messageTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.main.bounds.width - (15 + 40 + 10 + 15)
        return maxWidth
    }()


    lazy var feedFormulaContainerView: FeedFormulaContainerView = {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 150)
        let view = FeedFormulaContainerView(frame: rect)
        view.compressionMode = false

        self.attachmentContainerView.addSubview(view)

        let views: [String: AnyObject] = [
            "view": view
        ]

        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)

        NSLayoutConstraint.activate(constraintsH)
        NSLayoutConstraint.activate(constraintsV)

        let tapFormulaAction = UITapGestureRecognizer(target: self, action: #selector(FeedHeaderView.tapFormulaAction(sender: )))

        view.addGestureRecognizer(tapFormulaAction)

        return view
    }()

    
    lazy var feedURLContainerView: FeedURLContainerView = {
        let view = FeedURLContainerView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        view.compressionMode = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.attachmentContainerView.addSubview(view)
        
        let views: [String: AnyObject] = [
            "view": view
        ]
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraintsH)
        NSLayoutConstraint.activate(constraintsV)
        
        let tapURLInfo = UITapGestureRecognizer(target: self, action: #selector(FeedHeaderView.tapUrlAction(sender:)))
        view.addGestureRecognizer(tapURLInfo)
        
        return view
    }()

    

    
     let feedMediaCellID = "FeedMediaCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nicknameLabel.textColor = UIColor.cubeTintColor()
        messageLabel.textColor = UIColor.darkGray
        messageTextView.textColor = UIColor.darkGray
        timeLabel.textColor = UIColor.gray
        
        messageLabel.font = UIFont.feedMessageTextView()
        messageLabel.alpha = 0
        
        messageTextView.scrollsToTop = false
        messageTextView.font = UIFont.feedMessageTextView()
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        mediaView.alpha = 0
        
        mediaCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15 + 40 + 10, bottom: 0, right: 15)
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.backgroundColor = UIColor.clear
        mediaCollectionView.registerNib(of: FeedMediaCell.self)
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        
        let tapToggleScroll = UITapGestureRecognizer(target: self, action: #selector(FeedHeaderView.toggleScroll(sender:)))
        addGestureRecognizer(tapToggleScroll)
        tapToggleScroll.delegate = self
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(FeedHeaderView.tapAvatar(sender:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapAvatar)

        let tapAttachment = UITapGestureRecognizer(target: self, action: #selector(FeedHeaderView.tapAttachment(sender:)))
        attachmentContainerView.addGestureRecognizer(tapAttachment)

    }

	// MARK: - Target & Action
    @objc private func tapFormulaAction(sender: UITapGestureRecognizer) {

        guard let formula = feed?.formulaInfo else {
            return
        }
		tapFormulaInfoAction?(formula)
    }

    @objc private func tapUrlAction(sender: UIGestureRecognizer) {

        guard let url = feed?.openGraphInfo?.URL else {
            return
        }
        tapUrlInfoAction?(url)
    }

    @objc private func toggleScroll(sender: UIGestureRecognizer) {

    }

    @objc private func tapAvatar(sender: UIGestureRecognizer) {
    }

    @objc private func tapAttachment(sender: UIGestureRecognizer) {

    }


    
    func calculateHeightOfMessageTextView() {
        let rect = (messageTextView.text as NSString).boundingRect(with: CGSize(width:FeedHeaderView.messageTextViewMaxWidth , height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.FeedHeaderView.textAttributes, context: nil)
        messageTextViewHeightConstraint.constant = ceil(rect.height)
    }
    
    func configureWithFeed(feed: DiscoverFeed) {
        
        let message = feed.body
        messageLabel.text = message
        messageTextView.text = message
        
        calculateHeightOfMessageTextView()
        
        // 设置约束
        timeLabelTopConstraint.constant = CGFloat(feed.hasAttachments ? (15 + 80 + 15) : 15)

        imageAttachments = feed.imageAttachments

        messageLabelTrailingConstraint.constant = CGFloat(feed.hasAttachments ? 15 : 60)


        // 设置头像
        if let creator = feed.creator {
            let userAvatar = CubeAvatar(avatarUrlString: creator.avatorImageURL() ?? "", avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: 0.5)
            
            nicknameLabel.text = creator.nickname() ?? ""
        }
        
        // TODO: - 时间显示
        timeLabel.text = "\(feed.createdAt?.timeIntervalSince1970)"
        
        switch feed.category {
            
        case .text:
            
            mediaCollectionView.isHidden = true
            attachmentContainerView.isHidden = true
            
            
        case .url:
            
            mediaCollectionView.isHidden = true
            attachmentContainerView.isHidden = false
            
            attachmentContainerHeightConstraint.constant = 80
            
            if let openGraphInfo = feed.openGraphInfo {
                feedURLContainerView.configureWithOpenGraphInfoType(openGraphInfo: openGraphInfo)
            }
            
        case .image:
            
            mediaCollectionView.isHidden = false
            attachmentContainerView.isHidden = true
            
            attachmentContainerHeightConstraint.constant = 80
            
        case .formula:
            
            mediaCollectionView.isHidden = true
            attachmentContainerView.isHidden = false
            attachmentContainerHeightConstraint.constant = 80
            
            if let formula = feed.formulaInfo {
                feedFormulaContainerView.configureWithDiscoverFormula(formula: formula)
            }
            
        default:
            break
        }
        
        
        
        
        
        
    }
}

extension FeedHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: FeedMediaCell = collectionView.dequeueReusableCell(for: indexPath)

        cell.configureWithAttachment(imageAttachments[indexPath.item], bigger: imageAttachments.count == 1)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 80, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! FeedMediaCell
        
        let transitionViews: [UIView?] = (0..<imageAttachments.count).map {
            
            let indexPath = IndexPath(row: $0, section: indexPath.section)
            let cell = collectionView.cellForItem(at: indexPath) as? FeedMediaCell
            
            return cell?.imageView
        }
        
        tapImagesAction?(transitionViews, imageAttachments, cell.imageView.image, indexPath.item)
        
    }


}

extension FeedHeaderView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        let location = touch.location(in: mediaCollectionView)

        if mediaCollectionView.bounds.contains(location) {
            return false
        }
        return true
    }
}

























