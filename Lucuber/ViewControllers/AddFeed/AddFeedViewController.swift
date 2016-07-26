//
//  AddFeedViewController.swift
//  Lucuber
//
//  Created by Howard on 7/23/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary
import Photos
import Ruler

class AddFeedViewController: UIViewController {

    // MARK: - Properties
    enum Attachment {
        case Media
        case Formula
    }
    
    var attachment: Attachment = .Media
    var mediaImages = [UIImage]() {
        didSet {
            
            mediaCollectionView.performBatchUpdates({ [weak self] in
                self?.mediaCollectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: nil)
        }
    }
    
    private var pickedImageAssets = [PHAsset]()
    
    var newFeed = Feed()
    
    private var isNeverInputMessage = true
    private var isReadyForPost = false {
        willSet {
            postFeedBarButton.enabled = newValue
            
            if !newValue && isNeverInputMessage {
                messageTextView.text = placeholderOfMessage
            }
            
            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    @IBOutlet weak var formulaView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var postFeedBarButton: UIBarButtonItem!
    
    private let placeholderOfMessage = "写点什么..."
    private let FeedMediaAddCellIdentifier = "FeedMediaAddCell"
    private let FeedMediaCellIdentifier = "FeedMediaCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
  
    }
    
    deinit {
        print(self, "死了")
    }
    
    func makeUI() {
        
        switch attachment {
        case .Media:
            title = "新话题"
            mediaCollectionView.hidden = false
            formulaView.hidden = true
            
        case .Formula:
            title = "新公式"
            
            mediaCollectionView.hidden = true
            formulaView.hidden = false
        }
        
        view.backgroundColor = UIColor.cubeBackgroundColor()
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        
        let messageTextViewHeight = Ruler.iPhoneVertical(100, 120, 170, 200).value
        messageTextViewHeightConstraint.constant = CGFloat(messageTextViewHeight)
        messageTextView.layoutIfNeeded()
        
        
        isReadyForPost = false
        messageTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.delegate = self
        messageTextView.tintColor = UIColor.cubeTintColor()
        
      
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    // MARK: - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPickPhotoView" {
            if let vc = segue.destinationViewController as? PickPhotosViewController {
              vc.delegate = self
              vc.pickedImageSet = Set(pickedImageAssets)
              vc.imageLimit = mediaImages.count
                
            }
        }
    }
    
 
    // MARK: - Targer & Notification
    @IBAction func postFeed(sender: AnyObject) {
        
        messageTextView.resignFirstResponder()
        
        if let user = AVUser.currentUser() {
            // 已经登录
            
            var photoUrls = [String]()
            if mediaImages.count > 0 {
                for image in mediaImages {
                    let uploadFile = AVFile(data: UIImageJPEGRepresentation(image, 0.7))
                 
                    var error: NSError?
                    if uploadFile.save(&error) {
                        if let url = uploadFile.url {
                            photoUrls.append(url)
                        }
                    } else {
                        print("图片上传失败", error?.localizedFailureReason)
                    }
                }
            }
            
            let newFeed = Feed()
            newFeed.contentBody = messageTextView.text
            newFeed.creator = user
            newFeed.imagesUrl = photoUrls
            newFeed.kind = "text"
            newFeed.category = FeedCategory.Topic.rawValue
            
            var error: NSError?
            
            if newFeed.save(&error) {
                print("发表成功")
            } else {
                print("发表失败", error?.localizedFailureReason)
            }
            
            
            
            dismissViewControllerAnimated(true, completion: nil)
            
            
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - CollectionViewDelegate & DataSource -> MediaCell
extension AddFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case Image = 0
        case Add
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .Image:
            return mediaImages.count
        case .Add:
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Image:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FeedMediaCellIdentifier, forIndexPath: indexPath) as! FeedMediaCell
            
            cell.configureWithImage(mediaImages[indexPath.row])
            
            cell.delete = {
                [unowned self] in
                self.mediaImages.removeAtIndex(indexPath.row)
            }
            
            return cell
        case .Add:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FeedMediaAddCellIdentifier, forIndexPath: indexPath) as! FeedMediaAddCell
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Image:
            return CGSize(width: 80, height: 80)
        case .Add:
            guard mediaImages.count != 4 else {
                return CGSizeZero
            }
            return CGSize(width: 80, height: 80)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }

        
        switch section {
        case .Image:
            break
        case .Add:
            
            messageTextView.resignFirstResponder()
            
            if mediaImages.count == 4 {
                CubeAlert.alertSorry(message: "最多只能添加四张图片", inViewController: self)
                return
            }
            
            let sheetView = ActionSheetView(items: [
                
                .Option(title: "拍摄", titleColor: UIColor.cubeTintColor(), action: { [weak self] in
                    
                    guard let strongSelf = self where UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                        self?.alertCanNotOpenCamera()
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == AVAuthorizationStatus.Authorized {
                            
                            strongSelf.modalPresentationStyle = .CurrentContext
                            strongSelf.imagePicker.sourceType = .Camera
                            
                            /*
                             bug :  Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
                             http://cocoadocs.org/docsets/DKCamera/1.2.9/index.html
                             可以选择使用这个开源项目解决问题
                             
                             */
                            delay(0.3) {
                                strongSelf.presentViewController(strongSelf.imagePicker, animated: true, completion: nil)
                            }
                            
                        } else {
                            strongSelf.alertCanNotOpenCamera()
                        }
                    }
                    
                    }
                ),
                
                .Option(title: "相册", titleColor: UIColor.cubeTintColor(), action: { [weak self] in
                    
                    guard let strongSelf = self where UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                        self?.alertCanNotOpenPhotoLibrary()
                        return
                    }
                    
                    //这个方法是在其他线程执行的
                    PHPhotoLibrary.requestAuthorization { authorization in
                        if authorization ==  PHAuthorizationStatus.Authorized {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                strongSelf.performSegueWithIdentifier("ShowPickPhotoView", sender: nil)
                            }
                            
                        } else {
                            strongSelf.alertCanNotOpenPhotoLibrary()
                            
                        }
                    }
                    }
                ),
                
                .Cancel
                
                ]
            )
            
            if let window = view.window {
                sheetView.showInView(window)
            }
        }
    }
    
}

// MARK: - ScrollerViewDelegate

extension AddFeedViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        if !isReadyForPost {
            textView.text = ""
        }
        
        isNeverInputMessage = false
    }
    
    func textViewDidChange(textView: UITextView) {
        print(textView.text.characters.count)
        isReadyForPost = textView.text.characters.count > 0
    }
}

// MARK: - ScrollerViewDelegate

extension AddFeedViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
        
    }
}

// MARK: - ImagePickerDelegate
extension AddFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
   
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
        
        dismissViewControllerAnimated(true, completion: nil)
    }
   
}

extension AddFeedViewController: ReturnPickedPhotosDelegate {
    func returnSeletedImages(images: [UIImage], imageAssets: [PHAsset]) {
        
        for image in images {
            mediaImages.append(image)
        }
    }
}







