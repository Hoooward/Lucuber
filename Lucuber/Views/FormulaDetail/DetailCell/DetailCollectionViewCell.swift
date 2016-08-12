//
//  DetailCollectionViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let MasterCellIdentifier = "DetailMasterCell"
private let FormulasCellIdentifier = "DetailFormulasCell"
private let SeparatorCellIdentifier = "DetailSeparatorCell"
private let DetailCommentCellIdentifier = "DetailCommentCell"

class DetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var headerView: DetailHeaderView = {
        let view = DetailHeaderView()
        return view
    }()
    
    var updateNavigatrionBar: ((Formula) -> Void)?
    
    var pushCommentViewController: ((Formula) -> ())?
    
    var formula: Formula? {
        didSet {
            headerView.formula = formula
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 100, right: 0)
        
        tableView.registerNib(UINib(nibName: MasterCellIdentifier, bundle: nil), forCellReuseIdentifier: MasterCellIdentifier)
        tableView.registerNib(UINib(nibName: FormulasCellIdentifier,bundle: nil), forCellReuseIdentifier: FormulasCellIdentifier)
        tableView.registerNib(UINib(nibName: SeparatorCellIdentifier,bundle: nil), forCellReuseIdentifier: SeparatorCellIdentifier)
        tableView.registerNib(UINib(nibName: DetailCommentCellIdentifier,bundle: nil), forCellReuseIdentifier: DetailCommentCellIdentifier)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
//        formula = nil
//        tableView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame.size = CGSize(width: screenWidth, height: headerView.headerHeight )
        tableView.tableHeaderView = headerView
        
    }


}

extension DetailCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case Master = 0
        case Separator = 1
        case Formulas = 2
//        case LastSeparator
        case Comment
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .Master:
            return 1
        case .Separator:
            return 1
        case .Formulas:
            printLog("formulaContentCount = \(formula?.contents)")
            return formula?.contents.count ?? 1
        case .Comment:
            return 1
    
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Master:
            return CubeConfig.DetailFormula.masterRowHeight
        case .Separator:
            return CubeConfig.DetailFormula.separatorRowHeight
        case .Formulas:
           return formula?.contents[indexPath.row].cellHeight ?? 100
        case .Comment:
            return CubeConfig.DetailFormula.commentRowHeight
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Master:
            let cell = tableView.dequeueReusableCellWithIdentifier(MasterCellIdentifier, forIndexPath: indexPath) as! DetailMasterCell
            return cell
            
        case .Separator:
            let cell = tableView.dequeueReusableCellWithIdentifier(SeparatorCellIdentifier, forIndexPath: indexPath)
            return cell
            
        case .Formulas:
            let cell = tableView.dequeueReusableCellWithIdentifier(FormulasCellIdentifier, forIndexPath: indexPath) as! DetailFormulasCell
            cell.formulaContent = formula?.contents[indexPath.row]
            return cell
            
        case .Comment:
            let cell = tableView.dequeueReusableCellWithIdentifier(DetailCommentCellIdentifier, forIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Comment:
            if let formula = formula,
               let closure = pushCommentViewController {
                closure(formula)
            }
        default:
            return
        }
        
    }
    
}














