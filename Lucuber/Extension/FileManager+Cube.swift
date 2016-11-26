//
//  FileManager+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/26.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public enum FileExtension: String {
    case jpeg = "jpg"
    case mp4 = "mp4"
    case m4a = "m4a"
    
    public var mimeType: String {
        switch self {
        case .jpeg:
            return "image/jpeg"
        case .mp4:
            return "video/mp4"
        case .m4a:
            return "audio/m4a"
        }
    }
}

extension FileManager {
    
    public class func cubeCachesURL() -> URL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    public class func cubeAvatarCachesURL() -> URL? {
        
        let fileManager = FileManager.default
        
        let avatarCachesURL = cubeCachesURL().appendingPathComponent("avatar_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: avatarCachesURL, withIntermediateDirectories: true, attributes: nil)
            return avatarCachesURL
        } catch _ {
        }
        
        return nil
    }
    
    public class func cubeAvatarURL(with name: String) -> URL? {
        
        if let avatarCachesURL = cubeAvatarCachesURL() {
            return avatarCachesURL.appendingPathComponent("\(name).\(FileExtension.jpeg.rawValue)")
        }
        
        return nil
    }
    
    public class func deleteAvatarImage(with name: String) {
        if let avatarURL = cubeAvatarURL(with: name) {
            do {
                try FileManager.default.removeItem(at: avatarURL)
            } catch _ {
            }
        }
    }
    
    public class func saveAvatarImage(with avatarImage: UIImage, withName name: String) -> URL? {
        
        if let avatarURL = cubeAvatarURL(with: name) {
            let imageData = UIImageJPEGRepresentation(avatarImage, 0.8)
            if FileManager.default.createFile(atPath: avatarURL.path, contents: imageData, attributes: nil) {
                return avatarURL
            }
        }
        return nil
    }
    
    // MARK: - Message
    
    public class func cubeMessageCachesURL() -> URL? {
        
        let fileManager = FileManager.default
        
        let messageCachesURL = cubeCachesURL().appendingPathComponent("message_caches", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: messageCachesURL, withIntermediateDirectories: true, attributes: nil)
            return messageCachesURL
        } catch _ {
            
        }
        return nil
    }
    
    
    // MARK: - Image
    
    public class func cubeMessageImageURL(with name: String) -> URL? {
        
        if let messageCachesURL = cubeMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.jpeg.rawValue)")
        }
        
        return nil
    }
    
    
   
}
