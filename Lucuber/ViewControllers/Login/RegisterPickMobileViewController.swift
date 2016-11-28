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
        let button = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(RegisterPickMobileViewController.next(_:)))
        return button
    }()
    
    private var isDirty = false {
        willSet {
            nextButton.isEnabled = newValue
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        view.backgroundColor = UIColor.cubeViewBackground()
        
        mobileTextFiled.backgroundColor = UIColor.white
        mobileTextFiled.textColor = UIColor.inputText()
        mobileTextFiled.tintColor = UIColor.cubeTintColor()
        mobileTextFiled.delegate = self
        
        mobileTextFiled.addTarget(self, action: #selector(RegisterPickMobileViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        leftTextFiled.backgroundColor = UIColor.white
        leftTextFiled.addTarget(self, action: #selector(RegisterPickMobileViewController.leftTextFiledChanged(_:)), for: .editingChanged)
        
        mobileTextFiled.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "ShowVerificationCode":
            
            let vc = segue.destination as! RegisterCodeViewController
            vc.phoneNumber = mobileTextFiled.text!
            vc.nickName = nickName
            vc.loginType = loginType
            
            break
            
        default:
            break
        }
        
    }

    // MARK: - Target & Action
    
    func textFieldDidChange(_ textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        
        do {
            /// 判断是否是正确的手机号码. 正则表达式
            //"^[1][3578][0-9]{9}$"
            let regex = try NSRegularExpression(pattern: "^1(3[0-9]|4[57]|5[0-35-9]|7[01678]|8[0-9])\\d{8}$", options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, text.characters.count))
            
            isDirty = matches.count > 0
            
        } catch { printLog("输入的不是手机号码") }
        
    }
    
    // MARK: - Aciton & Target
    
    func leftTextFiledChanged(_ textFiled: UITextField) {
        view.layoutIfNeeded()
        leftTextFiled.layoutIfNeeded()
    }
    
    
    func next(_ button: UIBarButtonItem) {
        
        showRegisterVerificationCodeViewController()
    }
    
    fileprivate func showRegisterVerificationCodeViewController() {
        
        if let phoneNumber = mobileTextFiled.text {
            
            CubeHUD.showActivityIndicator()
            
            if let type = self.loginType {
                
                fetchValidateMobile(mobile: phoneNumber, checkType: type, failureHandler: { reason, errorMessage in
                    
                    CubeHUD.hideActivityIndicator()
                    
                    defaultFailureHandler(reason, errorMessage)
                    
                    switch type {
                        
                    case .register:
                        
                        switch reason {
                            
                        case .noSuccess:
                            CubeAlert.alertSorry(message: "您输入的手机号已经注册, 可返回直接登录", inViewController: self)
                            
                        case .network(_):
                            CubeAlert.alertSorry(message: "请求失败，请检查网络连接或稍后再试", inViewController: self)
                            
                        default: break
                            
                        }

                    case .login:
                        
                        switch reason {
                            
                        case .noSuccess:
                            CubeAlert.alertSorry(message: "您输入的手机号码尚未注册，请返回注册", inViewController: self)
                            
                        case .network(_):
                            
                            CubeAlert.alertSorry(message: "请检查网络连接或稍后再试", inViewController: self)
                            
                        default: break
                        }
                    }
                    
                    }, completion: {
                        
                        CubeHUD.hideActivityIndicator()
                        self.performSegue(withIdentifier: "ShowVerificationCode", sender: phoneNumber)
                        
                })
                
            }
            
        }
        
    }
    
}

// MARK: - TextFiledDelegate

extension RegisterPickMobileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        if !text.isEmpty {
            showRegisterVerificationCodeViewController()
        }
        
        return true
    }
}
