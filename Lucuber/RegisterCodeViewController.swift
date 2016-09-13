//
//  RegisterCodeViewController.swift
//  Lucuber
//
//  Created by Howard on 9/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegisterCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    var phoneNumber: String?
    var nickName: String?
    var code: String?
    
    var loginType: LoginType?

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var getCodeButton: UIButton!
    

    
    private var isDirty: Bool = false {
        willSet {
            navigationItem.rightBarButtonItem?.enabled = newValue
        }
    }
    
    private lazy var getCodeTimer: NSTimer = {
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(RegisterCodeViewController.tryGetCode(_:)), userInfo: nil, repeats: true)
        return timer
    }()
    
    
    private var getCodeInSeconds = CubeConfig.getCodeInSeconds
    
    @objc private func tryGetCode(xxx: NSTimer) {
        
        if getCodeInSeconds > 1 {
            let buttonTitle = "获取验证码" + "(\(getCodeInSeconds))"
            
            UIView.performWithoutAnimation({ 
                self.getCodeButton.setTitle(buttonTitle, forState: .Normal)
                self.getCodeButton.layoutIfNeeded()
            })
        } else {
            
            UIView.performWithoutAnimation({ 
                self.getCodeButton.setTitle("获取验证码", forState: .Normal)
                self.getCodeButton.layoutIfNeeded()
            })
            
            getCodeButton.enabled = true
        }
        
        
        if getCodeInSeconds > 1 {
            getCodeInSeconds -= 1
        }
        
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
        
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "验证", style: .Plain, target: self, action: #selector(RegisterCodeViewController.login(_:)))
        navigationItem.rightBarButtonItem?.enabled = false
       
        
        view.backgroundColor = UIColor.cubeViewBackgroundColor()

        codeTextField.backgroundColor = UIColor.whiteColor()
        codeTextField.textColor = UIColor.cubeInputTextColor()
        codeTextField.tintColor = UIColor.cubeTintColor()
        
        getCodeButton.setTitle("重新获取", forState: .Normal)
        
        codeTextField.addTarget(self, action: #selector(RegisterCodeViewController.codeTextFieldDidChanged(_:)), forControlEvents: .EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        phoneNumberLabel.text = phoneNumber
        
        getCodeButton.enabled = false
        
        if let type = loginType {
            
            switch type {
                
            case .Login:
                title = "登录"
                
            case .Resgin:
                title = "注册"
               
            }
        }
        
  
        
        printLog(phoneNumber)
        printLog(nickName)
        
    }
    
 
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        codeTextField.becomeFirstResponder()
        
        getCodeTimer.fire()
        
        getSmsCodeWithPhoneNumber()
        
    }
    
    // MARK: - Action & Target
    
    @IBAction func getCode(sender: AnyObject) {
        
        getSmsCodeWithPhoneNumber()
        
        getCodeInSeconds = CubeConfig.getCodeInSeconds
        getCodeButton.enabled = false
        
    }
    
    
    func codeTextFieldDidChanged(textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        
        isDirty = text.characters.count >= 6
    }
    
    private func getSmsCodeWithPhoneNumber() {
        
        AVOSCloud.requestSmsCodeWithPhoneNumber(phoneNumber) { succeeded, error in
            
            printLog(succeeded)
            printLog(error)
            
            if succeeded {
                
                // 获取验证码成功
                printLog("成功获取验证码")
                
            } else {
                
                
                if error != nil {
                    printLog(error)
                    
                    switch error.code {
                        
                    case 601: /// 频繁获取
                        
                        printLog("频繁获取,稍等..")
                        self.getCodeInSeconds = CubeConfig.getCodeInSeconds
                        
                    case 602: /// 运营商错误
                        
                        printLog("运营商错误")
                        CubeAlert.alert(title: "抱歉", message: "获取验证码失败，请检查网络连接或稍后再试。", dismissTitle: "关闭", inViewController: self, withDismissAction: {
                            
                            self.getCodeInSeconds = 1
                        })
                        
                    default:
                        
                        CubeAlert.alert(title: "抱歉", message: "获取验证码失败，请检查网络连接或稍后再试。", dismissTitle: "关闭", inViewController: self, withDismissAction: {
                            
                            self.getCodeInSeconds = 1
                        })
                        
                    }
                    
                }
                /// code = 601 是短时间内频繁获取的错误代码
                
            }
        }
    }
    
func login(item: UIBarButtonItem) {
        
        guard let code = codeTextField.text else {
            print("验证码错误")
            return
        }
        
        AVUser.signUpOrLoginWithMobilePhoneNumberInBackground(phoneNumber, smsCode: code) {
            user, error in
            
            if error == nil {
                
                printLog("登录成功")
                
                self.performSegueWithIdentifier("ShowPickAvatar", sender: user)
                
            } else {
                
                printLog(error)
                // code = 603 无效的验证码
                if error.code == 603 {
                    
                    CubeAlert.alert(title: "抱歉", message: "无效的验证码，请核对后重新输入。", dismissTitle: "关闭", inViewController: self, withDismissAction: nil)
                    
                } else {
                    
                    CubeAlert.alert(title: "抱歉", message: "验证失败，请检查网络连接或稍后再试。", dismissTitle: "关闭", inViewController: self, withDismissAction: nil)
                }
            
            }
            
            
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
            case "ShowPickAvatar":
                
//                let vc = segue.destinationViewController as! RegisterPickAvatarViewController
                
                break
                
                
            default:
                break
            }
        }
    }
    
    
}
