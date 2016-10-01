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
        
        tableView.register(UINib(nibName: MasterCellIdentifier, bundle: nil), forCellReuseIdentifier: MasterCellIdentifier)
        tableView.register(UINib(nibName: FormulasCellIdentifier,bundle: nil), forCellReuseIdentifier: FormulasCellIdentifier)
        tableView.register(UINib(nibName: SeparatorCellIdentifier,bundle: nil), forCellReuseIdentifier: SeparatorCellIdentifier)
        tableView.register(UINib(nibName: DetailCommentCellIdentifier,bundle: nil), forCellReuseIdentifier: DetailCommentCellIdentifier)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
//        formula = nil
//        tableView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: headerView.headerHeight )
        tableView.tableHeaderView = headerView
        
    }


}

extension DetailCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case master = 0
        case separator = 1
        case formulas = 2
        case comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .master:
            return 1
        case .separator:
            return 1
        case .formulas:
            printLog("formulaContentCount = \(formula?.contents)")
            return formula?.contents.count ?? 1
        case .comment:
            return 1
    
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .master:
            return Config.FormulaDetail.masterRowHeight
        case .separator:
            return Config.FormulaDetail.separatorRowHeight
        case .formulas:
           return formula?.contents[indexPath.row].cellHeight ?? 100
        case .comment:
            return Config.FormulaDetail.commentRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .master:
            let cell = tableView.dequeueReusableCell(withIdentifier: MasterCellIdentifier, for: indexPath) as! DetailMasterCell
            return cell
            
        case .separator:
            let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorCellIdentifier, for: indexPath)
            return cell
            
        case .formulas:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormulasCellIdentifier, for: indexPath) as! DetailFormulasCell
            cell.formulaContent = formula?.contents[indexPath.row]
            return cell
            
        case .comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommentCellIdentifier, for: indexPath)
            return cell
        }
 
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .master:
        
            if let cell = tableView.cellForRow(at: indexPath) as? DetailMasterCell {
                
                cell.changeMasterStatus(with: formula)
            }
//            printLog("master is clicked")
            
        case .comment:
            if let formula = formula,
               let closure = pushCommentViewController {
                closure(formula)
            }
        default:
            return
        }
        
    }
    
}














