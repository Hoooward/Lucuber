//
//  CameraPreviewView.swift
//  Lucuber
//
//  Created by Howard on 9/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

  
    var session: AVCaptureSession? {
        
        get {
            
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        
        set {
            
            (self.layer as! AVCaptureVideoPreviewLayer).session = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        (self.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
    }

}
