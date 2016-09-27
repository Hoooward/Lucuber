//
//  RegisterPickNameViewController.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegisterPickNameViewController: UIViewController {
    
    // MARK: - Properties

    var loginType: LoginType?
    var nickName: String?
    var phoneNumber: String?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(RegisterPickNameViewController.next(_:)))
        return button
    }()
    
    private var isDirty = false {
        willSet {
            nextButton.isEnabled = !newValue
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
       
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        view.backgroundColor = UIColor.cubeViewBackground()
        nameTextField.backgroundColor = UIColor.white
        nameTextField.textColor = UIColor.inputText()
        nameTextField.tintColor = UIColor.cubeTintColor()
        nameTextField.placeholder = " "
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(RegisterPickNameViewController.textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let type = loginType {
            
            switch type {
            case .login:
//                title = "登录"
                navigationItem.titleView = NavigationTitleLabel(title: "登录")
            case .register:
                navigationItem.titleView = NavigationTitleLabel(title: "注册")
//                title = "注册"
            }
        }
        
    }
    
    // MARK: - Target & Action
    
    func textFieldDidChange(_ textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        
        /// 名字不能只有空格
        isDirty = text.trimming(trimmingType: .whitespace).isEmpty
        
        nickName = text
    }
    
    func next(_ button: UIBarButtonItem) {
        showRegisterMobileViewController()
    }
    
    // MARK: - Segie
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "ShowRegisterPickMobile":
            
            let vc = segue.destination as! RegisterPickMobileViewController
            vc.nickName = nickName
            vc.loginType = loginType
            
        default:
            break
        }
    }
    
    func showRegisterMobileViewController() {
        
        guard let nickName = nameTextField.text else {
            return
        }
        
        // 暂存本地
        UserDefaults.setNewUser(userName: nickName)
        
        performSegue(withIdentifier: "ShowRegisterPickMobile", sender: nil)
    }
}

// MARK: - TextFieldDelegate
extension RegisterPickNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        if !text.isEmpty {
            showRegisterMobileViewController()
        }
        
        return true
    }
}
