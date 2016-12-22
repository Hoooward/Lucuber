//
//  MediaPreviewViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


let mediaPreviewWindow = UIWindow(frame: UIScreen.main.bounds)

public enum PreviewMedia {
    case formula(DiscoverFormula)
    case message(Message)
    case attachmentType(ImageAttachment)
    case localImage(UIImage)
}

class MediaPreviewViewController: UIViewController {

    // MARK: - Properties
    var previewMedias: [PreviewMedia] = []

    var showFinished = false

    var currentIndex: Int = 0

    var startIndex: Int = 0 {
        didSet {
            currentIndex = startIndex
        }
    }

    // 为 true 时, 在 dismiss 动画时, 不更新 frame
    var isConversationDismissStyle: Bool = false

    var previewImageViewInitalFrame: CGRect?
    var topPreviewImage: UIImage?
    var bottomPreviewImage: UIImage?

    weak var transitionView: UIView?

    var afterDismissAction: (() -> Void)?

    fileprivate lazy var topPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()

    fileprivate lazy var bottomPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()

    @IBOutlet weak var mediasCollectionView: UICollectionView!
    @IBOutlet weak var mediaControlView: MediaControlView!


    fileprivate let mediaViewCellIdentifier = "MediaViewCell"
    // MARK: - Life Cycle


