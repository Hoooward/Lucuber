//
//  NewFeedViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import RealmSwift
import AVOSCloud
import Kingfisher

class NewFeedViewController: UIViewController {
    
    enum Attachment {
        case normal
        case formula
        case location
        case voice
    }
    
    enum UploadState {
        case ready
        case uploading
        case failed(message: String)
        case success
    }
    
    var uploadState: UploadState = .ready {
        
        willSet {
            
            switch newValue {
            case .ready:
                break
                
            case .uploading:
                postButton.isEnabled = false
                messageTextView.resignFirstResponder()
                CubeHUD.showActivityIndicator()
                
            case .failed(message: let message):
                CubeHUD.hideActivityIndicator()
                postButton.isEnabled = true
                
                if presentingViewController != nil {
                    CubeAlert.alertSorry(message: message, inViewController: self)
                } else {
                    
                    printLog(feedsViewController)
//                    FeedsViewController.handleError
                }
                feedsViewController?.handleUploadingErrorMessage(message: message)
                
            case .success:
                CubeHUD.hideActivityIndicator()
                messageTextView.text = nil
            }
        }
    }
    
    weak var feedsViewController: FeedsViewController?
    var getFeedsViewController: (() -> FeedsViewController?)?
    var attachment: Attachment = .normal
    
    var beforUploadingFeedAction: ((DiscoverFeed, NewFeedViewController) -> Void)?
    var afterUploadingFeedAction: ((DiscoverFeed) -> Void)?
    var cancelCreatedFormulaFeed: ((Formula) -> Void)?
    
    var mediaImages = [UIImage]() {
        didSet {
            
            let indexSet = IndexSet(integer: 0)
            mediaCollectionView.performBatchUpdates({
                [weak self] in
              
                self?.mediaCollectionView.reloadSections(indexSet)
            }, completion: nil)
        }
    }
    
    fileprivate var pickedImageAssets = [PHAsset]()
    
    var attachmentFormula: Formula?
    
    fileprivate var isNeverInputMessage = true
    fileprivate var isReadyForPost = false {
        willSet {
            
            postButton.isEnabled = newValue
            
            if !newValue && isNeverInputMessage {
                messageTextView.text = placeholderOfMessage
            }
            
            messageTextView.textColor = newValue ? UIColor.black : UIColor.lightGray
        }
    }
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    
    @IBOutlet weak var formulaView: FeedFormulaView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    fileprivate let placeholderOfMessage = "写点什么"
    fileprivate let feedMediaAdddCellIdentifier = "FeedMediaAddCell"
    fileprivate let feedMediaCellIdentifier = "FeedMediaCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let formula = attachmentFormula {
//            formulaView.configViewWith(formula: formula)
//        }
        
        switch attachment {
        case .normal:
            
            title = "新话题"
            mediaCollectionView.isHidden = false
            formulaView.isHidden = true
            
        case .formula:
            
            title = "创建公式(2/2)"
            mediaCollectionView.isHidden = true
            formulaView.isHidden = false
            
        default:
            break
            
        }
        
        feedsViewController = getFeedsViewController?()
        
        formulaView.configViewWith(formula: attachmentFormula)
        
        formulaView.tapAction = { [weak self] in
            _ = self?.navigationController?.popViewController(animated: true)
        }
        
        view.backgroundColor = UIColor.cubeBackgroundColor()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        
        let messageTextViewHeight = CubeRuler.iPhoneVertical(100, 120, 170, 200).value
        messageTextViewHeightContraint.constant = CGFloat(messageTextViewHeight)
        messageTextView.layoutIfNeeded()
        
        isReadyForPost = false
        messageTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.delegate = self
        //        messageTextView.tintColor = UIColor.cubeTintColor()
        
