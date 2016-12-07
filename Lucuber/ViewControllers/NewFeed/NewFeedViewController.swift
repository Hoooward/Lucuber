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

class NewFeedViewController: UIViewController {
    
    enum Attachment {
        case normal
        case formula
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
                    
//                    FeedsViewController.handleError
                }
                
            case .success:
                CubeHUD.hideActivityIndicator()
                messageTextView.text = nil
            }
            
        }
        
    }
    
    // MARK: - Properties
    
    var attachment: Attachment = .normal
    
    var beforUploadingFeedAction: ((DiscoverFeed, NewFeedViewController) -> Void)?
    var afterUploadingFeedAction: ((DiscoverFeed) -> Void)?
    
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
    
    var newFeed = Feed()
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
        makeUI()
    }
    
    private func makeUI() {
    
        switch attachment {
        case .normal:
            
            title = "新话题"
            mediaCollectionView.isHidden = false
            formulaView.isHidden = true
            
        case .formula:
            
            title = "创建公式(2/2)"
            mediaCollectionView.isHidden = true
            formulaView.isHidden = false
            
        }
        
        view.backgroundColor = UIColor.cubeBackgroundColor()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        
        let messageTextViewHeight = CubeRuler.iPhoneVertical(100, 120, 170, 200).value
        messageTextViewHeightContraint.constant = CGFloat(messageTextViewHeight)
        messageTextView.layoutIfNeeded()
        
        isReadyForPvar = false
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
    
    
    // MARK: -  Action & Target
    
    func tryMakeUploadingFeed() -> DiscoverFeed? {
        
        guard let currentAVUser = AVUser.current(), let realm = try? Realm(), let currentRuser = currentUser(in: realm) else {
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
                        fixedImageWidth = min(imageWidth, Config.Media.miniImageWidth)
                        fixedImageHeight = imageHeight * (fixedImageWidth / imageWidth)
                    } else {
                        fixedImageHeight =  min(imageHeight, Config.Media.miniImageHeight)
                        fixedImageWidth = imageWidth * (fixedImageHeight / imageHeight)
                    }
                    
                    let fixedSize = CGSize(width: fixedImageWidth, height: fixedImageHeight)
                    
                    if let image = image.resizeTo(targetSize: fixedSize, quality: .medium) {
                        
                        let attachment = ImageAttachment(metadata: "", URLString: "", image: image)
                        imageAttachments.append(attachment)
                    }
                }
                
                if !imageAttachments.isEmpty {
                   feedAttachment = .images(imageAttachments)
                }
            }
            
            
            
        default:
            break
        }
        
        let newDiscoverFeed = DiscoverFeed()
        
        newDiscoverFeed.creator = currentAVUser
        newDiscoverFeed.localObjectID = Feed.randomLocalObjectID()
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
        printLog("post")
        post(again: false)
    }
    
    
    fileprivate func post(again: Bool) {
        
        let messageLength = messageTextView.text.characters.count
        
        guard messageLength <= 300 else {
            CubeAlert.alertSorry(message: "发表的内容太长喽, 建议在 300 个字以内.", inViewController: self)
            return
        }
    
        
        if !again {
            uploadState = .uploading
            
            if let feed = tryMakeUploadingFeed() {
                
                if feed.category.needBackgroundUpload {
                    
                    
                }
            }
            
            
            
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
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