    override func viewDidLoad() {
        super.viewDidLoad()

        // 暂时只处理显示 image
        mediaControlView.type = .image

        mediasCollectionView.showsVerticalScrollIndicator = false
        mediasCollectionView.showsHorizontalScrollIndicator = false
        mediasCollectionView.isPagingEnabled = true

        mediasCollectionView.backgroundColor = UIColor.clear
        mediasCollectionView.register(UINib(nibName: mediaViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: mediaViewCellIdentifier)

        guard let previewImageViewInitalFrame = self.previewImageViewInitalFrame else {
            // 初始化时,需要赋值
            return
        }

        topPreviewImageView.frame = previewImageViewInitalFrame
        bottomPreviewImageView.frame = previewImageViewInitalFrame

        topPreviewImageView.contentMode = .scaleAspectFill
        bottomPreviewImageView.contentMode = .scaleAspectFill

        view.addSubview(topPreviewImageView)
        view.addSubview(bottomPreviewImageView)

        guard let bottomPreviewImage = self.bottomPreviewImage else {
            return
        }

        bottomPreviewImageView.image = bottomPreviewImage
        topPreviewImageView.image = topPreviewImage

        let previewImageWidth = bottomPreviewImage.size.width
        let previewImageHeight = bottomPreviewImage.size.height

        let previewImageViewWidth = UIScreen.main.bounds.width
        let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth

        mediasCollectionView.alpha = 0
        mediaControlView.alpha = 0

        topPreviewImageView.alpha = 0
        bottomPreviewImageView.alpha = 1

        view.backgroundColor = UIColor.clear

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            [weak self] in

            self?.view.backgroundColor = UIColor.black

            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 1
                self?.bottomPreviewImageView.alpha = 0
            }

            let frame = CGRect(x: 0,
                    y: (UIScreen.main.bounds.height - previewImageViewHeight) * 0.5,
                    width: previewImageViewWidth,
                    height: previewImageViewHeight)

            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame

        }, completion: { [weak self] finished in

            self?.mediasCollectionView.alpha = 1


            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                [weak self] in

                self?.mediaControlView.alpha = 1

            }, completion: { _ in })

            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                [weak self] in

                self?.topPreviewImageView.alpha = 0
                self?.bottomPreviewImageView.alpha = 0

            }, completion: { _ in

                self?.showFinished = true
            })
        })

        let swip = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismissPreview))
        swip.direction = .up
        view.addGestureRecognizer(swip)

        let swip2 = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewViewController.dismissPreview))
        swip.direction = .down
        view.addGestureRecognizer(swip2)
    }

    var isFirstLayoutSubviews = true

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayoutSubviews {

            let index = startIndex

            let targetIndexPath = IndexPath(item: index, section: 0)
            mediasCollectionView.scrollToItem(at: targetIndexPath, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: false)

            delay(0.1) { [weak self] in

                guard let cell = self?.mediasCollectionView.cellForItem(at: targetIndexPath) as? MediaViewCell else {
                    return
                }

                guard let previewMedia = self?.previewMedias[index] else {
                    return
                }


                // TODO: - 设置分享 actino
                self?.prepareForShare(with: cell, previewMedia: previewMedia)
            }
        }

        isFirstLayoutSubviews = false
    }

    deinit {
        printLog("MediaViewController 死亡")
    }

    func dismissPreview() {

        guard showFinished else {
            return
        }

        let finishDismissAction: () -> Void = {
            [weak self] in

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

        self.view.backgroundColor = UIColor.clear

        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            [weak self] in
            self?.mediaControlView.alpha = 0
            self?.mediasCollectionView.alpha = 0
        }, completion: nil)

        var frame = self.previewImageViewInitalFrame ?? CGRect.zero


        if currentIndex != startIndex && !isConversationDismissStyle {
            let offsetIndex = currentIndex - startIndex
            frame.origin.x += CGFloat(offsetIndex) * frame.width + CGFloat(offsetIndex) * 4
        }


        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in

            if let _ = self?.topPreviewImage {
                self?.topPreviewImageView.alpha = 0
                self?.bottomPreviewImageView.alpha = 1
            }

            self?.topPreviewImageView.frame = frame
            self?.bottomPreviewImageView.frame = frame

        }, completion: { _ in
            finishDismissAction()
        }
        )
    }


    fileprivate func prepareForShare(with cell: MediaViewCell, previewMedia: PreviewMedia) {
        // 设置分享的动作
    }
}
extension MediaPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewMedias.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mediaViewCellIdentifier, for: indexPath) as! MediaViewCell

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? MediaViewCell {
            
            let previewMedia = previewMedias[indexPath.row]
            
            switch previewMedia {
                
            case .localImage(let image):
                
                mediaControlView.isHidden = true
                cell.mediaView.image = image
                cell.activityIndicator.stopAnimating()
                
            case .attachmentType(let attachment):
                
                mediaControlView.isHidden = false
                cell.activityIndicator.startAnimating()
                
                if attachment.isTemporary {
                    
                    cell.mediaView.image = attachment.image
                    cell.activityIndicator.stopAnimating()
                    
                } else {
                    
                    CubeImageCache.shard.imageOfAttachment(attachment: attachment, withSideLenght: nil, imageExtesion: CubeImageCache.imageExtension.jpeg, completion: {
                        url, image, cacheType in
                        cell.mediaView.image = image
                        cell.activityIndicator.stopAnimating()
                    })
                }

            case .message(let message):

                switch message.mediaType {

                case MessageMediaType.image.rawValue:

                    mediaControlView.type = .image
                    cell.mediaView.scrollView.isHidden = false

                    if let imageFileUrl = FileManager.cubeMessageImageURL(with: message.localAttachmentName), let image = UIImage(contentsOfFile: imageFileUrl.path) {
                        cell.mediaView.image = image
                    }

                    cell.activityIndicator.stopAnimating()

                default:
                    break
                }

            default:
                break
            }
            
            cell.mediaView.tapToDismissAction = {
                [weak self] in
                self?.dismissPreview()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension MediaPreviewViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let cellWidth = UIScreen.main.bounds.width
        let index = Int(scrollView.contentOffset.x / cellWidth)
        
        currentIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        
        if let cell = mediasCollectionView.cellForItem(at: indexPath) as? MediaViewCell {
            
            guard let image = cell.mediaView.image else {
                return
            }
            
            let attachment = self.previewMedias[index]
            
            prepareForShare(with: cell, previewMedia: attachment)
            
            switch attachment {
            case .attachmentType(_):
                
                
                bottomPreviewImageView.image = image
                
                let previewImageWidth = image.size.width
                let previewImageHeight = image.size.height
                
                let previewImageViewWidth = UIScreen.main.bounds.width
                let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth
                
                let frame = CGRect(x: 0, y: (UIScreen.main.bounds.height - previewImageViewHeight) * 0.5, width: previewImageViewWidth, height: previewImageViewHeight)
                
                bottomPreviewImageView.frame = frame
                
                
            case .localImage(let image):
                
                bottomPreviewImageView.image = image
                let previewImageWidth = image.size.width
                let previewImageHeight = image.size.height
                
                let previewImageViewWidth = UIScreen.main.bounds.width
                let previewImageViewHeight = (previewImageHeight / previewImageWidth) * previewImageViewWidth
                
                let frame = CGRect(x: 0, y: (UIScreen.main.bounds.height - previewImageViewHeight) * 0.5, width: previewImageViewWidth, height: previewImageViewHeight)
                
                bottomPreviewImageView.frame = frame
                
            default:
                break
            }
            
        }
    }
    
    
}























