//
//  CubeAvatar.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/10.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import Navi

private let screenScale = UIScreen.main.scale

let miniAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 60, height: 60), cornerRadius: 30, borderWidth: 0)
let nanoAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 40, height: 40), cornerRadius: 20, borderWidth: 0)
let picoAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 30, height: 30), cornerRadius: 15, borderWidth: 0)

struct CubeAvatar {
    
    let avatarUrlString: String
    let avatarStyle: AvatarStyle
    
}

extension CubeAvatar: Navi.Avatar {

    
    var url: URL? {
        return URL(string: avatarUrlString)
    }
    
    var style: AvatarStyle {
        return avatarStyle
    }
    
    
    var placeholderImage: UIImage? {
        
        switch style {
            
        case miniAvatarStyle:
            return UIImage(named: "default_avatar_60")
            
        case nanoAvatarStyle:
            return UIImage(named: "default_avatar_40")
            
        case picoAvatarStyle:
            return UIImage(named: "default_avatar_30")
            
        default:
            return nil
        }
    }
    
    public var localOriginalImage: UIImage? {
        
        if let realm = try? Realm(),
            let avatar = avatarWith(avatarUrlString, inRealm: realm),
            let avatarFileUrl = FileManager.cubeAvatarURL(with: avatar.avatarFileName),
            let image = UIImage(contentsOfFile: avatarFileUrl.path) {
            return image
        }
        
        return nil
    }
    
    
    var localStyledImage: UIImage? {
        
        switch style {
            
        case miniAvatarStyle:
            if let
                realm = try? Realm(),
                let avatar = avatarWith(avatarUrlString, inRealm: realm) {
                return UIImage(data: avatar.roundMini, scale: screenScale)
            }
            
        case nanoAvatarStyle:
            if let
                realm = try? Realm(),
                let avatar = avatarWith(avatarUrlString, inRealm: realm) {
                return UIImage(data: avatar.roundNano, scale: screenScale)
            }
            
        default:
            break
        }
        
        return nil
    }
    
    
    func save(originalImage: UIImage, styledImage: UIImage) {
        
        guard let realm = try? Realm() else {
            return
        }
        
        var _avatar = avatarWith(avatarUrlString, inRealm: realm)
        
        if _avatar == nil {
            
            let newAvatar = Avatar()
            newAvatar.avatarUrlString = avatarUrlString
            
            try? realm.write {
                realm.add(newAvatar)
            }
            
            _avatar = newAvatar
        }
        
        guard let avatar = _avatar else {
            return
        }
        
        let avatarFileName = UUID().uuidString
        
        if avatar.avatarFileName.isEmpty, let _ = FileManager.saveAvatarImage(with: originalImage, withName: avatarFileName) {
            
            try? realm.write {
                avatar.avatarFileName = avatarFileName
            }
            
        }
        
        switch style {
            
        case .roundedRectangle(let size, _, _):
            
            switch size.width {
                
            case 60:
                
                if avatar.roundMini.isEmpty, let data = UIImagePNGRepresentation(styledImage) {
                    try? realm.write {
                        avatar.roundMini = data
                    }
                }
                
            case 40:
                
                if avatar.roundNano.isEmpty, let data = UIImagePNGRepresentation(styledImage) {
                    let _ = try? realm.write {
                        avatar.roundNano = data
                    }
                }
                
            default:
                break
            }
            
        default:
            break
        }
        
    }
    
    
    
    
}













