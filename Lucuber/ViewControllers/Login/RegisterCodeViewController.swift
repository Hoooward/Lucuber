//
//  RegisterCodeViewController.swift
//  Lucuber
//
//  Created by Howard on 9/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

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
            navigationItem.rightBarButtonItem?.isEnabled = newValue
        }
    }
    
    private lazy var getCodeTimer: Timer = {
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RegisterCodeViewController.tryGetCode), userInfo: nil, repeats: true)
        
        return timer
        
    }()
    
    
    private var getCodeInSeconds = Config.mobilePhoneCodeInSeconds
    
    func tryGetCode() {
        
        if getCodeInSeconds > 1 {
            let buttonTitle = "获取验证码" + "(\(getCodeInSeconds))"
            
            UIView.performWithoutAnimation({ 
                self.getCodeButton.setTitle(buttonTitle, for: .normal)
                self.getCodeButton.layoutIfNeeded()
            })
        } else {
            
            UIView.performWithoutAnimation({ 
                self.getCodeButton.setTitle("获取验证码", for: .normal)
                self.getCodeButton.layoutIfNeeded()
            })
            
            getCodeButton.isEnabled = true
        }
        
        
        if getCodeInSeconds > 1 {
            getCodeInSeconds -= 1
        }
        
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: loginType == .login ? "登录" : "验证", style: .plain, target: self, action: #selector(RegisterCodeViewController.login(_:)))
        
        navigationItem.rightBarButtonItem?.isEnabled = false
       
        
        view.backgroundColor = UIColor.cubeViewBackground()

        codeTextField.backgroundColor = UIColor.white
        codeTextField.textColor = UIColor.inputText()
        codeTextField.tintColor = UIColor.cubeTintColor()
        
        getCodeButton.setTitle("重新获取", for: .normal)
        
        codeTextField.addTarget(self, action: #selector(RegisterCodeViewController.codeTextFieldDidChanged(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        phoneNumberLabel.text = phoneNumber
        
        getCodeButton.isEnabled = false
        
        if let type = loginType {
            
            switch type {
                
            case .login:
                title = "登录"
//                navigationItem.titleView = NavigationTitleLabel(title: "登录")
            case .register:
//                navigationItem.titleView = NavigationTitleLabel(title: "注册")
                title = "注册"
            }
        }
        
        printLog(phoneNumber)
        printLog(nickName)
        
    }
    
 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        codeTextField.becomeFirstResponder()
        
        getCodeTimer.fire()
        
        getSmsCodeWithPhoneNumber()
        
    }
    
    // MARK: - Action & Target
    
    @IBAction func getCode(sender: AnyObject) {
        
        getSmsCodeWithPhoneNumber()
        
        getCodeInSeconds = Config.mobilePhoneCodeInSeconds
        getCodeButton.isEnabled = false
        
    }
    
    
    func codeTextFieldDidChanged(_ textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        
        isDirty = text.characters.count >= 6
    }
    
    private func getSmsCodeWithPhoneNumber() {
        
        fetchMobileVerificationCode(phoneNumber: phoneNumber!, failureHandler: { reason, errorMessage in
            
            defaultFailureHandler(reason, errorMessage)
            switch reason {
                
            case .other(let error):
                
                if let error = error {
                    
                    switch error.code {
                        
                    case 601: /// 频繁获取
                        
                        CubeAlert.alert(title: "抱歉", message: "获取太过频繁，请稍后再试。", dismissTitle: "关闭", inViewController: self, dismissAction: {
                            self.getCodeInSeconds = Config.mobilePhoneCodeInSeconds
                        })
                        
                    case 602: /// 运营商错误

                        CubeAlert.alert(title: "抱歉", message: "获取验证码失败，请检查网络连接或稍后再试。", dismissTitle: "关闭", inViewController: self, dismissAction: {
                            
                            self.getCodeInSeconds = 1
                        })
                        
                    default:
                        
                        CubeAlert.alert(title: "抱歉", message: "获取验证码失败，请检查网络连接或稍后再试。", dismissTitle: "关闭", inViewController: self, dismissAction: {
                            
                            self.getCodeInSeconds = 1
                        })
                    }
                }
                
            default: break
            }
            
        }, completion: nil )
        
    }

    func login(_ item: UIBarButtonItem) {
        
        guard let code = codeTextField.text else {
            return
        }
        
        CubeHUD.showActivityIndicator()
        
        signUpOrLogin(with: phoneNumber!, smsCode: code, failureHandler: { reason, errorMessage in
            
            CubeHUD.hideActivityIndicator()
            
            defaultFailureHandler(reason, errorMessage)
            switch reason {
                
            case .other(let error):
                
                if error?.code == 603 {
                    printLog(errorMessage)
                    CubeAlert.alertSorry(message: "无效的验证码， 请核对后重新输入。", inViewController: self)
                    
                } else {
                    CubeAlert.alertSorry(message: "验证失败， 请检查网络连接或稍后再试。", inViewController: self)
                }
                
            default: break
                
            }
            
        }, completion: { user in
            
            CubeHUD.hideActivityIndicator()
            
            
            switch self.loginType! {
                
            case .login:
                
                // 进入 Main Storyboard
                NotificationCenter.default.post(name: Notification.Name.changeRootViewControllerNotification, object: nil)
                break
                
            case .register:
                
                // 进入头像选择
                self.performSegue(withIdentifier: "ShowPickAvatar", sender: user)
            }
            
        })
       
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
            case "ShowPickAvatar":
                
                let vc = segue.destination as! RegisterPickAvatarViewController
                vc.nickName = self.nickName
                
                
                break
                
                
            default:
                break
            }
        }
    }
    
    
    
}
