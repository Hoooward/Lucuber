//
//  CubeAlert.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


public class CubeAlert {
    
    
    class func alert(title: String, message: String?, dismissTitle: String, inViewController viewController: UIViewController?, dismissAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: dismissTitle, style: .default) { action in
                
                if let dismissAction = dismissAction {
                    dismissAction()
                }
            }
            
            alertController.addAction(action)
            viewController?.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?, dismissAction: @escaping () -> Void) {
        alert(title: "抱歉" , message: message, dismissTitle: "关闭", inViewController: viewController, dismissAction: dismissAction)
    }
    
    class func alertSorry(message: String?, inViewController viewController: UIViewController?) {
        alert(title: "抱歉", message: message, dismissTitle: "关闭", inViewController: viewController, dismissAction: nil)
    }
    
    
    class func textInput(title: String, placeholder: String?, oldText: String?, dismissTitle: String, inViewController viewController: UIViewController?, finishedAction: ((String) -> Void)? ) {
        
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: { textField in
                
                textField.placeholder = placeholder
                textField.text = oldText
                
            })
            
            let action = UIAlertAction(title: dismissTitle, style: .default) { action in
                
                if let finishedAction = finishedAction {
                    
                    if
                    let textField = alertController.textFields?.first,
                        let text = textField.text {
                        finishedAction(text)
                    }
                }
            }
            
            alertController.addAction(action)
            viewController?.present(alertController, animated: true, completion: nil)
            
            
        }
    }
    
    
    static weak var confirmAlertAction: UIAlertAction?
    
 
    
    class func textInput(title: String, message: String?, placeholder: String?, oldText: String?, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, confirmAction: ((String) -> Void)?,  cancelAction: (() -> Void)? ) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: { textField in
                
                textField.placeholder = placeholder
                textField.text = oldText
                textField.addTarget(self, action: #selector(handleTextFieldTextDidChangedNotification(sender:)), for: .editingChanged)
            })
            
            let _cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                
                cancelAction?()
            
            }
            
            alertController.addAction(_cancelAction)
            
            let _confirmAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                
                if
                    let textField = alertController.textFields?.first,
                    let text = textField.text {
                    
                    confirmAction?(text)
                    
                }
                
            }
            
            _confirmAction.isEnabled = false
            self.confirmAlertAction = _confirmAction
            
            alertController.addAction(_confirmAction)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @objc class func handleTextFieldTextDidChangedNotification(sender: UITextField) {
        
        if let text = sender.text, text.utf16.count >= 1 {
            
            CubeAlert.confirmAlertAction?.isEnabled = true
            
        } else {
            
            CubeAlert.confirmAlertAction?.isEnabled = false
        }
        
    }
    
    class func confirmOrCancel(title: String, message: String, confirmTitle: String, cancelTitles: String, inViewController viewController: UIViewController?, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: cancelTitles, style: .cancel) { action in
                cancelAction()
            }
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirmAction()
            }
            alertController.addAction(confirmAction)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}




