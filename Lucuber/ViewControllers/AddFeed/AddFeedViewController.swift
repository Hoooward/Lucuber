//
//  AddFeedViewController.swift
//  Lucuber
//
//  Created by Howard on 7/23/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {

    // MARK: - Properties
    enum Attachment {
        case Default
        case Formula
    }
    
    var attachment: Attachment = .Default
    
    var mediaImages = [UIImage]()
    
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            
        }
    }
    
    private lazy var imagePickView: UIImagePickerController = {
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.cubeBackgroundColor()
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.showsHorizontalScrollIndicator = false

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
            guard mediaImages.count != 4 else {
                return CGSizeZero
            }
            return CGSize(width: 80, height: 80)
        case .Add:
            return CGSize(width: 80, height: 80)
        }
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
                
                .Option(title: "拍摄", titleColor: UIColor.cubeTintColor(), action: {
                    
                    
                    
                    
                    }
                ),
                .Cancel
                
                ]
            )
        }
    }
    
}
// MARK: - ImagePickerDelegate
extension AddFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
}








