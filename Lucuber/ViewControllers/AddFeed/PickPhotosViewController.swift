//
//  PickPhotosViewController.swift
//  Lucuber
//
//  Created by Howard on 7/24/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import Photos

private let PhotoCellIdentifier = "PhotoCell"

protocol ReturnPickedPhotosDelegate: class {
    func returnSeletedImages(images: [UIImage], imageAssets: [PHAsset])
}

class PickPhotosViewController: UICollectionViewController {

    var images: PHFetchResult? {
        didSet {
            collectionView?.reloadData()
            guard let images = images else { return }
            
            collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: images.count - 1, inSection: 0), atScrollPosition: .CenteredVertically, animated: false)
        }
    }
    
    weak var delegate: ReturnPickedPhotosDelegate?
    var imageManager = PHCachingImageManager()
    
    var pickedImageAssets = [PHAsset]()

    var imageLimit = 0
    
    deinit {
        print(self, "死了")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "选取图片" + "(" + "\(pickedImageAssets.count)" + "/4" + ")"
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let width: CGFloat = (screenWidth - 5) / 4
            layout.itemSize = CGSize(width: width, height: width)
            
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 64, left: 1, bottom: 1, right: 1)
            
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: self, action: #selector(PickPhotosViewController.back(_:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PickPhotosViewController.done(_:)))
        
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true)]
        images = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)

    }
    
    func back(sender: UIBarButtonItem) {
       
    }

  
    
    func done(sender: UIBarButtonItem)  {
        
        var images = [UIImage]()
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        options.networkAccessAllowed = true
        
        for imageAsset in pickedImageAssets {
            
            let maxSize: CGFloat = 1024
            
            let pixelWidth = CGFloat(imageAsset.pixelWidth)
            let pixelHeight = CGFloat(imageAsset.pixelHeight)
            
            let targetSize: CGSize
            
            if pixelHeight > pixelWidth {
                let width = maxSize
                let height = floor(maxSize * (pixelHeight / pixelWidth))
                targetSize = CGSize(width: width, height: height)
            } else {
                let height = maxSize
                let width = floor(maxSize * (pixelWidth / pixelHeight))
                targetSize = CGSize(width: width, height: height)
            }
            
            
            imageManager.requestImageDataForAsset(imageAsset, options: options, resultHandler: { (data, string, imageOrientation, _) in
                if let data = data, let image = UIImage(data: data) {
                    
                    let newRect = CGRect(origin: CGPointZero, size: targetSize)
                    
                    let bitmapContext = CGBitmapContextCreate(nil, Int(newRect.width),  Int(newRect.height), CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage).rawValue)
                    
                    CGContextConcatCTM(bitmapContext, CGAffineTransformIdentity)
                    
                    CGContextSetInterpolationQuality(bitmapContext, CGInterpolationQuality.Medium)
                    CGContextDrawImage(bitmapContext, newRect, image.CGImage)
                    
                    if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
                        let newImage = UIImage(CGImage: newCGImage)
                        print(newImage)
                        
                        images.append(newImage)
                    }
                    
                }
            })
            
            
        }
        
        delegate?.returnSeletedImages(images, imageAssets: pickedImageAssets)
        navigationController?.popViewControllerAnimated(true)
        
       
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier, forIndexPath: indexPath)
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PhotoCell {
            cell.imageManager = imageManager
            
            if let imageAsset = images?[indexPath.row] as? PHAsset {
                cell.imageAsset = imageAsset
                cell.pickedImageView.hidden = !pickedImageAssets.contains(imageAsset)
            }
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let imageAsset = images?[indexPath.row] as? PHAsset {
            if pickedImageAssets.contains(imageAsset) {
                if let index = pickedImageAssets.indexOf(imageAsset) {
                    pickedImageAssets.removeAtIndex(index)
                }
            } else {
                if pickedImageAssets.count >= 4 {
                    return
                }
                if !pickedImageAssets.contains(imageAsset) {
                    pickedImageAssets.append(imageAsset)
                }
            }
            
            title = "选取图片" + "(" + "\(pickedImageAssets.count)" + "/4" + ")"
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            cell.pickedImageView.hidden = !pickedImageAssets.contains(imageAsset)
            
        }
    }

}