        mediaCollectionView.backgroundColor = UIColor.clear
        
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
    }
    
    deinit {
    }
    
    // MARK: -  Action & Target
    
    func tryMakeUploadingFeed() -> DiscoverFeed? {
        
        guard let currentAVUser = AVUser.current(), let realm = try? Realm(), let _ = currentUser(in: realm) else {
            return nil
        }
        
        var category: FeedCategory = .text
        
        let message = messageTextView.text.trimming(trimmingType: .whitespaceAndNewLine)
        
        var feedAttachment: DiscoverFeed.Attachment?
        
        switch attachment {
            
        case .normal:
            
            if !mediaImages.isEmpty {
                category = .image
                
                var imageAttachments: [ImageAttachment] = []
                
                for image in mediaImages {
                    
                    let imageWidth = image.size.width
                    let imageHeight = image.size.height
                    
                    let fixedImageWidth: CGFloat
                    let fixedImageHeight: CGFloat
                    
                    if imageWidth > imageHeight {
                        fixedImageWidth = min(imageWidth, CGFloat(1024))
                        fixedImageHeight = imageHeight * (fixedImageWidth / imageWidth)
                    } else {
                        fixedImageHeight =  min(imageHeight, CGFloat(1024))
                        fixedImageWidth = imageWidth * (fixedImageHeight / imageHeight)
                    }
                    
                    let fixedSize = CGSize(width: fixedImageWidth, height: fixedImageHeight)
                    
                    if let image = image.resizeTo(targetSize: fixedSize, quality: .high) {
                        
                        let attachment = ImageAttachment(metadata: "", URLString: "", image: image)
                        imageAttachments.append(attachment)
                    }
                }
                
                if !imageAttachments.isEmpty {
                   feedAttachment = .images(imageAttachments)
                }
            }
            
        case .formula:

            if let formula = attachmentFormula, let discoverFormula = parseFormulaToDisvocerModel(with: formula) {
                category = .formula
                feedAttachment = .formula(discoverFormula)
                // TODO: - 存储图片
            }
            
        default:
            break
        }
        
        let newDiscoverFeed = DiscoverFeed()
        
        newDiscoverFeed.creator = currentAVUser
        newDiscoverFeed.allowComment = true
        newDiscoverFeed.categoryString = category.rawValue
        newDiscoverFeed.attachment = feedAttachment
        newDiscoverFeed.distance = 0
        newDiscoverFeed.messagesCount = 0
        newDiscoverFeed.body = message
        newDiscoverFeed.highlightedKeywordsBody = ""
        
        return newDiscoverFeed
        
    }
    
    @IBAction func post(_ sender: Any) {
        post(again: false)
    }
    
    
     func post(again: Bool) {
        
        let messageLength = messageTextView.text.characters.count
        
        guard messageLength <= 300 else {
            CubeAlert.alertSorry(message: "发表的内容太长喽, 建议在 300 个字以内.", inViewController: self)
            return
        }
    
        if !again {
            uploadState = .uploading
            
            if let feed = tryMakeUploadingFeed() {
                
                if feed.category.needBackgroundUpload {
                    beforUploadingFeedAction?(feed, self)
                    CubeHUD.hideActivityIndicator()
                    dismiss(animated: true, completion: nil)
                }
            }
        }
        
        let message = messageTextView.text.trimming(trimmingType: .whitespaceAndNewLine)
        
        var category: FeedCategory = .text
        var attachments: JSONDictionary?
        
        let tryCreateFeed: (_ withFormula: DiscoverFormula?) -> Void = {
            [weak self] formula in
            
            var openGraph: OpenGraph?
            
            let doCreateFeed: () -> Void = {
                [weak self] in
                
                if let openGraph = openGraph, openGraph.isValid {
                   
                    category = .url
                    
                    let URLInfo: JSONDictionary = [
                        "url": openGraph.URL.absoluteString,
                        "siteName": (openGraph.siteName ?? "").truncateForFeed,
                        "title": (openGraph.title ?? "").truncateForFeed,
                        "description": (openGraph.description ?? "").truncateForFeed,
                        "image_url": openGraph.previewImageURLString ?? "",
                    ]
                    
                    attachments = URLInfo 
                }
                
                createFeedWithCategory(category, message: message, attachments: attachments, withFormula: formula, coordinate: nil, allowComment: true, failureHandler: { reason, errorMessage in
                    
                    defaultFailureHandler(reason, errorMessage)
                    
                    let message = errorMessage ?? "创建 Feed 失败"
                    self?.uploadState = .failed(message: message)
                    
                }, completion: { newFeed in
                    
                    self?.afterUploadingFeedAction?(newFeed)
                    
                    CubeHUD.hideActivityIndicator()
                    
                    NotificationCenter.default.post(name: Config.NotificationName.createdFeed, object: newFeed)
                    
                    if !category.needBackgroundUpload {
                        self?.dismiss(animated: true, completion: nil)
                    }
                    
//                    syncGroupsAndDoFurtherAction {}
                    
                })
            }
            
            
            guard category.needParseOpenGraph,
                let firstURL = message.opengraph_embeddedURLs.first else {
                doCreateFeed()
                return
            }
            
            let parseOpenGraphGroup = DispatchGroup()
            
            parseOpenGraphGroup.enter()
            
            
            openGraphWithURL(firstURL, failureHandler: {
                reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
                
                parseOpenGraphGroup.leave()
                
            }, completion: { _openGraph in
                
                openGraph = _openGraph
                
                parseOpenGraphGroup.leave()
            })
            
            
            parseOpenGraphGroup.notify(queue: DispatchQueue.main, execute: {
                
                doCreateFeed()
            })
            
        }
        
        switch attachment {
            
        case .normal:
            
            let mediaImagesCount = mediaImages.count
            
            var imagesData = [Data]()
            
            for image in mediaImages {
                
                let imageWidth = image.size.width
                let imageHeight = image.size.height
                
                let fixedImageWidth: CGFloat
                let fixedImageHeight: CGFloat
                
                if imageWidth > imageHeight {
                    fixedImageWidth = min(imageWidth, Config.Media.imageWidth)
                    fixedImageHeight = imageHeight * (fixedImageWidth / imageWidth)
                } else {
                    fixedImageHeight = min(imageHeight, Config.Media.imageHeight)
                    fixedImageWidth = imageWidth * (fixedImageHeight / imageHeight)
                }
                
                let fixedSize = CGSize(width: fixedImageWidth, height: fixedImageHeight)
                
                if let image = image.resizeTo(targetSize: fixedSize, quality: CGInterpolationQuality.high), let imageData = UIImageJPEGRepresentation(image, 0.95) {
                    
                    imagesData.append(imageData)
                    
                }
            }
            
            guard imagesData.count == mediaImagesCount else {
                defaultFailureHandler(Reason.network(nil), "创建图片失败")
                self.uploadState = .failed(message: "图片数据准备失败")
                break
            }
            
            pushDatasToLeancloud(with: imagesData, failureHandler: {
                reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
                self.uploadState = .failed(message: "图片数据上传失败")
                
            }, completion: { [weak self] URLs in
                
                guard let URLs = URLs else {
                    tryCreateFeed(nil)
                    return
                }
                
                if !URLs.isEmpty {
                    let imagesInfos: JSONDictionary = ["urls": URLs as AnyObject]
                    
                    attachments = imagesInfos
                    category = .image
                    
                }
                
                tryCreateFeed(nil)
                
                if let strongSelf = self {
                    
                   let bigger = (strongSelf.mediaImages.count == 1)
                    
                    for i in 0..<strongSelf.mediaImages.count {
                        
                        let image = strongSelf.mediaImages[i]
                        let URLString = URLs[i]
                        
                        let sideLength: CGFloat
                        if bigger {
                            sideLength = Config.FeedBiggerImageCell.imageSize.width
                        } else {
                            sideLength = Config.FeedAnyImagesCell.imageSize.width
                        }
                        
                        let scaledKey = CubeImageCache.attachmentSideLengthKeyWithURLString(URLString: URLString, sideLenght: sideLength)
                        let scaledImage = image.scaleToSideLenght(sidLenght: sideLength)
                        let scaledData = UIImageJPEGRepresentation(image, 1.0)
                        
                        ImageCache.default.store(scaledImage, original: scaledData, forKey: scaledKey, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: true, completionHandler: nil)
                        
                        let originalKey = CubeImageCache.attachmentOriginKeyWithURLString(URLString: URLString)
                        let originalData = UIImageJPEGRepresentation(image, 1.0)
                        
                        ImageCache.default.store(image, original: originalData, forKey: originalKey, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: true, completionHandler: nil)
                    }
                    
                }
            })
      
        case .formula:
            
            // 这个公式信息已经被本地 Realm 存储. 直接创建新实例
            guard let attachmentFormula = attachmentFormula else {
                break
            }
            
            pushFeedFormulaAttachmentToLeancloud(with: attachmentFormula, failureHandler: {
                
                reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
                
                self.uploadState = .failed(message: "上传公式失败")

            }, completion: { newDiscoverFormula in
                
                category = .formula
                tryCreateFeed(newDiscoverFormula)
                
            })
           
            
        default:
            break
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        if let formula = attachmentFormula {
            cancelCreatedFormulaFeed?(formula)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -  Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPickPhotoView" {
            
            if let vc = segue.destination as? PickPhotosViewController {
                vc.delegate = self
                vc.pickedImageSet = Set(pickedImageAssets)
//                vc.pickedImages = pickedImageAssets
                vc.imageLimit = mediaImages.count
            }
        }
    }
    
}

