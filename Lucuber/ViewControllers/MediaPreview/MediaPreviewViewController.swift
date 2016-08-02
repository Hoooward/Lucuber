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
//    @IBOutlet weak var mediaControlView: 
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mediasCollectionView.backgroundColor = UIColor.blackColor()
        mediasCollectionView.registerNib(UINib(nibName: mediaViewCellID, bundle: nil), forCellWithReuseIdentifier: mediaViewCellID)
        
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip.direction = .Up
        view.addGestureRecognizer(swip)
        
        let swip2 = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip2.direction = .Down
        view.addGestureRecognizer(swip2)
        
        view.backgroundColor = UIColor.clearColor()
        
        
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







































