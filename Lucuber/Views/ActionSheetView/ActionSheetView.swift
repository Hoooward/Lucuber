//
//  ActionSheetView.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

final private class ActionSheetOptionCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    var action: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        return label
    }()
    
    var colorTitleLabeltextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitlelabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitlelabel)
        colorTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: colorTitlelabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: colorTitlelabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([centerX, centerY])
    }
}

// MARK: - ActionSheetDefaultCell
final private class ActionSheetDefaultCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        return label
    }()
    
    var colorTitleLabeltextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitlelabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitlelabel)
        colorTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: colorTitlelabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: colorTitlelabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([centerX, centerY])
    }
}

// MARK: - ACtionSheetDetailCell
final private class ActionSheetDetailCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
   
    var action: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGray
        textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ActionSheetSwitchCell 
final private class ActionSheetSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    var action: ((Bool) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGray
        textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSwitchCell.toggleSwitch(_:)), for: .valueChanged)
        return s
    }()
    
    @objc func toggleSwitch(_ sender: UISwitch) {
        action?(sender.isOn)
    }
    
    func makeUI() {
        contentView.addSubview(checkedSwitch)
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20)
        
        NSLayoutConstraint.activate([centerY, trailing])
    }
}


// MARK: - ActionSheetSubtitleSwitchCell
final private class ActionSheetSubtitleSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    var action: ((Bool) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
            
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSubtitleSwitchCell.toggleSwitch(_:)), for: .valueChanged)
        return s
    }()
    
    @objc private func toggleSwitch(_ sender: UISwitch) {
        action?(sender.isOn)
    }
    
    func makeUI() {
        
        contentView.addSubview(checkedSwitch)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        
        titleStackView.axis = .vertical
        titleStackView.distribution = .fill
        titleStackView.alignment = .fill
        titleStackView.spacing = 2
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleStackView)
        
        do {
            let centerY = NSLayoutConstraint(item: titleStackView, attribute: .centerY, relatedBy: .equal, toItem: contentView
                , attribute: .centerY, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: titleStackView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activate([centerY, leading])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([centerY, trailing])
        }
        
        let gap = NSLayoutConstraint(item: checkedSwitch, attribute: .leading, relatedBy: .equal, toItem: titleStackView, attribute: .trailing, multiplier: 1, constant: 10)
        
        NSLayoutConstraint.activate([gap])
    }
}

// MARK: - ActionSheetCheckCell
final private class ActionSheetCheckCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_location_checkmark"))
        return imageView
    }()
    
    var colorTitleLabelTextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitleLabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(checkImageView)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        do {
            let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([centerY, centerX])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 0, constant: 1)
            let trailing = NSLayoutConstraint(item: checkImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([centerY, trailing])
        }
    }
}

// MARK: - ActionSheetView
final class ActionSheetView: UIView{
    
    enum Item {
        case Option(title: String, titleColor: UIColor, action: () -> Void)
        case Default(title: String, titleColor: UIColor, action: () -> Bool)
        case Detail(title: String, titleColor: UIColor, action: () -> Void)
        case Switch(title: String, titleColor: UIColor, switchOn: Bool, action: (_ switchOn: Bool) -> Void)
        case SubtitleSwitch(title: String, titleColor: UIColor, subtitle: String, subtitleColor: UIColor, switchOn: Bool, action: (_ switchOn: Bool) -> Void)
        case Check(title: String, titleColor: UIColor, checked: Bool, action: () -> Void)
        case Cancel
    }
    
    var items: [Item]
    
    private let rowHeight: CGFloat = 60
    
    private var totalHeight: CGFloat {
        return CGFloat(items.count) * rowHeight
    }
    
    init(items: [Item]) {
        self.items = items
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.rowHeight = self.rowHeight
        view.isScrollEnabled = false
        
        view.register(ActionSheetOptionCell.self, forCellReuseIdentifier: ActionSheetOptionCell.reuseIdentifier)
        view.register(ActionSheetDetailCell.self, forCellReuseIdentifier: ActionSheetDetailCell.reuseIdentifier)
        view.register(ActionSheetDefaultCell.self, forCellReuseIdentifier: ActionSheetDefaultCell.reuseIdentifier)
        view.register(ActionSheetSwitchCell.self, forCellReuseIdentifier: ActionSheetSwitchCell.reuseIdentifier)
        view.register(ActionSheetSubtitleSwitchCell.self, forCellReuseIdentifier: ActionSheetSubtitleSwitchCell.reuseIdentifier)
        view.register(ActionSheetCheckCell.self, forCellReuseIdentifier: ActionSheetCheckCell.reuseIdentifier)
        view.backgroundColor = UIColor.clear
        
        return view
        
    }()
    
