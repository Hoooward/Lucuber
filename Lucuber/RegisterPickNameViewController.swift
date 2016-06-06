//
//  RegisterPickNameViewController.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegisterPickNameViewController: UIViewController {

 
    var mobile: String?
    var areaCode: String?
    
    @IBOutlet var nameTextField: UITextField!
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(RegisterPickNameViewController.next(_:)))
        return button
    }()
    

    
    private var isDirty = false {
        willSet {
            nextButton.enabled = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.enabled = false
      
        
        
        view.backgroundColor = UIColor.cubeViewBackgroundColor()
        nameTextField.backgroundColor = UIColor.whiteColor()
        nameTextField.textColor = UIColor.cubeInputTextColor()
        nameTextField.placeholder = " "
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(RegisterPickNameViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        print(#function)
        isDirty = !text.isEmpty
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
            vc.mobile = mobile
            vc.areaCode = areaCode
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
