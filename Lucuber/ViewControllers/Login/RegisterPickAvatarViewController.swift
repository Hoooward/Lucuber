//  RegisterPickAvatarViewController.swift
//  Lucuber
//
//  Created by Howard on 9/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVFoundation
import AVOSCloud
import Photos

class RegisterPickAvatarViewController: UIViewController {
    
    /// 进入到此控制器，说明已经成功登录，但已登录的用户，仅有手机号码信息。
    /// 这里会进行 nickName 和 AvatarImage 的更新
    /// cameraPreviewView 暂时用不到
    
    // MARK: - Properties
    
    var nickName: String?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var openCameraButton: BorderButton!
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    @IBOutlet weak var nikeNameLabel: UILabel!
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "完成注册", style: .plain, target: self, action: #selector(RegisterPickAvatarViewController.next(_:)))
        button.isEnabled = false
        return button
    }()
    
    private enum PickAvatarState {
        case Default
        case Captured
    }

    fileprivate var avatar = UIImage() {
        willSet {
            avatarImageView.image = newValue
        }
    }
    
    fileprivate var pickAvatarState: PickAvatarState = .Default {
        
        willSet {
            
            switch newValue {
                
            case .Default:
                
                cameraPreviewView.isHidden = true
                avatarImageView.isHidden = false
                avatarImageView.image = UIImage(named: "default_avatar")
                nextButton.isEnabled = false
                
            case .Captured:
                
                cameraPreviewView.isHidden = true
                avatarImageView.isHidden = false
                nextButton.isEnabled = true
                
                break
            }
        }
        
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "注册"
        view.backgroundColor = UIColor.white
        
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.hidesBackButton = true
        avatarImageView.clipsToBounds = true
        
        openCameraButton.setTitle("选择照片", for: .normal)
        openCameraButton.setTitleColor(UIColor.white, for: .normal)
        openCameraButton.backgroundColor = UIColor.cubeTintColor()
        openCameraButton.addTarget(self, action: #selector(RegisterPickAvatarViewController.openPhotoLibraryPicker), for: .touchUpInside)
        
        nikeNameLabel.textColor = UIColor.inputText()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = AVUser.current() {
            nikeNameLabel.text = user.getUserNickName() ?? ""
        }
        
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            
            if status == PHAuthorizationStatus.authorized {
                printLog("授权成功")
            } else {
                
                printLog("授权失败")
                
            }
            
        }
    }
    
//    private lazy var sessionQueue: dispattchq = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
    
//    private lazy var session: AVCaptureSession = {
//        let session = AVCaptureSession()
//        session.sessionPreset = AVCaptureSessionPreset640x480
//        return session
//    }()
//    
//    private let mediaType = AVMediaTypeVideo
//    
//    private lazy var videoDeviceInPut: AVCaptureDeviceInput? = {
//        
//        let devices = AVCaptureDevice.devicesWithMediaType(self.mediaType)
//        
//        var captureDevice = devices.first as? AVCaptureDevice
//        
//        for device in devices as! [AVCaptureDevice] {
//            
//            if device.position == AVCaptureDevicePosition.init(rawValue: 0){
//                
//                captureDevice = device
//                
//                break
//            }
//        }
//        
//        
//        return try? AVCaptureDeviceInput(device: captureDevice)
//       
//        
//    }()
    
    // MARK: - Target & Action
    func next(_ barButton: UIBarButtonItem) {
        
        CubeHUD.showActivityIndicator()
        
        let image = avatar.largestCenteredSquareImage().resizeTo(targetSize: Config.Avatar.maxSize)
        
        let imageData = UIImageJPEGRepresentation(image, 0.7)
        
        if let imageData = imageData {
            
            updateAvatar(withImageData: imageData, failureHandler: { error in
                
                CubeHUD.hideActivityIndicator()
                
                CubeAlert.alertSorry(message: "上传头像失败，请检查网络连接或稍后再试。", inViewController: self)
                
                }, completion: { URLString in
                    
                    CubeHUD.hideActivityIndicator()
                    
                    // 本地保存 avatarURL
                    UserDefaults.setNewUser(avatarURL: URLString)
                    
                    let nickName = UserDefaults.getNewUserNickName()!
                    let avatarURL = UserDefaults.getNewUserAvatarURL()!
                    
                    updateUserInfo(nickName: nickName, avatarURL: avatarURL, failureHandler: { error in
                        
                        CubeHUD.hideActivityIndicator()
                        if let error = error {
                            
                            switch error.code {
                                
                            case 9999:
                                
                                CubeAlert.alertSorry(message: "注册异常， 请尝试退出应用重启进入。", inViewController: self)
                                
                            default:
                                
                                CubeAlert.alertSorry(message: "用户信息上传失败， 请检查网络连接或稍后再试。", inViewController: self)
                            }
                        }
                        
                        }, completion: {
                            
                            CubeHUD.hideActivityIndicator()
                           // 用户信息更新完成。进入Main
                            
                            NotificationCenter.default.post(name: Notification.Name.changeRootViewControllerNotification, object: nil)
                            
                    })
                    
            })
            
        }
    }
    
    func openPhotoLibraryPicker() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            self.alertCanNotOpenPhotoLibrary()
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            self.alertCanNotOpenPhotoLibrary()
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
  

}

extension RegisterPickAvatarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.avatar = image
            self.pickAvatarState = .Captured
            
        }
        dismiss(animated: true, completion: nil)
    }
    
 
}




















