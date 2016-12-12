//
//  PickPhotosCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/11.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Photos
import Proposer

class PickPhotosCell: UITableViewCell {

    @IBOutlet weak var photosCollectionView: UICollectionView!

    public var alertCanNotAccessCameraAction: (() -> Void)?
    public var takePhotoAction: (() -> Void)?
    public var pickedPhotosAction: ((Set<PHAsset>) -> Void)?
    
    var images: PHFetchResult<PHAsset>?
    let imageManager = PHCachingImageManager()
    
    
    var pickedImageSet = Set<PHAsset>() {
        didSet {
            pickedPhotosAction?(pickedImageSet)
        }
    }
    
    var completion: (([UIImage], Set<PHAsset>) -> Void)?
    
    fileprivate let cameraCellIdentifier = "CameraCell"
    fileprivate let photoCellIdentifier = "PhotoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        photosCollectionView.backgroundColor = UIColor.clear
        photosCollectionView.register(UINib(nibName: cameraCellIdentifier, bundle: nil), forCellWithReuseIdentifier: cameraCellIdentifier)
        photosCollectionView.register(UINib(nibName: photoCellIdentifier, bundle: nil), forCellWithReuseIdentifier: photoCellIdentifier)
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 70, height: 70)
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            
            photosCollectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
        
        proposeToAccess(.photos, agreed: {
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                let options = PHFetchOptions()
                options.sortDescriptors = [
                    NSSortDescriptor(key: "creationData", ascending: false)
                ]
                
                let images = PHAsset.fetchAssets(with: .image, options: options)
                
                strongSelf.images = images
                // TODO: - Manager
                
                strongSelf.photosCollectionView.reloadData()
                
                PHPhotoLibrary.shared().register(strongSelf as PHPhotoLibraryChangeObserver)
                
            }
            
        }, rejected: { [weak self] in
            self?.alertCanNotAccessCameraAction?()
        })
    }
}

extension PickPhotosCell: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        if let _images = images, let changeDetails = changeInstance.changeDetails(for: _images) {
           
            DispatchQueue.main.async { [weak self] in
                self?.images = changeDetails.fetchResultAfterChanges
                self?.photosCollectionView.reloadData()
            }
        }
    }
}

extension PickPhotosCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0: return 1
        case 1: return images?.count ?? 0
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraCellIdentifier, for: indexPath) as! CameraCell
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as!  PhotoCell
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? PhotoCell {
            cell.imageManager = imageManager
            
            if let imageAsset = images?[indexPath.item] {
                cell.imageAsset = imageAsset
                cell.pickedImageView.isHidden = !pickedImageSet.contains(imageAsset)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
            
        case 0:
            takePhotoAction?()
            
        case 1:
            
            if let imageAsset = images?[indexPath.item] {
                
                if pickedImageSet.contains(imageAsset) {
                    pickedImageSet.remove(imageAsset)
                } else {
                    pickedImageSet.insert(imageAsset)
                }
                
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
                
                cell.pickedImageView.isHidden = !pickedImageSet.contains(imageAsset)
            }
            
        default:
            break
        }
    }
    
}
















































