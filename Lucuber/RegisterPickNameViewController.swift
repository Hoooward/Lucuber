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
        let button = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(RegisterPickNameViewController.next(_:)))
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

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.enabled = false
      
       
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        view.backgroundColor = UIColor.cubeViewBackgroundColor()
        nameTextField.backgroundColor = UIColor.whiteColor()
        nameTextField.textColor = UIColor.cubeInputTextColor()
        nameTextField.tintColor = UIColor.cubeTintColor()
        nameTextField.placeholder = " "
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(RegisterPickNameViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        nameTextField.becomeFirstResponder()
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
    
    // MARK: - Target & Action
    
    func textFieldDidChange(textField: UITextField) {
        
        guard let text = textField.text else {
            return
        }
        isDirty = !text.isEmpty
        nickName = text
    }
    
    func next(button: UIBarButtonItem) {
        showRegisterMobileViewController()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "ShowRegisterPickMobile":
    
            let vc = segue.destinationViewController as! RegisterPickMobileViewController
            vc.nickName = nickName
            vc.loginType = loginType
            
        default:
            break
        }
    }

    func showRegisterMobileViewController() {
        
        guard let text = nameTextField.text else {
            return
        }
        
        let user = User()
        user.username = text.trimming(.WhitespaceAndNewLine)
        
        performSegueWithIdentifier("ShowRegisterPickMobile", sender: nil)
    }
}

extension RegisterPickNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        if !text.isEmpty {
            showRegisterMobileViewController()
        }
        return true
    }
}
