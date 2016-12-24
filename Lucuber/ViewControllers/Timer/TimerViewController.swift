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


class TimerViewController: UIViewController {
    
    let realm = try! Realm()
    
    var currentScoreGroup: ScoreGroup? {
        didSet {
            scoreView.scoreGroup = currentScoreGroup
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
    
    lazy var scrambling = Scrambling()
    
    @IBOutlet weak var scramblingLabel: UILabel!
    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.timerType = .stopWatch
        }
    }
    
    private func perpareScoreGroup() {
        currentScoreGroup = getOrCreatDefaultScoreGroup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perpareScoreGroup()
        
        let heightConstant = CubeRuler.iPhoneVertical(350, 380, 470, 500)
        topContaninerViewConstarint.constant = CGFloat(heightConstant.value)
        view.layoutIfNeeded()
        timerLabel.font = UIFont.timerLabelFont()
        
        scramblingLabel.text = scrambling.creatScramblingText()
        
        timerControl.afterReadyStartAction = { [weak self] in
            self?.timerLabel.reset()
        }
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(TimerViewController.startTimer(sender:)))
        view.addGestureRecognizer(long)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TimerViewController.pasueTimer(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func pasueTimer(sender: UIGestureRecognizer) {
        
        if timerLabel.isCounting {
            timerLabel.pause()
            timerControl.status = .prepare
            
            realm.beginWrite()
            let newScore = Score()
            newScore.localObjectId = "123jyuuiayiusdyfiuhj11"
            newScore.timertext = timerLabel.text ?? "00:00:00"
            newScore.atGroup = currentScoreGroup
            realm.add(newScore)
            
            try? realm.commitWrite()
            
            scoreView.updateTableView(with: newScore, inRealm: realm)
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
}
