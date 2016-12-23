//
//  TimerLabel.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

protocol TimerLabelDelegate: class {
    func finishedCountDownTimer(with time: TimeInterval, atTimerLabel: TimerLabel)
    func timerLabelCountingTo(time: TimeInterval, withTimerType: TimerLabel.Style, atTimerLabel: TimerLabel)
    func customTextToDisplay(at time: TimeInterval, atTimerLabel: TimerLabel) -> String
}

fileprivate let defaultTimerFormatter = "HH:mm:ss"
fileprivate let hourFormatReplace = "!!!*"
fileprivate let defaultFireIntervalNormal: TimeInterval = 0.1
fileprivate let defaultFireIntervalHighUse: TimeInterval = 0.01
fileprivate let defaultTimerLabelType: TimerLabel.Style = .stopWatch

class TimerLabel: UILabel {
    
    public enum Style {
        case stopWatch
        case timer
    }
    
    fileprivate enum Status {
        case fire
        case pause
        case reset
    }
    
    public var finishedCountDownTimerAction: ((TimeInterval, TimerLabel) -> Void)?
    public var countingToTimeAction: ((TimeInterval, TimerLabel.Style, TimerLabel) -> Void)?
    public var customTextToDisplayAction: ((TimeInterval, TimerLabel) -> String)?
    public var endedAction: ((TimeInterval) -> Void)?
    
    /// Use Delegate for finish or countdown timer
    public weak var delegate: TimerLabelDelegate?
    
    /// Time format wish to display in label
    public var timeFormat: String = "HH:mm:ss"
    /// Used for replace text in range
    public var textRange: NSRange = NSRange()
    public var attributedForTextInRange: [String: Any]?
    
    /// Style to choose from stopwatch or timer
    public var timerType: TimerLabel.Style = .timer
    
    /// Is time timer running?
    fileprivate(set) var counting: Bool = false
    
    /// Do you want to reset the Timer after countdown?
    public var resetTimerAfterFinish: Bool = false
    /// Do you wantthe timer to count beyond the HH limit form 0-23 e.g. 25:23:12 (HH:mm:ss)
    public var sholdCountBeyondHHLimit: Bool = false {
        didSet {
            updateLabel()
        }
    }
    
    public func setStopWatchTime(_ time: TimeInterval) {
        timerUserValue = (time < 0) ? 0 : time
        if timerUserValue > 0 {
            startCountDate = Date().addingTimeInterval(-timerUserValue)
            pausedTimeDate = Date()
            updateLabel()
        }
    }
    
    public func setCountDownTime(_ time: TimeInterval) {
        timerUserValue = (time < 0) ? 0 : time
        timeToCountOff = date1970.addingTimeInterval(timerUserValue)
        updateLabel()
    }
    
    public func setCountDownToDate(_ date: Date) {
        let timeLeft = date.timeIntervalSince(Date())
        if timeLeft > 0 {
            timerUserValue = timeLeft
            timeToCountOff = date1970.addingTimeInterval(timeLeft)
        } else {
            timerUserValue = 0
            timeToCountOff = date1970.addingTimeInterval(0)
        }
        updateLabel()
    }
    
    public func setTimeFormat(with format: String) {
        if !format.isEmpty {
            timeFormat = format
            self.dateFormatter.dateFormat = format
        }
        updateLabel()
    }
    
    fileprivate var timerUserValue: TimeInterval = 0
    fileprivate var startCountDate: Date?
    fileprivate var pausedTimeDate: Date?
    fileprivate var date1970: Date = Date()
    fileprivate var timeToCountOff: Date = Date()
   
    private var status: Status = .pause {
        
        didSet {
            switch status {
                
            case .fire:
                creatTimer()
                
                if startCountDate == nil {
                    if timerType == .stopWatch && timerUserValue > 0 {
                        startCountDate = Date().addingTimeInterval(-timerUserValue)
                    }
                }
                
                if let pausedTimeDate = pausedTimeDate, let startCountDate = startCountDate {
                    let countedTime = pausedTimeDate.timeIntervalSince(startCountDate)
                    self.startCountDate = Date().addingTimeInterval(-countedTime)
                }
                
                counting = true
                timer?.fire()
                
            case .pause:
                if counting {
                    timer?.invalidate()
                    timer = nil
                    counting = false
                    pausedTimeDate = Date()
                }
                
            case .reset:
                pausedTimeDate = nil
                timerUserValue = timerType == .stopWatch ? 0 : timerUserValue
                startCountDate = counting ? Date() : nil
                
            }
        }
    }
   
    fileprivate var timer: Timer?

