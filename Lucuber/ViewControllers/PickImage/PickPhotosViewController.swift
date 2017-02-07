//
//  PickPhotosViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Photos

private let photoCellIdentifier = "PhotoCell"

protocol ReturnPickedPhotosDelegate: class {
    
    func returnSeletedImages(_ images: [UIImage], imageAssets: [PHAsset])
}

class PickPhotosViewController: UICollectionViewController {

    /*
     参考: http://kayosite.com/ios-development-and-detail-of-photo-framework-part-two.html
     */
    
    var imagesDidFetch: Bool = false
    var album: AlbumListController?
    
    var imageManager = PHCachingImageManager()
    
    var images: PHFetchResult<PHAsset>? {
        didSet {
            collectionView?.reloadData()
            guard let images = images else { return }
            
            let indexPath = IndexPath(item: images.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
    
    weak var delegate: ReturnPickedPhotosDelegate?
    
    var pickedImages = [PHAsset]()
    var pickedImageSet = Set<PHAsset>()
    
    var imageLimit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选取图片" + "(" + "\(imageLimit + pickedImages.count )" + "/4" + ")"
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let width: CGFloat = (UIScreen.main.bounds.width - 5) / 4
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 64, left: 1, bottom: 1, right: 1)
            
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(PickPhotosViewController.back))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickPhotosViewController.done))

        if !imagesDidFetch {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            images = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        }
        
        guard var vcStack = navigationController?.viewControllers else { return }
        
        if !vcStack.isEmpty {
            if !(vcStack[1] is AlbumListController) {
                album = AlbumListController()
                vcStack.insert(self.album!, at: 1)
                navigationController?.setViewControllers(vcStack, animated: false)
            } else {
                album = vcStack[1] as? AlbumListController
            }
        }
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func back() {
        album?.imageLimit = imageLimit
        album?.pickedImages.append(contentsOf: pickedImages)
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc private func done() {
        
        var images = [UIImage]()
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        
        for imageAsset in pickedImages {
            
            let maxSize: CGFloat =  Config.NewFeedFullImage.maxSize
            
            let pixelWidth = CGFloat(imageAsset.pixelWidth)
            let pixelHeight = CGFloat(imageAsset.pixelHeight)
            
            let targetSize: CGSize
            
            if pixelWidth > pixelHeight {
                let width = maxSize
                let height = floor(maxSize * (pixelHeight / pixelWidth))
                targetSize = CGSize(width: width, height: height)
            } else {
                let height = maxSize
                let width = floor(maxSize * (pixelWidth / pixelHeight))
                targetSize = CGSize(width: width, height: height)
            }
            
            imageManager.requestImageData(for: imageAsset, options: options, resultHandler: {
                data, string, imgeProemtatopm, _ in
                
                if
                    let data = data,
                    let image = UIImage(data: data) {
                    
                    if let resizeImage = image.resizeTo(targetSize: targetSize, quality: CGInterpolationQuality.medium) {
                        images.append(resizeImage)
                    }
                }
            })
        }
        
        if let vcStack = navigationController?.viewControllers {
            weak var destVC: NewFeedViewController?
            for vc in vcStack {
                if vc is NewFeedViewController {
                    let vc = vc as! NewFeedViewController
                    destVC = vc
                    destVC?.returnSeletedImages(images, imageAssets: pickedImages)
                    break
                }
            }
            if let destVC = destVC {
                let _ = navigationController?.popToViewController(destVC, animated: true)
            }
        }
    }
}

// MARK: - CollectionView Delegate & DataScoure
extension PickPhotosViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? PhotoCell else { return }
        
        cell.imageManager = self.imageManager
        
        if let imageAsset = images?[indexPath.item]{
            cell.imageAsset = imageAsset
            cell.pickedImageView.isHidden = !pickedImageSet.contains(imageAsset)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageAsset = images?[indexPath.item]  {
            if pickedImageSet.contains(imageAsset) {
                pickedImageSet.remove(imageAsset)
                if let index = pickedImages.index(of: imageAsset) {
                    pickedImages.remove(at: index)
                }
            } else {
                if pickedImageSet.count + imageLimit == 4 {
                    return
                }
                if !pickedImageSet.contains(imageAsset) {
                    pickedImageSet.insert(imageAsset)
                    pickedImages.append(imageAsset)
                }
            }
            
            title = "选取图片" + "(" + "\(pickedImageSet.count + imageLimit )" + "/4" + ")"
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
                return
            }
            
            cell.pickedImageView.isHidden = !pickedImageSet.contains(imageAsset)
        }
    }
}
