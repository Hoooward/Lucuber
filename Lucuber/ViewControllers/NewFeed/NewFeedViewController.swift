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

class NewFeedViewController: UIViewController {
    
    enum Attachment {
        case media
        case formula
    }
    
    // MARK: - Properties
    
    var attachment: Attachment = .media
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
            
            postFeedBarButton.isEnabled = newValue
            
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
    
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFeedBarButton: UIBarButtonItem!
    
    fileprivate let placeholderOfMessage = "写点什么"
    fileprivate let feedMediaAdddCellIdentifier = "FeedMediaAddCell"
    fileprivate let feedMediaCellIdentifier = "FeedMediaCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
    
    private func makeUI() {
    
        switch attachment {
        case .media:
            
            title = "新话题"
            mediaCollectionView.isHidden = false
            
        case .formula:
            
            title = "创建公式(2/2)"
            mediaCollectionView.isHidden = true
            
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
    
    
    // MARK: -  Action & Target
    
    @IBAction func post(_ sender: Any) {
        printLog("post")
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
                            
                            strongSelf.alertCanNotOpenCamera()
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
        
//        printLog("images = \(mediaImages.count)")
//        mediaImages = images
//        pickedImageAssets.append(contentsOf: imageAssets)
//        printLog("imageAssets = \(pickedImageAssets.count)")
//        pickedImageAssets = imageAssets
//        printLog(imageAssets)
    }
}















