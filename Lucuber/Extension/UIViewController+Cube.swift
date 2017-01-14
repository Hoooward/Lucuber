//
//  UIViewController+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import SafariServices
import MonkeyKing

protocol Shareable {
}

extension URL: Shareable {
}

extension UIImage: Shareable {
}

extension UIViewController {
    
    func share< T: Any>(info sessionInfo: MonkeyKing.Info, timelineInfo: MonkeyKing.Info? = nil, defaultActivityItem activityItem: T, description: String? = nil) where T: Shareable {
        
        var activityItems: [Any] = [activityItem]
        if let description = description {
            activityItems.append(description)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension UIViewController {
    
    func cube_openURL(_ URL: URL) {
        
        if let URL = URL.validNetworkURL {
           
            let safariViewController = SFSafariViewController(url: URL)
            present(safariViewController, animated: true, completion: nil)
            
        } else {
            CubeAlert.alertSorry(message: "无效的URL", inViewController: self)
        }
    }
}

extension UIViewController {
    
    func alertCanNotAccessCameraRoll() {
        DispatchQueue.main.async {
            CubeAlert.alertSorry(message: "设备没有摄像头", inViewController: self)
        }
    }
    
    func alertCanNotOpenCamera() {
        
        DispatchQueue.main.async {
            CubeAlert.confirmOrCancel(title: "抱歉", message: "Lucuber 不能访问您的摄像头.\n你可以更改摄像头访问的权限设置.", confirmTitle: "前往设置", cancelTitles: "取消", inViewController: self, confirmAction: {
                
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                
                if #available(iOS 10, *)  {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                } else {
                    
                    UIApplication.shared.openURL(url)
                }
                
                }, cancelAction: {
                    
            })
        }
    }
    
    func alertCanNotOpenPhotoLibrary() {
        
        DispatchQueue.main.async {
            
            CubeAlert.confirmOrCancel(title: "抱歉", message: "Lucuber 不能访问您的相册.\n你可以更改相册访问的权限设置", confirmTitle: "前往设置", cancelTitles: "取消", inViewController: self, confirmAction: {
                
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                
                if #available(iOS 10, *)  {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                } else {
                    
                    UIApplication.shared.openURL(url)
                }
                
                }, cancelAction: {
                    
            })
        }
    }
}
