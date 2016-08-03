//
//  MediaPreviewViewController.swift
//  Lucuber
//
//  Created by Howard on 7/28/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

let mediaPreviewWindow = UIWindow(frame: screenBounds)

class MediaPreviewViewController: UIViewController {
    
    // MARK: Properties
    
    
 
    var previewMedias: [UIImage] = []
    
    var startIndex: Int = 0
    
    var currentIndex: Int = 0 {
        
        didSet {
            
        }
    }
    
    private lazy var topPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    
    private lazy var bottomPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    
    var previewImageViewInitalFrame: CGRect?
    var topPreviewImage: UIImage?
    var bottomPreviewImage: UIImage?
    
    weak var transitionView: UIView?
    
    var afterDismissAction: (() -> Void)?
    
    var showFinished = false
    
    let mediaViewCellID = "MediaViewCell"
    
    
    @IBOutlet weak var mediasCollectionView: UICollectionView! {
        didSet {
            mediasCollectionView.showsVerticalScrollIndicator = false
            mediasCollectionView.showsHorizontalScrollIndicator = false
        }
    }
    /*
     在 Yep 中, 下面这个控制View是用来控制音频或者视频的播放器控制器. 这里暂时没有这个场景. 所以暂时可以不实现.
     */
    @IBOutlet weak var mediaControlView: MediaControlView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mediasCollectionView.backgroundColor = UIColor.clearColor()
        mediasCollectionView.registerNib(UINib(nibName: mediaViewCellID, bundle: nil), forCellWithReuseIdentifier: mediaViewCellID)
        
        guard let previewImageViewInitalFrame = previewImageViewInitalFrame else {
            return
        }
        
        topPreviewImageView.frame = previewImageViewInitalFrame
        bottomPreviewImageView.frame = previewImageViewInitalFrame
        
        view.addSubview(bottomPreviewImageView)
        view.addSubview(topPreviewImageView)
        
        guard let bottomPreviewImage = bottomPreviewImage else {
            return
        }
        
        bottomPreviewImageView.image = bottomPreviewImage
        topPreviewImageView.image = topPreviewImage
        
        let previewImageWidth = bottomPreviewImage.size.width
        let previewImageHeight = bottomPreviewImage.size.height
        
        let previewImageViewWidht = screenWidth
        let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidht
        
        
        mediasCollectionView.alpha = 0
        mediaControlView.alpha = 0
        
        topPreviewImageView.alpha = 0
        bottomPreviewImageView.alpha = 1
//        view.backgroundColor = UIColor.clearColor()
        
        view.alpha = 1
        view.backgroundColor = UIColor.redColor()
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{ [weak self] in
            
            print(self?.view)
            print(self?.view.backgroundColor)
//            self?.mediasCollectionView.backgroundColor = UIColor.blackColor()
            
            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 1
                self?.bottomPreviewImageView.alpha = 0
            }
            
            let frame = CGRect(x: 0, y: (screenHeight - previewImageViewHeight) * 0.5, width: previewImageViewWidht, height: previewImageViewHeight)
            
            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame
            
            
            }, completion: { [weak self] _ in
                
                self?.mediasCollectionView.alpha = 1
                
                
                UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveLinear, animations: { 
                    [weak self] in
                    
                    self?.mediaControlView.alpha = 1
                    
                    }, completion: { _ in  })
                
                UIView.animateWithDuration(0.1, delay: 0.1, options: .CurveLinear, animations: {
                    [weak self] in
                    
                    self?.topPreviewImageView.alpha = 0
                    self?.bottomPreviewImageView.alpha = 0
                    
                    }, completion: { _ in  })
                
        })
        
        
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip.direction = .Up
        view.addGestureRecognizer(swip)
        
        let swip2 = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip2.direction = .Down
        view.addGestureRecognizer(swip2)
        
        view.backgroundColor = UIColor.clearColor()
        
        
    }
    
    var isFirstLayoutSubviews = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayoutSubviews {
            
        }
    }
    
    deinit {
        print("预览视图已死")
    }
    
    private func makeUI() {
        
        
        
    }
    
    func dismiss(sender: UIGestureRecognizer?) {
        
        mediaPreviewWindow.windowLevel = UIWindowLevelNormal
        afterDismissAction?()
    }

}

extension MediaPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(previewMedias.count)
        return previewMedias.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(mediaViewCellID, forIndexPath: indexPath) as! MediaViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MediaViewCell {
            let previewMedia = previewMedias[indexPath.row]
            cell.mediaView.image = previewMedia
            
            cell.mediaView.tapToDismissAction = {
                [weak self] in
                self?.dismiss(nil)
            }
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
  
    
    
    
    
}







































