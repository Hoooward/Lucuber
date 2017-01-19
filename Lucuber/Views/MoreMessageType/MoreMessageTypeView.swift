//
//  MoreMessageTypeView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/11.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Photos

class MoreMessageTypeView: UIView {
    
    let totalHeight: CGFloat = 100 + 60 * 3
    
    fileprivate var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
     fileprivate let titleCellIdentifier = "TitleCell"
     fileprivate let pickPhotosCellIdentifier = "PickPhotosCell"
    
     fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.isScrollEnabled = false
        
        tableView.register(UINib(nibName: self.titleCellIdentifier, bundle: nil), forCellReuseIdentifier: self.titleCellIdentifier)
        tableView.register(UINib(nibName: self.pickPhotosCellIdentifier, bundle: nil), forCellReuseIdentifier: self.pickPhotosCellIdentifier)
        
        return tableView
    }()
    
    public var alertCanNotAccessPhotoLibraryAction: (() -> Void)?
    public var takePhotoAction: (() -> Void)?
    public var choosePhotoAction: (() -> Void)?
    public var sendImageAction: ((UIImage) -> Void)?
    public var pickLocationAction: (() -> Void)?
    
    var pickedImageSet = Set<PHAsset>() {
        didSet {
            let indexPath = IndexPath(item: Row.photoLibrary.rawValue, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    fileprivate var tableViewBottomConstraint: NSLayoutConstraint?
    
    public func show(in view: UIView) {
        
        frame = view.bounds
        view.addSubview(self)
        
        layoutIfNeeded()
        
        containerView.alpha = 1
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
            
            self.tableViewBottomConstraint?.constant = 0
            self.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    public func hide() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            self.tableViewBottomConstraint?.constant = self.totalHeight
            self.layoutIfNeeded()
            
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
            
            self.containerView.backgroundColor = UIColor.clear
            
        }, completion: { _ in
            
            self.removeFromSuperview()
        })
    }
    
    public func hideAndDo(action: (() -> Void)?) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            
            self.containerView.alpha = 0
            self.tableViewBottomConstraint?.constant = self.totalHeight
            self.layoutIfNeeded()
            
        }, completion: { _ in
            
            self.removeFromSuperview()
        })
        
        delay(0.1) {
            action?()
        }
    }
    
    fileprivate var isFirstShow: Bool = true
   
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if isFirstShow {
            isFirstShow = false
            
            makeUI()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(MoreMessageTypeView.hide))
            containerView.addGestureRecognizer(tap)
            
            tap.cancelsTouchesInView = true
            tap.delegate = self
        }
    }
    
    private func makeUI() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = [
            "tableView": tableView,
            "containerView": containerView
        ]
        
        do {
            
            let containerViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views)
            let containerViewY = NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(containerViewH)
            NSLayoutConstraint.activate(containerViewY)
        }
        
        do {
            
            let tableViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views)
            
            let tableViewBottom = NSLayoutConstraint.init(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: self.totalHeight)
            
            self.tableViewBottomConstraint = tableViewBottom
            
            let tableViewHeight = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.totalHeight)
            
            NSLayoutConstraint.activate(tableViewH)
            NSLayoutConstraint.activate([tableViewBottom, tableViewHeight])
        }
    }
}

extension MoreMessageTypeView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view != containerView {
            return false
        }
        return true
    }
}

extension MoreMessageTypeView: UITableViewDelegate, UITableViewDataSource {
    
    enum Row: Int {
        case pickPhoto = 0
        case photoLibrary
//        case location
        case cancel
        
        var title: String {
            switch self {
            case .pickPhoto: return ""
            case .photoLibrary: return "相册"
//            case .location: return "位置"
            case .cancel: return "取消"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let row = Row(rawValue: indexPath.row) else {
            fatalError()
        }

        switch row {

        case .pickPhoto:

            let cell = tableView.dequeueReusableCell(withIdentifier: pickPhotosCellIdentifier, for: indexPath) as! PickPhotosCell

            cell.alertCanNotAccessPhotoLibraryAction = { [weak self] in
                self?.alertCanNotAccessPhotoLibraryAction?()
            }

            cell.takePhotoAction = { [weak self] in
                self?.hideAndDo(action: {
                    self?.takePhotoAction?()
                })
            }

            cell.pickedPhotosAction = { [weak self] pickedImageSet in

                self?.pickedImageSet = pickedImageSet

            }

            return cell

        default:

            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellIdentifier, for: indexPath) as! TitleCell

            cell.nameLabel.text = row.title
            cell.nameLabel.textColor = UIColor.cubeTintColor()

            if case .photoLibrary = row {

                if !pickedImageSet.isEmpty {
                    cell.nameLabel.text = "发送照片: \(pickedImageSet.count)"
                }
            }

            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let row = Row(rawValue: indexPath.row) else {
            return 0
        }

        if case .pickPhoto = row {
            return 100
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let row = Row(rawValue: indexPath.row) else {
            fatalError()
        }

        switch row {

        case .photoLibrary:

            if !pickedImageSet.isEmpty {

                var images = [UIImage]()

                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.version = .current
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true

                let imageManager = PHCachingImageManager()

                for imageAsset in pickedImageSet {

                    let maxSize: CGFloat = 1024

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
                       data, string, imageOrientation, _ in

                        if let data = data, let image = UIImage(data: data) {
                            if let image = image.resizeTo(targetSize: targetSize, quality: .medium) {
                                images.append(image)
                            }
                        }
                    })
                }

                for (index, image) in images.enumerated() {
                    delay(0.1 * Double(index)) { [weak self] in
                        self?.sendImageAction?(image)
                    }
                }

                pickedImageSet.removeAll()

                hideAndDo(action: {

                    let indexPath = IndexPath(row: Row.pickPhoto.rawValue, section: 0)
                    if let cell = tableView.cellForRow(at: indexPath) as? PickPhotosCell {
                        cell.pickedImageSet.removeAll()
                        cell.photosCollectionView.reloadData()
                    }

                })
            } else {

                hideAndDo(action: { [weak self] in
                    self?.choosePhotoAction?()
                })
            }

//        case .location:
//            hideAndDo(action: { [weak self] in
//                self?.pickLocationAction?()
//            })

        case .cancel:
            hide()

        default:
            break
        }
    }


}