    private var isFirstTimeBeenAddedAsSubview = true
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if isFirstTimeBeenAddedAsSubview {
            isFirstTimeBeenAddedAsSubview = false
            
            makeUI()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ActionSheetView.hide))
            containerView.addGestureRecognizer(tap)
            
            tap.cancelsTouchesInView = true
            tap.delegate = self
        }
    }
    
    func refreshItems() {
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    func makeUI() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor.clear
        
        let viewsDictionary: [String: AnyObject] = [
            "containerView": containerView,
            "tableView": tableView
        ]
        
        let containerViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: viewsDictionary)
        let containerViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activate(containerViewConstraintsH)
        NSLayoutConstraint.activate(containerViewConstraintsV)
        
        
        let tableViewConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: viewsDictionary)
        
        let tableViewBottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: self.totalHeight)
        
        self.tableViewBottomConstraint = tableViewBottomConstraint
        
        let tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.totalHeight)
        
        NSLayoutConstraint.activate(tableViewConstraintsH)
        NSLayoutConstraint.activate([tableViewBottomConstraint, tableViewHeightConstraint])
    }
    
    func showInView(view: UIView) {
        
        frame = view.bounds
        
        view.addSubview(self)
        
        layoutIfNeeded()
        
        containerView.alpha = 1
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { _ in
            self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            }, completion: { _ in
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: { _ in
            self.tableViewBottomConstraint?.constant = 0
            
            self.layoutIfNeeded()
            
            }, completion: { _ in
        })
    }
    
    func hide() {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { _ in
            self.tableViewBottomConstraint?.constant = self.totalHeight
            
            self.layoutIfNeeded()
            
            }, completion: { _ in
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: { _ in
            self.containerView.backgroundColor = UIColor.clear
            
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    func hideAndDo(afterHideAction: (() -> Void)?) {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: { _ in
            self.containerView.alpha = 0
            
            self.tableViewBottomConstraint?.constant = self.totalHeight
            
            self.layoutIfNeeded()
            
            }, completion: { finished in
                self.removeFromSuperview()
        })
        
        delay(0.1) {
            afterHideAction?()
        }
    }
}


// MARK: - UIGestureRecognizerDelegate
extension ActionSheetView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view != containerView {
            return false
        }
        return true
    }
}

// MARK: - UITableViewDataSource&Delegate
extension ActionSheetView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        switch item {
        case let .Option(title, titleColor, action):
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetOptionCell.reuseIdentifier, for: indexPath) as! ActionSheetOptionCell
            cell.colorTitlelabel.text = title
            cell.colorTitleLabeltextColor = titleColor
            cell.action = action
            
            return cell
            
        case let .Default(title, titleColor, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetDefaultCell.reuseIdentifier) as! ActionSheetDefaultCell
            cell.colorTitlelabel.text = title
            cell.colorTitleLabeltextColor = titleColor
            
            return cell
            
        case let .Detail(title, titleColor, action):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetDetailCell.reuseIdentifier) as! ActionSheetDetailCell
            cell.textLabel?.text = title
            cell.textLabel?.textColor = titleColor
            cell.action = action
            
            return cell
            
        case let .Switch(title, titleColor, switchOn, action):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetSwitchCell.reuseIdentifier) as! ActionSheetSwitchCell
            cell.textLabel?.text = title
            cell.textLabel?.textColor = titleColor
            cell.checkedSwitch.isOn = switchOn
            cell.action = action
            
            return cell
            
        case let .SubtitleSwitch(title, titleColor, subtitle, subtitleColor, switchOn, action):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetSubtitleSwitchCell.reuseIdentifier) as! ActionSheetSubtitleSwitchCell
            cell.titleLabel.text = title
            cell.titleLabel.textColor = titleColor
            cell.subtitleLabel.text = subtitle
            cell.subtitleLabel.textColor = subtitleColor
            cell.checkedSwitch.isOn = switchOn
            cell.action = action
            
            return cell
            
        case let .Check(title, titleColor, checked, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetCheckCell.reuseIdentifier) as! ActionSheetCheckCell
            cell.colorTitleLabel.text = title
            cell.colorTitleLabelTextColor = titleColor
            cell.checkImageView.isHidden = !checked
            
            return cell
            
        case .Cancel:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetDefaultCell.reuseIdentifier) as! ActionSheetDefaultCell
            cell.colorTitlelabel.text = NSLocalizedString("取消", comment: "")
            cell.colorTitleLabeltextColor = UIColor.cubeTintColor()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        
        let item = items[indexPath.row]
        
        switch item {
            
        case .Option(_, _, let action):
            
            hideAndDo(afterHideAction: action)
            
        case .Default(_, _, let action):
            
            if action() {
                hide()
            }
            
        case .Detail(_, _, let action):
            
            hideAndDo(afterHideAction: action)
            
        case .Switch:
            
            break
            
        case .SubtitleSwitch:
            
            break
            
        case .Check(_, _, _, let action):
            
            action()
            hide()
            
        case .Cancel:
            
            hide()
            break
        }
    }
}
