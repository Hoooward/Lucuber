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

class AddFeedViewController: UIViewController {

    // MARK: - Properties
    enum Attachment {
        case Default
        case Formula
    }
    
    var attachment: Attachment = .Default {
        didSet {
            switch attachment {
            case .Default:
                title = "新话题"
            case .Formula:
                title = "新公式"
            }
        }
    }
    
    var mediaImages = [UIImage]() {
        didSet {
            mediaCollectionView.reloadData()
        }
    }
    
    private var pickedImageAssets = [PHAsset]()
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            
        }
    }
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private let FeedMediaAddCellIdentifier = "FeedMediaAddCell"
    private let FeedMediaCellIdentifier = "FeedMediaCell"
    
    @IBOutlet weak var postFeedBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        
        title = "新话题"
        
        view.backgroundColor = UIColor.cubeBackgroundColor()
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    deinit {
        print(self, "死了")
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







