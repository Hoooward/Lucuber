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
    
    public class func saveMessageImageData(_ messageImageData: Data, withName name: String) -> URL? {
        if let messageImageURL = cubeMessageImageURL(with: name) {
            if FileManager.default.createFile(atPath: messageImageURL.path, contents: messageImageData, attributes: nil) {
                return messageImageURL
            }
        }
        return nil
    }
    
    public class func removeMessageImageFile(with name: String) {
        
        guard !name.isEmpty else { return }
        
        if let messageImageURL = cubeMessageImageURL(with: name) {
            do {
                try FileManager.default.removeItem(at: messageImageURL)
            } catch _ {
                
            }
        }
    }
    
    // MARK: - Audio
    
    public class func cubeMessageAudioURL(with name: String) -> URL? {
        if let messageCachesURL = cubeMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.m4a.rawValue)")
        }
        return nil
    }
    
    public class func saveMessageAudioData(messageAudioData: Data, withName name: String) -> URL? {
        
        if let messageAudioURL = cubeMessageAudioURL(with: name) {
            if FileManager.default.createFile(atPath: messageAudioURL.path, contents: messageAudioData, attributes: nil) {
                return messageAudioURL
            }
            return nil
        }
        return nil
    }
    
    public class func removeMessageAudioFile(with name: String) {
        
        guard !name.isEmpty else { return }
        
        if let messageAudioURL = cubeMessageAudioURL(with: name) {
            do {
                try FileManager.default.removeItem(at: messageAudioURL)
            } catch _ {
                
            }
        }
    }
    
    // MARK: - Video
    
    public class func cubeMessageVideoURL(with name: String) -> URL? {
        
        if let messageCachesURL = cubeMessageCachesURL() {
            return messageCachesURL.appendingPathComponent("\(name).\(FileExtension.mp4.rawValue)")
        }
        return nil
    }
    
    public class func saveMessageVideoData(_ messageVideoData: Data, withName name: String) -> URL? {
        
        if let messageVideoURL = cubeMessageVideoURL(with: name) {
            if FileManager.default.createFile(atPath: messageVideoURL.path, contents: messageVideoData, attributes: nil) {
                return messageVideoURL
            }
        }
        return nil
    }
    
    public class func removeMessageVideoFiles(with name: String, thumbnailName: String) {
        
        if !name.isEmpty {
            if let messageVideoURL = cubeMessageVideoURL(with: name) {
                do {
                    try FileManager.default.removeItem(at: messageVideoURL)
                } catch _ {
                }
            }
        }
        
        if !thumbnailName.isEmpty {
            if let messageImageURL = cubeMessageImageURL(with: thumbnailName) {
                do {
                    try FileManager.default.removeItem(at: messageImageURL)
                } catch _ {
                }
            }
        }
    }
    
    
   
}





















