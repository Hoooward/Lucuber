//
//  TimerViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import LucuberTimer

class TimerViewController: UIViewController {
    
    @IBOutlet weak var timerControl: TimerControlView!
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer! {
        didSet {
            longPressGesture.minimumPressDuration = 0.5
            longPressGesture.addTarget(self, action: #selector(TimerViewController.startTimer(sender:)))
        }
    }
    @IBOutlet var tapGesture: UITapGestureRecognizer! {
        didSet {
            tapGesture.addTarget(self, action: #selector(TimerViewController.pasueTimer(sender:)))
        }
    }
    
    lazy var scrambling = Scrambling()
    @IBOutlet weak var scramblingLabel: UILabel!
    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.timerType = .stopWatch
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scramblingLabel.text = scrambling.creatScramblingText()
    }
    
    
    func pasueTimer(sender: UIGestureRecognizer) {
        if timerLabel.isCounting {
            timerLabel.pause()
            timerControl.status = .prepare
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
