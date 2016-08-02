//  MediaView.swift
//  Lucuber
//
//  Created by Howard on 8/1/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVFoundation

final class MediaView: UIView {

    var tapToDismissAction: (() -> Void)?
        
    // MARK: - Properties
    var inTapZoom = false
    var isZoomIn = false
    
    var zoomScaleBeforeZoomIn: CGFloat?
    
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                updateImageViewWithimage(image)
            }
        }
    }
    
    func updateImageViewWithimage(image: UIImage) {
       
        scrollView.frame = UIScreen.mainScreen().bounds
        
        // floor 向下取整
        let size = CGSize(width: floor(image.size.width), height: floor(image.size.height))
        
        imageView.frame = CGRect(origin: CGPointZero, size: size)
        print("imageSize = \(size)")
        
        let widthScale = scrollView.bounds.size.width / size.width
        let minSclae = widthScale
        
        scrollView.minimumZoomScale = minSclae
        scrollView.maximumZoomScale = max(minSclae, 3.0)
        
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        recenterImage(image)
        
        scrollView.scrollEnabled = false
    }
    
    func recenterImage(image: UIImage) {
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        let scale = scrollView.minimumZoomScale
        let scaleImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
        print("scaleImageSize = \(scaleImageSize)")
        
//        imageView.frame.size = scaleImageSize
        
        let hSpace = scaleImageSize.width < scrollViewSize.width ? (scrollViewSize.width - scaleImageSize.width) * 0.5 : 0
        let vSpace = scaleImageSize.height < scrollViewSize.height ? (scrollViewSize.height - scaleImageSize.height) * 0.5 : 0
        print("hSpace = \(hSpace)")
        print(scrollView.frame)
        print(imageView.frame)
        
        scrollView.contentInset = UIEdgeInsets(top: vSpace, left: hSpace, bottom: vSpace, right: hSpace)
        
        
        
        
    }

    

    
    var coverImage: UIImage? {
        didSet {
            
        }
    }
    
    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    lazy var videoPlayerLayer: AVPlayerLayer = {
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        return playerLayer
    }()
    
    
    // MARK: Life cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
        
        layer.addSublayer(videoPlayerLayer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MediaView.doubleTapToZoom(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MediaView.tapToDismiss(_:)))
        tap.requireGestureRecognizerToFail(doubleTap)
        addGestureRecognizer(tap)
        
    }
    
    deinit {
        print("cell 中的 MediaView已死")
    }

    
    private func makeUI() {
        
        addSubview(scrollView)
        addSubview(coverImageView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary: [String: AnyObject] = [
            "scrollView": scrollView,
            "imageView": imageView,
            "coverImageView": coverImageView]
        
        let scrollViewContraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let scrollViewContraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activateConstraints(scrollViewContraintsV)
        NSLayoutConstraint.activateConstraints(scrollViewContraintsH)
        
        let coverImageViewContraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[coverImageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let coverImageViewContraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[coverImageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activateConstraints(coverImageViewContraintsH)
        NSLayoutConstraint.activateConstraints(coverImageViewContraintsV)
        
        scrollView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let imageViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let imageViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        
        NSLayoutConstraint.activateConstraints(imageViewConstraintsH)
        NSLayoutConstraint.activateConstraints(imageViewConstraintsV)
        
        
    }
    
    // MARK: Notification & target
    @objc private func doubleTapToZoom(sender: UIGestureRecognizer) {
        
        
        let zoomPoint = sender.locationInView(self)
        
        if !isZoomIn {
            isZoomIn = true
            
            zoomScaleBeforeZoomIn = scrollView.zoomScale
            let zoomRect = CGRect(x: zoomPoint.x, y: zoomPoint.y, width: screenWidth, height: screenHeight)
            scrollView.zoomToRect(zoomRect, animated: true)
        } else {
            isZoomIn = false
        }
        
        
        //当前的缩放比例
        let currentSclae = scrollView.zoomScale
        
        
        
        print("当前的缩放比例 = \(currentSclae)")
    }
    
    @objc private func tapToDismiss(sender: UIGestureRecognizer) {
        
        delay(0.35) { [weak self] in
            self?.tapToDismissAction?()
        }
        
        
    }
    
}

extension MediaView: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        print(#function)
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        print(#function)
        if inTapZoom {
            inTapZoom = false
            return
        }
        
        if let image = image {
            recenterImage(image)
            
        }
    }
    
}






















