//
//  TimerViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import LucuberTimer
import RealmSwift
import Spring


class TimerViewController: UIViewController {
    
    private let realm = try! Realm()
    
    var currentScoreGroup: ScoreGroup? {
        didSet {
            scoreView.scoreGroup = currentScoreGroup
            scoreDetailView.scoreGroup = currentScoreGroup
            
            if let group = currentScoreGroup, let category = Category(rawValue: group.category) {
                titleLabel.text = category.indicatorString
            } else {
                titleLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var topContaninerViewConstarint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerConstarint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerView: SpringView!
    
    private var isFirstAppear: Bool = true
    
    @IBOutlet weak var timerControl: TimerControlView!
    
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var scoreDetailView: ScoreDetailView!
    
    private lazy var newScoreGroupAnimator: NewScoreGroupAnimator = NewScoreGroupAnimator()
    
    @IBOutlet weak var scramblingLabel: SpringLabel!
    
    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.timerType = .stopWatch
        }
    }


    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        topBackgroundView.backgroundColor = UIColor.cubeTintColor()
        
        topContaninerViewConstarint.constant = CGFloat(CubeRuler.iPhoneVertical(350, 380, 470, 480).value)
        view.layoutIfNeeded()
        
        timerControl.afterReadyStartAction = { [weak self] in
            self?.timerLabel.reset()
        }
        
        scoreView.afterChangeScoreToDNF = { [weak self] in
            self?.scoreDetailView.updateUI()
        }
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(TimerViewController.startTimer(sender:)))
        view.addGestureRecognizer(long)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TimerViewController.pasueTimer(sender:)))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimerViewController.updateRefreshButton), name: .newScoreGroupViewControllerDidDismissNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimerViewController.updateUI), name: Config.NotificationName.updateMyScores, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIWithAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        perpareScoreGroup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Target & Action
    @objc fileprivate func updateUI() {
        scoreView.tableView.reloadData()
        scoreDetailView.updateUI()
    }
    
    func pasueTimer(sender: UIGestureRecognizer) {
        
        if timerLabel.isCounting {
            
            timerLabel.pause()
            timerControl.status = .prepare
            
            let timeToShow = timerLabel.timeToShow.timeIntervalSince1970
            
            realm.beginWrite()
            let newScore = Score()
            newScore.localObjectId = Score.randomLocalObjectID()
            newScore.timer = timeToShow
            newScore.timertext = timerLabel.text ?? "00:00:00"
            newScore.atGroup = currentScoreGroup
            newScore.scramblingText = scramblingLabel.text ?? ""
            newScore.creator = currentUser(in: realm)
            newScore.category = currentScoreGroup?.category ?? ""
         
            realm.add(newScore)
            
            try? realm.commitWrite()
            
            scoreView.updateTableView(with: newScore, inRealm: realm)
            scoreDetailView.updateUI()
            scramblingLabel.text = Scrambling.shared.refreshScramblingText()
            refreshButton.isEnabled = true
        }
        
    }
    
    func startTimer(sender: UIGestureRecognizer) {
        
        if timerLabel.isCounting {
            return
        }
        timerLabel.reset()
        
        switch sender.state {
            
        case .began:
            timerControl.status = .readyStart
            refreshButton.isEnabled = false
            
        case .ended:
            timerControl.status = .start
            timerLabel.start()
            
        default: break
        }
    }
    
    func refreshGroup() {
        refreshGroupAction(UIButton())
    }
    
    @IBAction func refreshGroupAction(_ sender: UIButton) {
        
        sender.isEnabled = false
        let stroyboard = UIStoryboard(name: "Timer", bundle: nil)
        
        guard let newScoreGroupVC = stroyboard.instantiateViewController(withIdentifier: "NewScoreGroupViewController") as? NewScoreGroupViewController else {
            return 
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let presentedWidth = screenWidth - 100
        let presentedHeight = screenHeight - 300
        
        self.newScoreGroupAnimator.presentedFrame = CGRect(x: (screenWidth - presentedWidth) * 0.5, y: (screenHeight - presentedHeight) * 0.5, width: presentedWidth, height: presentedHeight)
        newScoreGroupVC.transitioningDelegate = self.newScoreGroupAnimator
        newScoreGroupVC.modalPresentationStyle = .custom
        
        
        newScoreGroupVC.afterSelectedNewCategory = { [weak self] categoryString in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.realm.beginWrite()
            let newGroup = ScoreGroup()
            newGroup.localObjectId = ScoreGroup.randomLocalObjectID()
            newGroup.category = categoryString
            
            let me = currentUser(in: strongSelf.realm)
            newGroup.creator = me
            strongSelf.realm.add(newGroup)
            try? strongSelf.realm.commitWrite()
            
            strongSelf.currentScoreGroup = newGroup
            strongSelf.updateUIWithAnimation()
            
            delay(1) {
               sender.isEnabled = true
            }
        }
        
        present(newScoreGroupVC, animated: true, completion: nil)
    }
    
    private func perpareScoreGroup() {
        // 直接拿最后一个创建的 Group
        currentScoreGroup = scoreGroupWith(user: currentUser(in: realm), inRealm: realm).first
    }
    
    @objc private func updateRefreshButton() {
        refreshButton.isEnabled = true
    }
    
    private func updateUIWithAnimation() {
        
        scramblingLabel.animation = "slideDown"
        scramblingLabel.curve = "easeInOut"
        scramblingLabel.duration = 0.8
        scramblingLabel.animate()
        
        scoreView.animation = "slideRight"
        scoreView.curve = "easeInOut"
        scoreView.delay = 0.4
        scoreView.duration = 0.8
        scoreView.animate()
        
        scoreDetailView.animation = "slideLeft"
        scoreDetailView.curve = "easeInOut"
        scoreDetailView.delay = 0.4
        scoreDetailView.duration = 0.8
        scoreDetailView.animate()
        
        timerControl.animation = "zoomIn"
        timerControl.curve = "easeInOut"
        timerControl.delay = 0.6
        timerControl.duration = 1.0
        timerControl.animate()
        
        timerLabel.text = "00:00:00"
        refreshButton.isEnabled = true
        
        bottomContainerView.animation = "fadeInUp"
        bottomContainerView.curve = "easeInOut"
        bottomContainerView.duration = 0.8
        bottomContainerView.animate()
        
    }
}
