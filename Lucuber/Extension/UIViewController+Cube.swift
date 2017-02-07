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
import AutoReview

protocol Shareable { }

extension URL: Shareable { }

extension UIImage: Shareable { }

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

//MARK: - Review
extension UIViewController {
    
    func remindUserToReview() {
        
        let remindAction: ()->() = { [weak self] in
            
            guard self?.view.window != nil else {
                return
            }
            
            let info = AutoReview.Info(
                appID: "1197999540",
                initialExponentialBackoff: 1,
                title: "评价 Lucuber",
                message: "希望你能在 AppStore 留下对 Lucuber 的评价/n你的支持是我最大的动力/n感谢！",
                doNotRemindMeInThisVersionTitle: "不再提示",
                maybeNextTimeTitle: "下次再说",
                confirmTitle: "去评论"
            )
            self?.autoreview_tryReviewApp(withInfo: info)
        }
        
        delay(3, clouser: remindAction)
    }
}

// MARK: - Report
extension UIViewController {
    
    enum ReportObject {
        case user(ProfileUser)
        case feed(feedID: String)
        case message(messageID: String)
    }
    
    func report(_ object: ReportObject) {
        
        let reportWithReason: (ReportReason) -> Void = { [weak self] reason in
            
            // 暂时仅实现 Feed 的举报
            switch object {
                
            case .feed(let feedID):
                
                reportFeedWithFeedID(feedID, forReason: reason, failureHandler: { reason, errorMessage in
                    CubeAlert.alertSorry(message: "上传举报信息失败, 请检查网络连接", inViewController: self)
                }, completion: {
                })
                
            default:
                break
            }
        }
        
        let reportAlertController = UIAlertController(title: "举报原因", message: nil, preferredStyle: .actionSheet)
        
        let pornoReasonAction: UIAlertAction = UIAlertAction(title: ReportReason.porno.describe, style: .default, handler: { _ in
            reportWithReason(.porno)
        })
        
        reportAlertController.addAction(pornoReasonAction)
        
        let advertistingReasonAction: UIAlertAction = UIAlertAction(title: ReportReason.advertising.describe, style: .default, handler: { _ in
            reportWithReason(.advertising)
        })
        
        reportAlertController.addAction(advertistingReasonAction)
        
        let scamsReasonAction: UIAlertAction = UIAlertAction(title: ReportReason.scams.describe, style: .default) { _ in
            reportWithReason(.scams)
        }
        reportAlertController.addAction(scamsReasonAction)
        
        let otherReasonAction: UIAlertAction = UIAlertAction(title: ReportReason.other("").describe, style: .default, handler: { [weak self] _  in
            
            CubeAlert.textInput(title: "其他原因", message: nil, placeholder: nil, oldText: nil, confirmTitle: "提交", cancelTitle: "取消", inViewController: self, confirmAction: { text in
                reportWithReason(.other(text))
            }, cancelAction: nil)
        })
        
        reportAlertController.addAction(otherReasonAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        reportAlertController.addAction(cancelAction)
        
        self.present(reportAlertController, animated: true, completion: nil)
    }
}

// MARK: - URL
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

// MARK: - Alert
extension UIViewController {
    
    func alertCanNotAccessCameraRoll() {
        DispatchQueue.main.async {
            CubeAlert.alertSorry(message: "设备没有摄像头", inViewController: self)
        }
    }
    
    func alertCanNotOpenCamera() {
        
        DispatchQueue.main.async {
            CubeAlert.confirmOrCancel(title: "抱歉", message: "你没有开启 Lucuber 访问摄像头的权限.\n请前往设置修改.", confirmTitle: "前往设置", cancelTitles: "取消", inViewController: self, confirmAction: {
                
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
            
            CubeAlert.confirmOrCancel(title: "", message: "你没有开启 Lucuber 访问相册的权限.\n请前往设置修改", confirmTitle: "前往设置", cancelTitles: "取消", inViewController: self, confirmAction: {
                
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
    
    func alertCanNotAccessNotification() {
        
        DispatchQueue.main.async {
            
            CubeAlert.confirmOrCancel(title: "", message: "你没有开启 Lucuber 的通知权限.\n如果希望接受消息提醒,请前往设置修改", confirmTitle: "前往设置", cancelTitles: "取消", inViewController: self, confirmAction: {
                
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
