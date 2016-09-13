//  RegisterPickAvatarViewController.swift
//  Lucuber
//
//  Created by Howard on 9/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVFoundation

class RegisterPickAvatarViewController: UIViewController {
    
    
    // MARK: - Properties
    
    @IBOutlet weak var avatarImageView: UIImageView!
//    var loginUser: AVUser?
    @IBOutlet weak var openCameraButton: BorderButton!

    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(RegisterPickAvatarViewController.next(_:)))
        
        button.enabled = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = AVUser.currentUser() {
            printLog(user)
        }

    }
    
    private enum PickAvatarState {
        case Default
        case Captured
    }

    private var avatar = UIImage() {
        willSet {
            avatarImageView.image = newValue
        }
    }
    
    private var pickAvatarState: PickAvatarState = .Default {
        
        willSet {
            
            switch newValue {
                
            case .Default:
                
                cameraPreviewView.hidden = true
                avatarImageView.hidden = false
                avatarImageView.image = UIImage(named: "default_avatar")
                nextButton.enabled = false
                
            case .Captured:
                
                cameraPreviewView.hidden = true
                avatarImageView.hidden = false
                nextButton.enabled = true
                
                break
            }
        }
        
    }
    
    private lazy var sessionQueue: dispatch_queue_t = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
    
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset640x480
        return session
    }()
    
    private let mediaType = AVMediaTypeVideo
    
    private lazy var videoDeviceInPut: AVCaptureDeviceInput? = {
        
        let devices = AVCaptureDevice.devicesWithMediaType(self.mediaType)
        
        var captureDevice = devices.first as? AVCaptureDevice
        
        for device in devices as! [AVCaptureDevice] {
            
            if device.position == AVCaptureDevicePosition.init(rawValue: 0){
                
                captureDevice = device
                
                break
            }
        }
        
        
        return try? AVCaptureDeviceInput(device: captureDevice)
       
        
    }()
    
    // MARK: - Target & Action
    func next(barButton: UIBarButtonItem) {
        
    }
    
  

}




