extension NewFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case image = 0
        case add
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .add:
            return 1
        case .image:
            return mediaImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .image:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedMediaCellIdentifier, for: indexPath) as! FeedMediaCell
            
            cell.configureWithImage(image: mediaImages[indexPath.row])
            
            cell.delete = {
                [unowned self] in
                self.mediaImages.remove(at: indexPath.row)
            }
            
            return cell
            
            
        case .add:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedMediaAdddCellIdentifier, for: indexPath) as! FeedMediaAddCell
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .image:
            return CGSize(width: 80, height: 80)
        case .add:
            guard mediaImages.count != 4 else {
                return CGSize.zero
            }
            return CGSize(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        guard let window = view.window else {
            return
        }
        
        switch section {
        case .image:
            
            let cell = collectionView.cellForItem(at: indexPath) as! FeedMediaCell
            
            let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewController(withIdentifier: "MediaPreviewViewController") as! MediaPreviewViewController
            
            let startIndex = indexPath.item
            let frame = cell.imageView.convert(cell.imageView.bounds, to: self.view)
            vc.previewImageViewInitalFrame = frame
            vc.bottomPreviewImage = mediaImages[startIndex]
            vc.startIndex = startIndex
            delay(0) {
                //                    transitionView.alpha = 0
            }
            
            vc.afterDismissAction = { [weak self] in
                
                //                    transitionView.alpha = 1
                self?.view.window?.makeKeyAndVisible()
            }
            
            vc.previewMedias = mediaImages.map { PreviewMedia.localImage($0) }
            
            mediaPreviewWindow.rootViewController = vc
            mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
            mediaPreviewWindow.makeKeyAndVisible()
            
        case .add:
            
            messageTextView.resignFirstResponder()
            
            if mediaImages.count == 4 {
                CubeAlert.alertSorry(message: "最多只能添加四张图片", inViewController: self)
                return
            }
            
            let sheetView = ActionSheetView(items: [
                
                .Option(title: "拍摄", titleColor: UIColor.cubeTintColor(), action: {
                    [weak self] in
                    
                    guard
                        let strongSelf = self,
                        UIImagePickerController.isSourceTypeAvailable(.camera) else {
                            self?.alertCanNotOpenCamera()
                            return
                    }
                    
                
                    DispatchQueue.main.async {
                        
                        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
                            
                            strongSelf.modalPresentationStyle = .currentContext
                            strongSelf.imagePicker.sourceType = .camera
                            
                            /*
                             bug :  Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
                             http://cocoadocs.org/docsets/DKCamera/1.2.9/index.html
                             可以选择使用这个开源项目解决问题
                             
                             */
                            delay(0.3) {
                                strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                            }
                        } else {
                            
                            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
                                success in
                                
                                if success {
                                    delay(0.3) {
                                        strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                                    }
                    
                                }
                
                            })
                            //strongSelf.alertCanNotOpenCamera()
                        }
                        
                    }
                    
                    
                }),
                
                .Option(title: "相册", titleColor: UIColor.cubeTintColor(), action: {
                    [weak self] in
                    
                    guard
                        let strongSelf = self,
                        UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                        self?.alertCanNotOpenPhotoLibrary()
                        return
                    }
                    
                    //这个方法是在其他线程执行的
                    PHPhotoLibrary.requestAuthorization { authorization in
                        if authorization ==  PHAuthorizationStatus.authorized {
                            
                            DispatchQueue.main.async {
                                
                                strongSelf.performSegue(withIdentifier: "ShowPickPhotoView", sender: nil)
                            }
                            
                        } else {
                            strongSelf.alertCanNotOpenPhotoLibrary()
                            
                        }
                    }
                    
                    }),
                
                .Cancel
                
                ])
            
            
            sheetView.showInView(view: window)
            
            
        }
        
    }
}

extension NewFeedViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if !isReadyForPost {
            textView.text = ""
        }
        
        isNeverInputMessage = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        isReadyForPost = textView.text.characters.count > 0
    }
}

extension NewFeedViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
    }
}

extension NewFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            switch mediaType {
            case String(kUTTypeImage):
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    if mediaImages.count <= 3 {
                        mediaImages.append(image)
                    }
                }
                
            default:
                break
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension NewFeedViewController: ReturnPickedPhotosDelegate {
    
    func returnSeletedImages(_ images: [UIImage], imageAssets: [PHAsset]) {
        
        for image in images {
            mediaImages.append(image)
        }
        
    }
}















