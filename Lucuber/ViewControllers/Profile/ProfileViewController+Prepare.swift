//
//  ProfileViewController+Prepare.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/14.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud
import RealmSwift

extension ProfileViewController {
    
    func prepare(with discoveredUser: AVUser?) {
        
        guard let userID = discoveredUser?.objectId, let me = AVUser.current(), let meID = me.objectId, let discoveredUser = discoveredUser else {
            prepareUI()
            return
        }
        
        if userID != meID {
            self.profileUser = ProfileUser.discoverUser(discoveredUser)
        }
        
        prepareUI()
    }
    
    func prepare(withUser user: RUser?) {
        
        guard let realm = try? Realm(), let me = currentUser(in: realm) , let user = user else {
            prepareUI()
            return
        }
        
        if user.lcObjcetID != me.lcObjcetID {
            self.profileUser = ProfileUser.userType(user)
        }
        
        prepareUI()
    }
    
    func prepare(withProfileUser profileUser: ProfileUser) {
        
        self.profileUser = profileUser
        
        prepareUI()
    }
    
    fileprivate func prepareUI() {
        
        setBackButtonWithTitle()
        
        hidesBottomBarWhenPushed = true
    }
}
