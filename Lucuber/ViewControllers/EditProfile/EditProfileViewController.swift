//
//  EditProfileViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import RealmSwift
import AVOSCloud
import Navi
import Proposer

final class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var moblieLabel: UILabel! {
        didSet {
            moblieLabel.textColor = UIColor.cubeTintColor()
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let realm = try! Realm()
    
    var introduction: String {
        var introduction = ""
        if let intro = currentUser(in: realm)?.introduction {
           introduction = intro
        }
        if introduction.isEmpty {
            return "此处是自我介绍"
        }
        return introduction
    }
    
    @IBOutlet weak var editProfileTableView: TPKeyboardAvoidingTableView! {
        didSet {
            editProfileTableView.registerNib(of: EditProfileLessInfoCell.self)
            editProfileTableView.registerNib(of: EditProfileMoreInfoCell.self)
            editProfileTableView.registerNib(of: EditProfileColoredTitleCell.self)
        }
    }
    
    @IBOutlet weak var mobileContainerView: UIStackView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tapMoblieContainer))
            mobileContainerView.addGestureRecognizer(tap)
        }
    }
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    fileprivate lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditProfileViewController.save))
        return button
    }()
    
    fileprivate var giveUpEditing: Bool = false
    fileprivate var isDirty: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem = doneButton
            doneButton.isEnabled = isDirty
        }
    }
    
    fileprivate func heightOfCellForMoreInfo(_ info: String) -> CGFloat {
        
        let tableViewWidth: CGFloat = editProfileTableView.bounds.width
        let introLabelMaxWidth: CGFloat = tableViewWidth - Config.EditProfile.infoInset
        
        let rect: CGRect = info.boundingRect(with: CGSize(width: introLabelMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: Config.EditProfile.infoFont], context: nil)
        
        let height: CGFloat = 20 + 22 + 10 + ceil(rect.height) + 20
        
        return max(height, 120)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑个人主页"
        
        updateAvatar {}
        
        if let me = currentUser(in: realm) {
            moblieLabel.text = me.username
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        giveUpEditing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        giveUpEditing = true
        view.endEditing(true)
    }
    
    func updateAvatar(_ completion: () -> Void) {
        
        guard let realm = try? Realm(), let me = currentUser(in: realm) else {
            return
        }
        
        if let avatarURLString = me.avatorImageURL, !avatarURLString.isEmpty {
            
            let avatarSize = Config.EditProfile.avatarSize
            let size = CGSize(width: avatarSize, height: avatarSize)
            let avatarStyle: AvatarStyle = AvatarStyle.roundedRectangle(size: size, cornerRadius: avatarSize * 0.5, borderWidth: 0)
            let avatar = CubeAvatar(avatarUrlString: avatarURLString, avatarStyle: avatarStyle)
            avatarImageView.navi_setAvatar(avatar, withFadeTransitionDuration: 0.0)
            completion()
            
        } else {
            
            avatarImageView.image = UIImage(named: "default_avatar_60")
        }
    }
    
    func tapMoblieContainer() {
        
    }
    
    func save() {
        view.endEditing(true)
        isDirty = false
    }
    
    @IBAction func changeAvatar(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let choosePhotoAction = UIAlertAction(title: "选择照片", style: .default, handler: { _ in
            
            let openCamerRoll: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                    self?.alertCanNotOpenPhotoLibrary()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .photoLibrary
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.photos, agreed: openCamerRoll, rejected: { [weak self] in
                self?.alertCanNotOpenPhotoLibrary()
            })
        })
        
        alertController.addAction(choosePhotoAction)
        
        let takePhotoAction = UIAlertAction(title: "拍照", style: .default, handler: { _ in
            
            let openCamera: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.alertCanNotOpenCamera()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .camera
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.camera, agreed: openCamera, rejected: { [weak self] in
                self?.alertCanNotOpenCamera()
            })
        })
        
        alertController.addAction(takePhotoAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case info
        case logOut
    }
    
    enum InfoRow: Int {
        case nikeName
        case intro
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .info:
            return 2
            
        case .logOut:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .info:
            
            guard let infoRow = InfoRow(rawValue: indexPath.row) else {
                fatalError()
            }
            
            switch infoRow {
            case .nikeName:
                
                let cell: EditProfileLessInfoCell = tableView.dequeueReusableCell(for: indexPath)
                
                cell.annotationLabel.text = "昵称"
                let nickname = currentUser(in: realm)?.nickname ?? "无"
                
                cell.infoLabel.text = nickname
                cell.selectionStyle = .default
                cell.accessoryImageView.isHidden = false
                cell.bageImageView.image = nil
                
                cell.infoLabelTrailingConstraint.constant = 8
                
                return cell
                
            case .intro:
                
                let cell: EditProfileMoreInfoCell = tableView.dequeueReusableCell(for: indexPath)
                
                cell.annotationLabel.text = "自我介绍"
                
                cell.infoTextView.text = introduction
                
                cell.infoTextViewBeginEditingAction = {[weak self] infoTextView in
                    if self?.introduction ?? "" == "此处是自我介绍" {
                        infoTextView.text = ""
                    }
                }
                
                cell.infoTextViewIsDirtyAction = { [weak self] in
                    self?.isDirty = true
                    
                }
                
                cell.infoTextViewDidEndEditingAction = { [weak self] newIntroducation in
                    
                    guard let strongSelf = self, let me = currentUser(in: strongSelf.realm) else {
                        return
                    }
                    
                    guard !strongSelf.giveUpEditing else {
                        return
                    }
                    
                    strongSelf.doneButton.isEnabled = false
                    
                    let oldIntro = me.introduction ?? ""
                    
//                    guard strongSelf.isDirty else {
//                        return
//                    }
                    
                    if oldIntro == newIntroducation {
                        return
                    }
                    
                    CubeHUD.showActivityIndicator()
                    
                    pushMyIntroductionToLeancloud(with: newIntroducation, failureHandler: {reason, errorMessage in
                        
                        defaultFailureHandler(reason, errorMessage)
                        CubeHUD.hideActivityIndicator()
                        
                    }, completion: {
                        
                        CubeHUD.hideActivityIndicator() 
                        guard let realm = try? Realm(), let me = currentUser(in: strongSelf.realm) else {
                            return
                        }
                        
                        try? realm.write {
                            me.introduction = newIntroducation
                        }
                    })
                }
                
                return cell
            }
            
        case .logOut:
            let cell: EditProfileColoredTitleCell = tableView.dequeueReusableCell(for: indexPath)
            cell.coloredLable.text = "退出登录"
            cell.coloredLable.textColor = UIColor.red
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .info:
            
            guard let infoRow = InfoRow(rawValue: indexPath.row) else {
                fatalError()
            }
            
            switch infoRow {
            case .nikeName:
                return 60
                
            case .intro:
                return heightOfCellForMoreInfo(introduction)
            }
            
        case .logOut:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .info:
            guard let infoRow = InfoRow(rawValue: indexPath.row) else {
                fatalError()
            }
            
            switch infoRow {
                
            case .nikeName:
                
                let nickname = currentUser(in: realm)?.nickname ?? ""
                
                CubeAlert.textInput(title: "设置昵称", message: "", placeholder: "可使用字母或文字", oldText: nickname, confirmTitle: "设置", cancelTitle: "取消", inViewController: self, confirmAction: { [weak self] text in
                    
                    
                    let newNickname = text
                    
                    pushMyNicknameToLeancloud(with: newNickname, failureHandler: { reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                        
                        CubeAlert.alertSorry(message: errorMessage, inViewController: self)
                        
                    }, completion: {
                        
                        guard let realm = try? Realm(), let me = currentUser(in: realm) else {
                            return 
                        }
                        
                        try? realm.write {
                            me.nickname = newNickname
                        }
                        
                        if let nicknameCell = tableView.cellForRow(at: indexPath) as? EditProfileLessInfoCell {
                            nicknameCell.infoLabel.text = newNickname
                        }
                    })
                    
                }, cancelAction: {
                    
                })
                
            default:break
            }
            
        case .logOut:
            
            CubeAlert.confirmOrCancel(title: "注意", message: "您要退出登录吗?", confirmTitle: "是的", cancelTitles: "取消", inViewController: self, confirmAction: {
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                appDelegate.unregisterThirdPartyPush()
                
                UserDefaults.clearAllUserDefaultes()
                
                cleanRealmAndCaches()
                AVUser.logOut()
               
                NotificationCenter.default.post(name: NSNotification.Name.changeRootViewControllerNotification, object: nil)
                
               
            }, cancelAction: {
            })
            
            break
        }
    }
}

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        activityIndicator.startAnimating()
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            let resultImage = image.largestCenteredSquareImage().resizeTo(targetSize: Config.avatarMaxSize())
            let imageData = UIImageJPEGRepresentation(resultImage, 0.7)
            
            if imageData != nil {
                
                pushDataToLeancloud(with: imageData, failureHandler: { reason, errorMessage in
                    
                    defaultFailureHandler(reason, errorMessage)
                    
                    self.activityIndicator.stopAnimating()
                    
                }, completion: { newAvatarString in
                    
                    guard let newAvatarString = newAvatarString  else {
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    
                    pushMyAvatarURLStringToLeancloud(with: newAvatarString, failureHandler: {
                        reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                        self.activityIndicator.stopAnimating()
                        
                    }, completion: { [weak self] in
                        
                        guard let realm = try? Realm(), let me = currentUser(in: realm) else {
                            return
                        }
                        
                        try? realm.write {
                            me.avatorImageURL = newAvatarString
                        }
                        
                        self?.updateAvatar({ [weak self] in
                            self?.activityIndicator.stopAnimating()
                        })
                    })
                })
            }
        }
    }
}
