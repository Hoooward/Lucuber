//
//  CubeAlert.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

final class CubeAlert {
    
    class func alert(title title: String, message: String?, dismissTitle: String, inViewController viewController: UIViewController?, withDismissAction dismissAction: (() -> Void)? ) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .Default) { action in
                if let dismissAction = dismissAction {
                    dismissAction()
                }
            }
            
            alertController.addAction(action)
            viewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    class func alertSorry(message message: String?, inViewController viewController: UIViewController?, withDismissAction dismissAction: () -> Void ){
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: dismissAction)
    }
    
    class func alertSorry(message message: String?, inViewController viewController: UIViewController?){
        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: nil)
    }
    
    class func textInput(title title: String, placeholder: String?, oldText: String?, dismissTitle: String, inViewController viewController: UIViewController?, withFinishedActin finishedAction: ((text: String) -> Void)?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler {
                textField in
                textField.placeholder = placeholder
                textField.text = oldText
            }
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .Default) {
                action in
                if let finishedAction = finishedAction {
                    if let textField = alertController.textFields?.first, text = textField.text {
                        finishedAction(text: text)
                    }
                }
            }
            
            alertController.addAction(action)
            viewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    static weak var confirmAlertAction: UIAlertAction?
    
    class func textInput(title title: String, message: String?, placeholder: String?, oldText: String?, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: ((text: String) -> Void)?, cancelAction: (() -> Void)?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler {
                textField in
                textField.placeholder = placeholder
                textField.text = oldText
                textField.addTarget(self, action: #selector(CubeAlert.handleTextFieldTextDidChangeNotification(_:)), forControlEvents: .EditingChanged)
            }
            
            let _cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .Cancel) {
                action in
                cancelAction?()
            }
            
            alertController.addAction(_cancelAction)
            
            let _confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .Default) {
                action in
                if let textField = alertController.textFields?.first, text = textField.text {
                    confirmAction?(text: text)
                }
            }
            
            _confirmAction.enabled = false
            self.confirmAlertAction = _confirmAction
            
            alertController.addAction(_confirmAction)
            
            viewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func handleTextFieldTextDidChangeNotification(sender: UITextField) {
        
        CubeAlert.confirmAlertAction?.enabled = sender.text?.utf16.count >= 1
    }
    
    class func confirmOrCancel(title title: String, message: String, confirmTitle: String, cancelTitles: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: () -> Void, cancelAction: () -> Void) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: cancelTitles, style: .Cancel) { action in
                cancelAction()
            }
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: confirmTitle, style: .Default) { action in
                confirmAction()
            }
            alertController.addAction(confirmAction)
            
            viewController?.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
}

extension UIViewController {
    
    func alertCanNotAccessCameraRoll() {
        dispatch_async(dispatch_get_main_queue()) {
            CubeAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Lucuber can not access your Camera Roll!\nBut you can change it in iOS Settings", comment: ""), confirmTitle: NSLocalizedString("Change it now", comment: ""), cancelTitles: NSLocalizedString("Dismiss", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
            })
        }
    }
    
    func alertCanNotOpenCamera() {
        
        dispatch_async(dispatch_get_main_queue()) {
            CubeAlert.confirmOrCancel(title: NSLocalizedString("抱歉", comment: ""), message: NSLocalizedString("Lucuber 不能访问您的摄像头.\n你可以更改摄像头访问的权限设置", comment: ""), confirmTitle: NSLocalizedString("前往设置", comment: ""), cancelTitles: NSLocalizedString("取消", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
                    
            })
        }
    }
    
    func alertCanNotOpenPhotoLibrary() {
        
        dispatch_async(dispatch_get_main_queue()) {
            CubeAlert.confirmOrCancel(title: NSLocalizedString("抱歉", comment: ""), message: NSLocalizedString("Lucuber 不能访问您的相册.\n你可以更改相册访问的权限设置", comment: ""), confirmTitle: NSLocalizedString("前往设置", comment: ""), cancelTitles: NSLocalizedString("取消", comment: ""), inViewController: self, withConfirmAction: {
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAction: {
                    
            })
        }
    }
    
    
}



















