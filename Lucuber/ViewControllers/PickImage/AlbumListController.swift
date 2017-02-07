//
//  AlbumListController.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Photos

final class Album: NSObject {
    var results: PHFetchResult<PHAsset>?
    var count = 0
    var name: String?
    var startDate: Date?
    var identifier: String?
}

fileprivate let defaultAlbumIdentifier = "com.Lucuber.photoPicker"

final class AlbumListController: UITableViewController {
    
    var pickedImageSet = Set<PHAsset>()
    var pickedImages = [PHAsset]()
    var completion: ((_ images: [UIImage], _ imageAssets: [PHAsset]) -> Void)?
    
    var imageLimit = 0
    
    let albumlistCellIdentifier = "AlbumListCell"
    
    var assetsCollection: [Album]?
    
    lazy var pickPhotoVC: PickPhotosViewController = {
        let vc = UIStoryboard(name: "NewFeed", bundle: nil).instantiateViewController(withIdentifier: "PickPhotosViewController") as! PickPhotosViewController
        return vc
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(AlbumListController.cancel(sender:)))
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: albumlistCellIdentifier, bundle: nil), forCellReuseIdentifier: albumlistCellIdentifier)
        tableView.tableFooterView = UIView()
        
        assetsCollection = fetchAlbumList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    @objc private func cancel(sender: UIBarButtonItem) {
        
        /*
        if let vcStack = navigationController?.viewControllers {
            var destVC: UIViewController?
            for vc in vcStack {
                if vc.isKind(of: NewFeedViewController.self) {
                    destVC = vc
                    break
                }
            }
            if let destVC = destVC {
                let _ = navigationController?.popToViewController(destVC, animated: true)
            }
        }
         */
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func  fetchAlbumIdentifier() -> String? {
        let string = UserDefaults.standard.object(forKey: defaultAlbumIdentifier) as? String
        return string
    }
    
    func fechAlbum() -> Album {
        
        let album = Album()
        let identifier = fetchAlbumIdentifier()
        guard identifier != nil else {
            return album
        }
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let result = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: .any, options: nil)
        if result.count <= 0 {
            return album
        }
        
        let collection = result.firstObject
        let requestResult = PHAsset.fetchAssets(in: collection!, options: options)
        
        album.count = requestResult.count
        album.name = collection?.localizedTitle
        album.results = requestResult
        album.startDate = collection?.startDate
        album.identifier = collection?.localIdentifier
        return album
        
    }
    
    func fetchAlbumList() -> [Album]? {
        
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        var results = [PHFetchResult<PHAssetCollection>]()
        
        results.append(PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: .albumRegular, options: nil) )
        
        results.append(PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: .any, options: userAlbumsOptions) )
        
        var list: [Album] = []
        guard !results.isEmpty else {
            return nil
        }
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        for (_, result) in results.enumerated() {
            
            result.enumerateObjects({
                album, index, stop in
                
                guard album.localizedTitle != "最近删除" else {
                    return
                }
                
                let assetResults = PHAsset.fetchAssets(in: album, options: options)
                
                var count = 0
                switch album.assetCollectionType {
                    
                case .album:
                    count = assetResults.count
                    
                case .smartAlbum:
                    count = assetResults.count
                    
                case .moment:
                    count = 0
                }
                
                if count > 0 {
                    
                    autoreleasepool(invoking: {
                        
                        let ab = Album()
                        ab.count = count
                        ab.results = assetResults
                        ab.name = album.localizedTitle
                        ab.startDate = album.startDate
                        ab.identifier = album.localIdentifier
                        list.append(ab)
                        
                    })
                }
            })
        }
        
        return list
    }
    
    func fetchImageWithAsset(asset: PHAsset?, targetSize: CGSize, imageResultHandler: @escaping (_ image: UIImage?) -> Void) -> PHImageRequestID? {
        
        guard let asset = asset else {
            return nil
        }
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        
        let scale = UIScreen.main.scale
        
        let size = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        
        return PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (result, info) in
            
            imageResultHandler(result)
        })
    }
}

// MARK: - TableView Delegate & DataSource
extension AlbumListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetsCollection == nil ? 0 : assetsCollection!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: albumlistCellIdentifier, for: indexPath) as! AlbumListCell
        
        if let album = assetsCollection?[indexPath.row] {
            
            cell.countLabel.text = "\(album.count)"
            cell.titleLabel.text = album.name
            let _ = fetchImageWithAsset(asset: album.results?.lastObject, targetSize: CGSize(width: 60, height: 60), imageResultHandler: { (image) in
                cell.posterImageView.image = image
            })
        
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let album = assetsCollection?[indexPath.row] else {
            return
        }
        
        pickPhotoVC.imagesDidFetch = true
        pickPhotoVC.pickedImages = pickedImages
        pickPhotoVC.pickedImageSet = Set(pickedImages)
        pickPhotoVC.imageLimit = imageLimit
        pickPhotoVC.images = album.results
        
        pickPhotoVC.delegate = self
        
        navigationController?.pushViewController(pickPhotoVC, animated: true)
    }
}

extension AlbumListController: ReturnPickedPhotosDelegate {
    func returnSeletedImages(_ images: [UIImage], imageAssets: [PHAsset]) {
        pickedImages.append(contentsOf: imageAssets)
    }
}
