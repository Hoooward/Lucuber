//
//  RegisterPickMobileViewController.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegisterPickMobileViewController: UIViewController {

    // MARK: - Properties
    
    var mobile: String?
    var nickName: String?
    
    var loginType: LoginType?
    
    @IBOutlet weak var mobileTextFiled: UITextField!
    @IBOutlet weak var leftTextFiled: BorderTextField!
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(RegisterPickMobileViewController.next(_:)))
        return button
    }()
    
    private var isDirty = false {
        willSet {
            nextButton.enabled = newValue
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.enabled = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        view.backgroundColor = UIColor.cubeViewBackgroundColor()
        
        mobileTextFiled.backgroundColor = UIColor.whiteColor()
        mobileTextFiled.textColor = UIColor.cubeInputTextColor()
        mobileTextFiled.tintColor = UIColor.cubeTintColor()
        mobileTextFiled.delegate = self
        mobileTextFiled.addTarget(self, action: #selector(RegisterPickMobileViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        leftTextFiled.backgroundColor = UIColor.whiteColor()
        leftTextFiled.addTarget(self, action: #selector(RegisterPickMobileViewController.leftTextFiledChanged(_:)), forControlEvents: .EditingChanged)
        
        mobileTextFiled.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let type = loginType {
            
            switch type {
                
            case .Login:
                title = "登录"
                
            case .Resgin:
                title = "注册"
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "ShowVerificationCode":
            
            let vc = segue.destinationViewController as! RegisterCodeViewController
            vc.phoneNumber = mobileTextFiled.text!
            vc.nickName = nickName
            vc.loginType = loginType
            
            break
            
        default:
            break
        }
    }

    // MARK: - Target & Action
    
    func textFieldDidChange(textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        
        do {
            
            /// 判断是否是正确的手机号码. 正则表达式
            let regex = try NSRegularExpression(pattern: "^[1][358][0-9]{9}$", options: NSRegularExpressionOptions.CaseInsensitive)
            let matches = regex.matchesInString(text, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, text.characters.count))
            
            
            isDirty = matches.count > 0
            
        } catch {
            
        }
        
        
        
    }
    
    
    func leftTextFiledChanged(textFiled: UITextField) {
        view.layoutIfNeeded()
        leftTextFiled.layoutIfNeeded()
    }
    

    
    func next(button: UIBarButtonItem) {
        
        showRegisterVerificationCodeViewController()
    }
    
    private func showRegisterVerificationCodeViewController() {
        
        
        
        if let phoneNumber = mobileTextFiled.text {
            
            CubeHUD.showActivityIndicator()
            
            validateMobile(phoneNumber, failureHandler: { error in
                
                CubeHUD.hideActivityIndicator()
                
                CubeAlert.alert(title: "抱歉", message: "此手机号已经注册, 可返回直接登录.", dismissTitle: "关闭", inViewController: self, withDismissAction: nil)
                
                
                }, completion: {
                    
                    CubeHUD.hideActivityIndicator()
                    self.performSegueWithIdentifier("ShowVerificationCode", sender: phoneNumber)
                    
            })
            
        }
        
        
//        AVUser.signUpOrLoginWithMobilePhoneNumberInBackground(<#T##phoneNumber: String!##String!#>, smsCode: <#T##String!#>, block: <#T##AVUserResultBlock!##AVUserResultBlock!##(AVUser!, NSError!) -> Void#>)
        
//        
//        AVUser.logInWithMobilePhoneNumberInBackground(mobileTextFiled.text!, smsCode: "") { (user, error) in
//            
//        }
    }


}

extension RegisterPickMobileViewController: UITextFieldDelegate {
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        if !text.isEmpty {
            showRegisterVerificationCodeViewController()
        }
        
        return true
    }
}
