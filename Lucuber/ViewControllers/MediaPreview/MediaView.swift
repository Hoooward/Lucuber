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
                updateImageView(with: image)
            }
        }
    }
    
    
    func updateImageView(with image: UIImage) {
       
        scrollView.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        
        // floor 向下取整
        let size = CGSize(width: floor(image.size.width), height: floor(image.size.height))
        
        printLog("imageSize = \(size)")
        
//        imageView.bounds.size = size
//        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
//        imageView.frame.size = size
//        imageView.layoutIfNeeded()
//        scrollView.layoutIfNeeded()
//        self.layoutIfNeeded()
        
//        scrollView.contentSize = size
        let widthScale = scrollView.bounds.size.width / size.width
        let minSclae = widthScale
//        let scaleImageSize = CGSize(width: size.width * minSclae, height: size.height * minSclae)
        
//        imageView.frame = CGRect(origin: CGPoint.zero, size: scaleImageSize)
        scrollView.minimumZoomScale = minSclae
        scrollView.maximumZoomScale = max(minSclae, 3.0)
        
        scrollView.zoomScale = minSclae
//        scrollView.zoom(to: CGPoint.zero, withScale: minSclae)
        
        recenter(with: image)
        
        scrollView.isScrollEnabled = false
//        scrollView.updateConstraints()
    }
    
    func recenter(with image: UIImage) {
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        let scale = scrollView.minimumZoomScale
        let scaleImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
//        printLog("scaleImageSize = \(scaleImageSize)")
        
//        imageView.frame.size = scaleImageSize
        
        let hSpace = scaleImageSize.width < scrollViewSize.width ? (scrollViewSize.width - scaleImageSize.width) * 0.5 : 0
        let vSpace = scaleImageSize.height < scrollViewSize.height ? (scrollViewSize.height - scaleImageSize.height) * 0.5 : 0
//        printLog("hSpace = \(hSpace)")
//        printLog(scrollView.frame)
//        printLog(imageView.frame)
        
        scrollView.contentInset = UIEdgeInsets(top: vSpace, left: hSpace, bottom: vSpace, right: hSpace)
        
       
        
//        printLog("scrollView.contentInset = \(scrollView.contentInset)")
//        
//        printLog("scrollView.zoomScale = \(scrollView.zoomScale)")
//        printLog("scrollView.contentSize = \(scrollView.contentSize)")
        printLog("imageViewFrame = \(self.imageView.frame)")
        
        
        if (scaleImageSize.height / scaleImageSize.width) > (scrollViewSize.height / scrollViewSize.width) {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
       
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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
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
        
//        makeUI()
        
        layer.addSublayer(videoPlayerLayer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MediaView.doubleTapToZoom(sender:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MediaView.tapToDismiss(sender:)))
        tap.require(toFail: doubleTap)
        addGestureRecognizer(tap)
        
    }
    
    deinit {
        printLog("cell 中的 MediaView已死")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         makeUI()
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private func makeUI() {
        
        addSubview(scrollView)
//        addSubview(coverImageView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary: [String: AnyObject] = [
            "scrollView": scrollView,
            "imageView": imageView,
            "coverImageView": coverImageView,
            "containerView": containerView]
        
        let scrollViewContraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let scrollViewContraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activate(scrollViewContraintsV)
        NSLayoutConstraint.activate(scrollViewContraintsH)
        
//        let coverImageViewContraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[coverImageView]|", options: [], metrics: nil, views: viewsDictionary)
//        
//        let coverImageViewContraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[coverImageView]|", options: [], metrics: nil, views: viewsDictionary)
//        
//        NSLayoutConstraint.activate(coverImageViewContraintsH)
//        NSLayoutConstraint.activate(coverImageViewContraintsV)
        
        scrollView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let imageViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary)
        
        
        
        NSLayoutConstraint.activate(imageViewConstraintsH)
        NSLayoutConstraint.activate(imageViewConstraintsV)
        
        
    }
    
    // MARK: Notification & target
    @objc private func doubleTapToZoom(sender: UIGestureRecognizer) {
        
        let zoomPoint = sender.location(in: self)
        
        if !isZoomIn {
            isZoomIn = true
            
            zoomScaleBeforeZoomIn = scrollView.zoomScale
            scrollView.zoom(to: zoomPoint, withScale: scrollView.zoomScale * 2)
            scrollView.isScrollEnabled = true
            
        } else {
            
            if let zoomScale = zoomScaleBeforeZoomIn {
                zoomScaleBeforeZoomIn = nil
                isZoomIn = false
                scrollView.zoom(to: zoomPoint, withScale: zoomScale)
                scrollView.isScrollEnabled = false
            }
        }
    }

    @objc private func tapToDismiss(sender: UIGestureRecognizer) {
       
        if let zoomScale = zoomScaleBeforeZoomIn {
            let quickZoomDuration: TimeInterval = 0.35
            scrollView.zoom(to: CGPoint.zero, withScale: zoomScale, animationDuration: quickZoomDuration, animationCurve: .easeInOut)
            
            delay(quickZoomDuration) { [weak self] in
                self?.tapToDismissAction?()
            }
        } else {
            
            self.tapToDismissAction?()
        }
        
        
    }
    
}

extension MediaView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if inTapZoom {
            inTapZoom = false
            return
        }
        
        if let image = image {
            recenter(with: image)
            
            zoomScaleBeforeZoomIn = scrollView.minimumZoomScale
            isZoomIn = !(scrollView.zoomScale == scrollView.minimumZoomScale)
            scrollView.isScrollEnabled = isZoomIn
        }
    }
    
}






