    fileprivate lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = self.timeFormat
        return dateFormatter
    }()
    
    fileprivate var _timeLabel: UILabel?
    fileprivate var timeLabel: UILabel? {
        set {
            _timeLabel = newValue
        }
        
        get {
            if let timeLabel = _timeLabel {
                return timeLabel
            }
            return self
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.timeLabel = nil
        self.timerType = defaultTimerLabelType
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(timerLabelType: TimerLabel.Style) {
        self.init(frame: CGRect.zero)
        self.timeLabel = nil
        self.timerType = timerLabelType
    }
    
    convenience init(label: UILabel) {
        self.init(frame: CGRect.zero)
        self.timeLabel = label
        self.timerType = defaultTimerLabelType
    }
    
    convenience init(label: UILabel, timerLabelType: TimerLabel.Style) {
        self.init(frame: CGRect.zero)
        self.timeLabel = label
        self.timerType = timerLabelType
    }
    
    
    fileprivate func setup() {
        date1970 = Date(timeIntervalSince1970: 0)
        updateLabel()
    }
    
    @objc fileprivate func updateLabel() {
        
        var timeDiff: TimeInterval = 0
        
        if let startCountDate = startCountDate {
            timeDiff = Date().timeIntervalSince(startCountDate)
        }

        var timeToShow = Date()
        var timerEnded = false
        
        switch timerType {
            
        case .stopWatch:
            
            timeToShow = date1970.addingTimeInterval(timeDiff)
            
        case .timer:
            
            if counting {
                
                if let startCountDate = startCountDate {
                    timeDiff = Date().timeIntervalSince(startCountDate)
                }
                
                let timeLeft = timerUserValue - timeDiff
                
                delegate?.timerLabelCountingTo(time: timeLeft, withTimerType: timerType, atTimerLabel: self)
                countingToTimeAction? (timeLeft, timerType, self)
                
                if timeDiff >= timerUserValue {
                    // 暂停
                    timeToShow = date1970.addingTimeInterval(0)
                    startCountDate = nil
                    timerEnded = true
                    
                } else {
                    // added 0.999 to make it actually counting the whole first second
                    timeToShow = timeToCountOff.addingTimeInterval(timeDiff * -1)
                }
                
            } else {
                
                timeToShow = timeToCountOff
            }
        }
        
        let atTime = timerType == .stopWatch ? timeDiff : (timerUserValue - timeDiff) < 0 ? 0 : timeDiff - timerUserValue
        
        let text = delegate?.customTextToDisplay(at: atTime, atTimerLabel: self)
        
        if let text = text {
            timeLabel?.text = text
        } else {
            timeLabel?.text = dateFormatter.string(from: timeToShow)
        }
        
        if sholdCountBeyondHHLimit {
            let originalTimeFormat = timeFormat
            var beyoudFormatter = timeFormat.replacingOccurrences(of: "HH", with: hourFormatReplace)
            beyoudFormatter = beyoudFormatter.replacingOccurrences(of: "H", with: hourFormatReplace)
            
            self.dateFormatter.dateFormat = beyoudFormatter
            
            let hours = timerType == .stopWatch ? (timeCounted / 3600) : (timeRemaining / 3600)
            
            let formattedDate = dateFormatter.string(from: timeToShow)
            let beyondedDate = formattedDate.replacingOccurrences(of: hourFormatReplace, with: String(format: "%02d", hours))
            
            timeLabel?.text = beyondedDate
            dateFormatter.dateFormat = originalTimeFormat
            
        } else {
            
            if textRange.length > 0 {
                
                if let attributedForTextInRange = attributedForTextInRange {
                    
                    let attrTextInRange = NSAttributedString(string: dateFormatter.string(from: timeToShow), attributes: attributedForTextInRange)
                    
                    let arrtibutedString = NSMutableAttributedString(string: text ?? "")
                    arrtibutedString.replaceCharacters(in: textRange, with: attrTextInRange)
                    
                    self.timeLabel?.attributedText = arrtibutedString
                    
                } else {
                    
                    let text = text ?? ""
                    
                    let labelText = (text as NSString).replacingCharacters(in: textRange, with: dateFormatter.string(from: timeToShow))
                    
                    timeLabel?.text = labelText
                }
                
            } else {
                
                timeLabel?.text = dateFormatter.string(from: timeToShow)
            }
        }
        
        if timerEnded {
            delegate?.finishedCountDownTimer(with: timerUserValue, atTimerLabel: self)
            
            endedAction?(timerUserValue)
            
            if resetTimerAfterFinish {
                reset()
            }
        }
        
        
    }
    
    public func start() {
        status = .fire
    }
    
    public func pause() {
        status = .pause
    }
    
    public func reset() {
        status = .reset
    }
    
}

extension TimerLabel {
    
    fileprivate func creatTimer() {
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        
        if let _ = self.timeFormat.range(of: "SS") {
            timer = Timer(timeInterval: defaultFireIntervalHighUse, target: self, selector: #selector(TimerLabel.updateLabel), userInfo: nil, repeats: true)
        } else {
            timer = Timer(timeInterval: defaultFireIntervalNormal, target: self, selector: #selector(TimerLabel.updateLabel), userInfo: nil, repeats: true)
        }
        
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    
    fileprivate var timeCounted: TimeInterval {
        
        guard let startCountDate = startCountDate else {
            return 0
        }
        var countedTime = Date().timeIntervalSince(startCountDate)
        
        guard let pausedTimeDate = pausedTimeDate else {
            return countedTime
        }
        
        let pausedCountedTime = Date().timeIntervalSince(pausedTimeDate)
        countedTime -= pausedCountedTime
        return countedTime
    }
    
    fileprivate var timeRemaining: TimeInterval {
        if timerType == .timer {
            return timerUserValue - timeCounted
        }
        return 0
    }
    
    fileprivate var countDownTime: TimeInterval {
        
        if timerType == .timer {
            return timerUserValue
        }
        return 0
    }
}

















