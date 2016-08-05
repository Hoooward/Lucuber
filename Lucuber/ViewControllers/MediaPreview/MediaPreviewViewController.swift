//
//  MediaPreviewViewController.swift
//  Lucuber
//
//  Created by Howard on 7/28/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import MonkeyKing

let mediaPreviewWindow = UIWindow(frame: screenBounds)

enum PreviewMedia {
    case Message
    case AttachmentType(ImageAttachment)
}


class MediaPreviewViewController: UIViewController {
    
  
    // MARK: Properties
    
    var previewMedias: [PreviewMedia] = []
    
    var showFinished = false
 
//    var previewMedias: [UIImage] = []
    
    var startIndex: Int = 0 {
        didSet {
            currentIndex = startIndex
        }
    }
    
    var currentIndex: Int = 0
    
    
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
    
    
    let mediaViewCellID = "MediaViewCell"
    
    
    @IBOutlet weak var mediasCollectionView: UICollectionView! {
        didSet {
            mediasCollectionView.showsVerticalScrollIndicator = false
            mediasCollectionView.showsHorizontalScrollIndicator = false
            mediasCollectionView.pagingEnabled = true
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
        
        topPreviewImageView.contentMode = .ScaleAspectFill
        bottomPreviewImageView.contentMode = .ScaleAspectFill
        
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
        
        view.backgroundColor = UIColor.clearColor()
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{ [weak self] in
            
            self?.view.backgroundColor = UIColor.blackColor()
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
                    
                    }, completion: { _ in
                        
                        self?.showFinished = true
                })
                
        })
        
        
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip.direction = .Up
        view.addGestureRecognizer(swip)
        
        let swip2 = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismiss(_:)))
        swip2.direction = .Down
        view.addGestureRecognizer(swip2)
        
        
        
    }
    
    var isFirstLayoutSubviews = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayoutSubviews {
            
            let index = startIndex
            
            let targetIndexPath = NSIndexPath(forItem: index, inSection: 0)
            mediasCollectionView.scrollToItemAtIndexPath(targetIndexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
            
            
            delay(0.1) { [weak self] in
                
                
                
                guard let cell = self?.mediasCollectionView.cellForItemAtIndexPath(targetIndexPath) as? MediaViewCell else {
                    return
                }
                
                guard let previewMedia = self?.previewMedias[index] else {
                    return
                }
                
                self?.prepareForSharewithCell(cell, previewMedia: previewMedia)
            }
          
        }
        
        isFirstLayoutSubviews = false
    }
    
    deinit {
        print("预览视图已死")
    }
    
    func dismiss(sender: UIGestureRecognizer?) {
        
        guard showFinished else {
            return
        }
        
        let finishDismissaction: () -> Void = { [weak self] in
            
            mediaPreviewWindow.windowLevel = UIWindowLevelNormal
            
            self?.afterDismissAction?()
            
            delay(0.05) {
                mediaPreviewWindow.rootViewController = nil
            }
        }
        
        if let _ = topPreviewImage {
            topPreviewImageView.alpha = 1
            bottomPreviewImageView.alpha = 0
            
        } else {
            bottomPreviewImageView.alpha = 1
        }
        
        self.view.backgroundColor = UIColor.clearColor()
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseInOut, animations: {
            [weak self] in
            self?.mediasCollectionView.alpha = 0
            self?.mediaControlView.alpha = 0
            }, completion: nil)
        
        
        var frame = self.previewImageViewInitalFrame ?? CGRectZero
        
        if currentIndex != startIndex {
            let offsetIndex = currentIndex - startIndex
            frame.origin.x += CGFloat(offsetIndex) * frame.width + CGFloat(offsetIndex) * 4
            
        }
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
            [weak self] in
            
            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 0
                self?.bottomPreviewImageView.alpha = 1
            }
            
            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame
            
            }, completion: { _ in
                finishDismissaction()
            }
        )
        
       
    }
    
    private func prepareForSharewithCell(cell: MediaViewCell, previewMedia: PreviewMedia) {
        
        switch previewMedia {
        case .AttachmentType(_):
            
            mediaControlView.type = .Image
            
            mediaControlView.shareAction = {
                [weak self] in
                
                guard let image = cell.mediaView.image else {
                    return
                }
                
      
                
//                let sessionMessage = MonkeyKing.Message.WeChat(.Session(info: info))
                
               MonkeyKing.registerAccount(MonkeyKing.Account.WeChat(appID: "wxd930ea5d5a258f4f", appKey: "6cfda8ca2d5a0e63fe47ad897d5de995"))
                
                let info = MonkeyKing.Info(
                    title: nil,
                    description: nil,
                    thumbnail: nil,
                    media: .Image(image)
                )
               
          
                let sessionMessage = MonkeyKing.Message.WeChat(.Session(info: info))
                
                let weChatSessionActivity = AnyActivity(type: "com.Lucuber.China.Wechat.Sesstion", title: "微信好友", image: UIImage(), message: sessionMessage, completionHandler: { (result) in
                    print("发送 \(result)")
                })
                
                let timeLineMessage = MonkeyKing.Message.WeChat(.Timeline(info: info))
                
                let weChatTimelineActivity = AnyActivity(type: "com.Lucuber.China.Wechat.Sesstion", title: "微信朋友圈", image: UIImage(), message: timeLineMessage, completionHandler: { (result) in
                    print("发送 \(result)")
                })
                
                
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: [weChatSessionActivity, weChatTimelineActivity])
                activityViewController.excludedActivityTypes = [UIActivityTypeMessage,UIActivityTypeMail]
                
                self?.presentViewController(activityViewController, animated: true, completion: nil)
            }
            
            
        default:
            break
        }
    }

}

extension MediaPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewMedias.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(mediaViewCellID, forIndexPath: indexPath) as! MediaViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MediaViewCell {
            
            let previewMedia = previewMedias[indexPath.row]
            
            switch previewMedia {
                
            case .AttachmentType(let attachment):
                
               ImageCache.shardInstance.imageOfAttachment(attachment, withSideLenght: nil, completion: { (url, image, cacheType) in
                    cell.mediaView.image = image
               })
                
            default:
                break
            }
            
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

extension MediaPreviewViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let cellWidth = screenWidth
        let index = Int(scrollView.contentOffset.x / cellWidth)
        
        
        currentIndex = index
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        
        if let cell = mediasCollectionView.cellForItemAtIndexPath(indexPath) as? MediaViewCell {
          
            guard let image = cell.mediaView.image else {
                return
            }
            
            let attachment = self.previewMedias[index]
            
            prepareForSharewithCell(cell, previewMedia: attachment)
            
            switch attachment {
            case .AttachmentType(_):
                
                bottomPreviewImageView.image = image
                
                let previewImageWidth = image.size.width
                let previewImageHeight = image.size.height
                
                let previewImageViewWidth = screenWidth
                let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth
                
                let frame = CGRect(x: 0, y: (screenHeight - previewImageViewHeight) * 0.5, width: previewImageViewWidth, height: previewImageViewHeight)
                
                bottomPreviewImageView.frame = frame
                
                
            default:
                break
            }
            
        }
    }
    

}







































