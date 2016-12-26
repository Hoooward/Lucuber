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
    
    let realm = try! Realm()
    
    var currentScoreGroup: ScoreGroup? {
        didSet {
            scoreView.scoreGroup = currentScoreGroup
            scoreDetailView.scoreGroup = currentScoreGroup
        }
    }
    
    @IBOutlet weak var scoreDetailView: ScoreDetailView!
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var topContaninerViewConstarint: NSLayoutConstraint!
    @IBOutlet weak var timerControl: TimerControlView!
    @IBOutlet weak var topBackgroundView: UIView! {
        didSet {
            topBackgroundView.backgroundColor = UIColor.cubeTintColor()
        }
    }
    
    @IBOutlet weak var scramblingLabel: SpringLabel!
    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.timerType = .stopWatch
        }
    }
    
    private func perpareScoreGroup() {
        currentScoreGroup = getOrCreatDefaultScoreGroup()
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perpareScoreGroup()
        
        let heightConstant = CubeRuler.iPhoneVertical(350, 380, 470, 500).value
        topContaninerViewConstarint.constant = CGFloat(heightConstant)
        view.layoutIfNeeded()
        
        timerLabel.font = UIFont.timerLabelFont()
        
        scramblingLabel.text = Scrambling.shared.refreshScramblingText()
        
        timerControl.afterReadyStartAction = { [weak self] in
            self?.timerLabel.reset()
        }
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(TimerViewController.startTimer(sender:)))
        view.addGestureRecognizer(long)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TimerViewController.pasueTimer(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIWithAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
         
            realm.add(newScore)
            
            try? realm.commitWrite()
            
            scoreView.updateTableView(with: newScore, inRealm: realm)
            scoreDetailView.recalculateScoreData()
            scramblingLabel.text = Scrambling.shared.refreshScramblingText()
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
            
        case .ended:
            timerControl.status = .start
            timerLabel.start()
            
        default: break
        }
    }
    
    var isCreatingNewGroup: Bool = false
    @IBAction func refreshGroupAction(_ sender: Any) {
        
        if isCreatingNewGroup {
            return
        }
        isCreatingNewGroup = true
        
        realm.beginWrite()
        let newGroup = ScoreGroup()
        newGroup.localObjectId = ScoreGroup.randomLocalObjectID()
        let me = currentUser(in: realm)
        newGroup.creator = me
        realm.add(newGroup)
        try? realm.commitWrite()
        
        currentScoreGroup = newGroup
        updateUIWithAnimation()
        
        delay(1) {
            self.isCreatingNewGroup = false
        }
        
    }
}
