//
//  RegisterSelectCubeCategoryViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import pop

class RegisterSelectCubeCategoryViewController: UIViewController {

    public var selectCategoryAction: ((_ category: CubeCategoryMaster, _ selected: Bool) -> Bool)?
    public var pushNewUserInfoAction: (() -> Void)?
    
    var categoryIndex: Int = 0
    var categorys = [CubeCategoryMaster]()
    var seletedCategorys :[CubeCategoryMaster]? {
        
        didSet {
            guard let seletedCategorys = seletedCategorys else {
                return
            }
            var strings = Set<String>()
            seletedCategorys.forEach { strings.insert($0.categoryString) }
            self.seletedCategoryStrings = strings
        }
    }
    
    fileprivate var seletedCategoryStrings: Set<String> = []
    
    @IBOutlet weak var categoryCollectionView: UICollectionView! {
        didSet {
            categoryCollectionView.backgroundColor = UIColor.clear
            categoryCollectionView.registerNib(of: CategorySelectionCell.self)
            categoryCollectionView.registerHeaderNibOf(CategoryAnnotationHeader.self)
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitle("返回", for: .normal)
            backButton.alpha = 0
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle("完成", for: .normal)
            cancelButton.alpha = 1
            cancelButton.addTarget(self, action: #selector(RegisterSelectCubeCategoryViewController.cancel), for: .touchUpInside)
        }
    }
    
    lazy var collectionViewWidth: CGFloat = {
        return self.categoryCollectionView.bounds.width
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = view.bounds
        view.insertSubview(effectView, at: 0)
        
        let layout = self.categoryCollectionView.collectionViewLayout as! RegisterSelectCubeCategoryLayout
        let originLineSpacing = layout.minimumLineSpacing
        
        let initialMinimumLineSpacing: CGFloat = 20
        layout.minimumLineSpacing = initialMinimumLineSpacing
        
        let anim = POPBasicAnimation()
        anim.beginTime = CACurrentMediaTime() + 0.0
        anim.duration = 0.9
        anim.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        let prop = POPAnimatableProperty.property(withName: "minimumLineSpacing", initializer: { props in
            
            props?.readBlock = { obj, values in
                values?[0] = (obj as! RegisterSelectCubeCategoryLayout).minimumLineSpacing
            }
            props?.writeBlock = { obj, values in
                (obj as! RegisterSelectCubeCategoryLayout).minimumLineSpacing = (values?[0])!
            }
            
            props?.threshold = 0.1
            
        }) as! POPAnimatableProperty
        
        anim.property = prop
        anim.fromValue = initialMinimumLineSpacing
        anim.toValue = originLineSpacing
        
        delay(0.1, clouser: {
            layout.pop_add(anim, forKey: "AnimateLine")
            
        })
        
        if categorys.isEmpty {
            
            fetchCubeCategorys(failureHandler: { reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)
            }, completion: { [weak self] results in
                
                self?.categorys = results.map {
                    let cube = CubeCategoryMaster()
                    cube.atRUser = nil
                    cube.categoryString = $0.categoryString
                    return cube
                }
                
                self?.categoryCollectionView.collectionViewLayout.invalidateLayout()
                self?.categoryCollectionView.reloadData()
                self?.categoryCollectionView.layoutIfNeeded()
            })
        }
    }
  
    func cancel() {
        pushNewUserInfoAction?()
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterSelectCubeCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionElementKindSectionHeader {
            
            let header: CategoryAnnotationHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
            header.annotationLabel.text = "魔方类型"
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionViewWidth, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CategorySelectionCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let category = categorys[indexPath.item]
        cell.categoryLabel.text = category.categoryString
        
        
        if seletedCategoryStrings.contains(category.categoryString) {
            cell.categorySelection = .on
        } else {
            cell.categorySelection = .off
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let category = categorys[indexPath.item]
        
        let rect = (category.categoryString as NSString).boundingRect(with: CGSize(width: CGFloat(FLT_MAX), height: CategorySelectionCell.height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20)], context: nil)
        
        return CGSize(width: rect.width + 24, height: CategorySelectionCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left:  CubeRuler.iPhoneHorizontal(10, 25, 25).value, bottom: 0, right: CubeRuler.iPhoneHorizontal(10, 25, 25).value)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let category = categorys[indexPath.item]
        
        if let action = selectCategoryAction {
            let isInset = seletedCategoryStrings.contains(category.categoryString)
            
            if action(category, !isInset) {
                
                if isInset {
                    seletedCategoryStrings.remove(category.categoryString)
                } else {
                    seletedCategoryStrings.insert(category.categoryString)
                }
                
                if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCell {
                    if seletedCategoryStrings.contains(category.categoryString) {
                        cell.categorySelection = .on
                    } else {
                        cell.categorySelection = .off
                    }
                }
            } else {
                CubeAlert.alertSorry(message: "修改技能出现错误", inViewController: self)
            }
        }
    }
}
