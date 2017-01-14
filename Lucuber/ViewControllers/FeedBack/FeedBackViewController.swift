//
//  FeedBackViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

final class FeedBackViewController: UIViewController {
    @IBOutlet fileprivate weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "我会细心阅读每一份反馈"
            titleLabel.textColor = UIColor.darkGray
        }
    }
    
    @IBOutlet fileprivate weak var feedbackTextView: UITextView! {
        didSet {
            feedbackTextView.text = ""
            feedbackTextView.delegate = self
            feedbackTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        }
    }
    
    @IBOutlet fileprivate weak var feedbackTextViewTopLineView: HorizontalLineView! {
        didSet {
            feedbackTextViewTopLineView.lineColor = UIColor.lightGray
        }
    }
    
    @IBOutlet fileprivate weak var feedbackTextViewBottomLineView: HorizontalLineView! {
        didSet {
            feedbackTextViewBottomLineView.lineColor = UIColor.lightGray
        }
    }
    
    @IBOutlet fileprivate weak var feedbackTextViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            feedbackTextViewBottomConstraint.constant = Config.Feedback.bottomMargin
        }
    }
    
    fileprivate var isDirty = false {
        willSet {
            navigationItem.rightBarButtonItem?.isEnabled = newValue
        }
    }
    
    fileprivate let keyboardMan = KeyboardMan()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "反馈"
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(FeedBackViewController.done(_:)))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] _, keyboardHeight, _ in
            self?.feedbackTextViewBottomConstraint.constant = keyboardHeight + Config.Feedback.bottomMargin
            self?.view.layoutIfNeeded()
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            self?.feedbackTextViewBottomConstraint.constant = Config.Feedback.bottomMargin
            self?.view.layoutIfNeeded()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedBackViewController.tap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        feedbackTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        feedbackTextView.resignFirstResponder()
    }
    
    @objc fileprivate func tap(_ sender: UITapGestureRecognizer) {
        feedbackTextView.resignFirstResponder()
    }
    
    @objc fileprivate func done(_ sender: AnyObject) {
        
        feedbackTextView.resignFirstResponder()
        
        let deviceInfo = (DeviceUtil.hardwareDescription() ?? "nixDevice") + ", " + ProcessInfo().operatingSystemVersionString
        let feedback = Feedback(content: feedbackTextView.text, deviceInfo: deviceInfo)
        
        sendFeedback(feedback, failureHandler: { [weak self] (reason, errorMessage) in
            let message = errorMessage ?? "Faild to send feedback!"
            YepAlert.alertSorry(message: message, inViewController: self)
            
            }, completion: { [weak self] in
                YepAlert.alert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Thanks! Your feedback has been recorded!", comment: ""), dismissTitle: String.trans_titleOK, inViewController: self, withDismissAction: {
                    
                    SafeDispatch.async { [weak self] in
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
                })
        })
    }
}
