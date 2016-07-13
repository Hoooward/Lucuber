//
//  ShowDetailCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import CoreGraphics

private let containerContentInsetTop: CGFloat = 30
class ShowDetailCell: UICollectionViewCell {

    /// 更新ShowDetailVC的Navigationbar闭包
    typealias updateTitle = (Formula?)->()
    var updateNavigatrionBar : updateTitle?
    
    private let HeaderImageDetailIdentifier = "HeaderCell"
    private let MasterIndicaterIdentifier = "MasterCell"
    private let SepatatorIndicatierIdentifier = "SeparatorCell"
    private let FormuilaIndicaterIdentifier = "FormulaCell"
    private let FooterIndicaterIdentifier = "FooterCell"
    
    @IBOutlet var containerCollectionView: DetailSubCollectionView!
    
    var formula: Formula? {
        didSet {
            containerCollectionView.reloadData()
            if let updateTitleClouser = updateNavigatrionBar {
                updateTitleClouser(formula)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerCollectionView.registerNib(UINib(nibName: HeaderImageDetailIdentifier, bundle: nil),forCellWithReuseIdentifier: HeaderImageDetailIdentifier)
        containerCollectionView.registerNib(UINib(nibName: MasterIndicaterIdentifier, bundle: nil), forCellWithReuseIdentifier: MasterIndicaterIdentifier)
        containerCollectionView.registerNib(UINib(nibName: SepatatorIndicatierIdentifier, bundle: nil), forCellWithReuseIdentifier: SepatatorIndicatierIdentifier)
        
        containerCollectionView.registerNib(UINib(nibName: FormuilaIndicaterIdentifier, bundle: nil), forCellWithReuseIdentifier: FormuilaIndicaterIdentifier)
        containerCollectionView.registerNib(UINib(nibName: FooterIndicaterIdentifier, bundle: nil), forCellWithReuseIdentifier: FooterIndicaterIdentifier)
        
        containerCollectionView.contentInset = UIEdgeInsetsMake(containerContentInsetTop, 0, 49, 0)
        containerCollectionView.delegate = self
        containerCollectionView.dataSource = self
        containerCollectionView.showsVerticalScrollIndicator = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        containerCollectionView.contentOffset = CGPointMake(0, -containerContentInsetTop)
    }
    
    //绘制公式，来自Yep，暂时不需要
    func getFormulasImage(formulas: [String]) -> UIImage {
        let maxWidth = screenWidth - 40
        let marginTop: CGFloat = 10
        
        var formulasLabels = [CGRect]()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: 50), false, UIScreen.mainScreen().scale)
        
        for (index, formula) in formulas.enumerate() {
            let textRect = CGRectMake(0, 0, 0, 17)
            let textTextContent = NSString(string: formula)
            let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .Center
            
            let textFontAttributes: [String: AnyObject] = {
                return [NSFontAttributeName:UIFont(name: "Menlo-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor(),
                        NSParagraphStyleAttributeName: textStyle]
            }()
            
            let textTextWidth: CGFloat = textTextContent.boundingRectWithSize(CGSizeMake(CGFloat.infinity, 19), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.width + 10
            
            var rect = CGRectMake(0, marginTop, textTextWidth, textRect.height + 10)
            
            let y = CGFloat(index) * (rect.height + 10)
            
            rect = CGRectMake(0, y, rect.width, rect.height)
            
            let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
            
            UIColor.cubeTintColor().setFill()
            rectanglePath.fill()
            formulasLabels.append(rect)
            
            textTextContent.drawInRect(rect, withAttributes: textFontAttributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension ShowDetailCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 5
    }
    
    enum Section: Int {
        case Header = 0
        case Master
        case Sepatator
        case Formula
        case Footer
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .Header:
            return 1
        case .Master:
            return 1
        case .Sepatator:
            return 1
        case .Formula:
            return 3
        case .Footer:
            return 1
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Header:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HeaderImageDetailIdentifier, forIndexPath: indexPath)
            return cell
        case .Master:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MasterIndicaterIdentifier, forIndexPath: indexPath)
            return cell
        case .Sepatator:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SepatatorIndicatierIdentifier, forIndexPath: indexPath)
            return cell
        case .Formula:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FormuilaIndicaterIdentifier, forIndexPath: indexPath)
            return cell
        case .Footer:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FooterIndicaterIdentifier, forIndexPath: indexPath)
            return cell
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Header:
            let cell = cell as! HeaderCell
            cell.formula = self.formula
        case .Formula:
            let cell = cell as! FormulaCell
            switch indexPath.row {
            case 0:
                cell.formulaString = self.formula!.contents.first!.text!
            case 1:
//                cell.formulaString = "(R U' U') (R2' F R F') U2 (R' F R F')"
                cell.formulaString = self.formula!.contents[indexPath.item].text!
            default:
//                cell.formulaString = "(U R' U') (R U' R) U (R U' R' U)(R U R2 U')(R' U)"
                cell.formulaString =  self.formula!.contents[indexPath.item].text!
            }
        default:
            break
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        
        switch section {
        case .Header:
            return CGSizeMake(screenWidth, screenWidth + 110)
        case .Master:
            return CGSizeMake(screenWidth, 50)
        case .Sepatator:
            return CGSizeMake(screenWidth, 40)
        case .Formula:
            let string = self.formula!.contents[indexPath.item].text!
            let attributsStr = string.setAttributesFitDetailLayout(ContentStyle.Detail)
            //这串数字是xib中的约束
            let rect = attributsStr.boundingRectWithSize(CGSizeMake(screenWidth - 38 - 30 - 4 - 20 - 20 - 38, CGFloat(MAXFLOAT)), options:NSStringDrawingOptions.init(rawValue: 1), context: nil)
            print("resultFrame = \(rect)")
            
            //如果文字+top约束 > 图片高度+top约束
            let height = rect.height + 10 > 10 + 30 ? rect.height + 10 + 20 : 10 + 30 + 20
//            if rect.height + 10 > 10 + 30 {
//                
//            }
            
            return CGSizeMake(screenWidth, height)
        case .Footer:
            return CGSizeMake(screenWidth, 80)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch  section {
        case .Footer:
            //通知自己的控制器Push评论视图控制器
            NSNotificationCenter.defaultCenter().postNotificationName(DetailCellShowCommentNotification, object: formula, userInfo: nil)
        default:
            break
        }
        
    }
    
    
}






















