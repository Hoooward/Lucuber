//
//  Downloader.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/16.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import ImageIO

class CubeDownloader: NSObject {
    
    static let shared = CubeDownloader()
    
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        return session
    }()

    struct ProgressReporter {
        typealias FinishedAction = (Data) -> Void

        struct Task {

            let downloadTask: URLSessionDataTask
            let finishedAction: FinishedAction
            let imageTransform: ((UIImage) -> UIImage)?
            let progress = Progress()
            var tempData = NSMutableData()
            let imageSource = CGImageSourceCreateIncremental(nil)
        }

        var tasks: [Task]
        var finishedTasksCount = 0

        let reportProgress: ((Double, UIImage?) -> Void)?

        var totalProgress: Double {

            let completedCount = tasks.map { $0.progress.completedUnitCount }.reduce(0, +)
            let totalUnitCount = tasks.map { $0.progress.totalUnitCount }.reduce (0, +)

            return Double(completedCount) / Double(totalUnitCount)
        }
    }

    var progressContainer: [ProgressReporter] = []

    class func downloadAttachmentsOfMessage(_ message: Message, reportProgress: @escaping (Double,UIImage?) -> Void, imageTransform: ((UIImage) -> UIImage)?, imageFinished: ((UIImage) -> Void)?) {

        // 如果已经下载完成, 返回
        if message.downloadState == MessageDownloadState.downloaded.rawValue {
            return
        }

        let messageID = message.localObjectID

        var attachmentDownloadTask: URLSessionDataTask?
        var attachmentDownloadFinishAction: ProgressReporter.FinishedAction?

        let attachmentUrlString = message.attachmentURLString

        if !attachmentUrlString.isEmpty, let url = URL(string: attachmentUrlString) {

            attachmentDownloadTask = shared.session.dataTask(with: url)

            attachmentDownloadFinishAction = { data in

                DispatchQueue.main.async {
               
                guard let realm = try? Realm() else {
                    return
                }

                if let message = messageWith(messageID, inRealm: realm) {

                    var fileName = message.localAttachmentName

                    if fileName.isEmpty {
                        fileName = UUID().uuidString
                    }

                    realm.beginWrite()
                    switch message.mediaType {

                    case MessageMediaType.image.rawValue:

                        _ = FileManager.saveMessageImageData(data, withName: fileName)

                        message.localAttachmentName = fileName
                        message.downloadState = MessageDownloadState.downloaded.rawValue

                        // 如果是 image 类型的 Message 任务完成
                        if let image = UIImage(data: data) {
                            imageFinished?(image)
                        }

                    case MessageMediaType.video.rawValue:

                        _ = FileManager.saveMessageVideoData(data, withName: fileName)
                        message.localAttachmentName = fileName
                        if !message.localThumbnailName.isEmpty {
                            message.downloadState = MessageDownloadState.downloaded.rawValue
                        }

                    case  MessageMediaType.audio.rawValue:

                        _ = FileManager.saveMessageAudioData(messageAudioData: data, withName: fileName)
                        message.localAttachmentName = fileName
                        message.downloadState = MessageDownloadState.downloaded.rawValue

                    default: break

                    }
                    try? realm.commitWrite()
                    
                    }
                }
                
            }
        }

        var thumbnailDownloadTask: URLSessionDataTask?
        var thumbnailDownloadFinishedAction: ProgressReporter.FinishedAction?

        if message.mediaType == MessageMediaType.video.rawValue {

            let thumbnailUrlString = message.thumbnailURLString

            if !thumbnailUrlString.isEmpty, let url = URL(string: thumbnailUrlString) {

                thumbnailDownloadTask = shared.session.dataTask(with: url)

                thumbnailDownloadFinishedAction = { data in
                    
                    DispatchQueue.main.async {
                        guard let realm = try? Realm() else {
                            return
                        }
                        
                        if let message = messageWith(messageID, inRealm: realm) {
                            
                            var fileName = message.localThumbnailName
                            
                            if fileName.isEmpty {
                                fileName = UUID().uuidString
                            }
                            
                            realm.beginWrite()
                            _ = FileManager.saveMessageImageData(data, withName: fileName)
                            message.localThumbnailName = fileName
                            if !message.localAttachmentName.isEmpty {
                                message.downloadState = MessageDownloadState.downloaded.rawValue
                            }
                            try? realm.commitWrite()
                            
                            if let image = UIImage(data: data) {
                                imageFinished?(image)
                            }
                        }
                    }
                }
            }
        }

        var tasks: [ProgressReporter.Task] = []

        if let attachmentDownloadTask = attachmentDownloadTask, let attachmentFinishAction = attachmentDownloadFinishAction {
            
            let progress = ProgressReporter.Task(downloadTask: attachmentDownloadTask, finishedAction: attachmentFinishAction, imageTransform: imageTransform, tempData: NSMutableData())
            tasks.append(progress)
        }

        if let thumbnailDownloadTask = thumbnailDownloadTask, let thumbnailFinishAction = thumbnailDownloadFinishedAction {
            let progress =  ProgressReporter.Task(downloadTask: thumbnailDownloadTask, finishedAction: thumbnailFinishAction, imageTransform: imageTransform, tempData: NSMutableData())
            tasks.append(progress)
        }

        if tasks.count > 0 {

            let progressReporter = ProgressReporter(tasks: tasks, finishedTasksCount: 0, reportProgress: reportProgress)
            shared.progressContainer.append(progressReporter)

            tasks.forEach {
                $0.downloadTask.resume()
            }

        }
    }

    
     func finishDownloadTask(_ downloadTask: URLSessionDataTask) {
        
        for i in 0..<progressContainer.count {
            
            for j in 0..<progressContainer[i].tasks.count {
                
                if downloadTask == progressContainer[i].tasks[j].downloadTask {
                    
                    let finishedAction = progressContainer[i].tasks[j].finishedAction
                    let data = progressContainer[i].tasks[j].tempData
                    finishedAction(data as Data)
                    
                    progressContainer[i].finishedTasksCount += 1
                    
                    // 若任务都已完成，移除此 progressReporter
                    if progressContainer[i].finishedTasksCount == progressContainer[i].tasks.count {
                        progressContainer.remove(at: i)
                    }
                    
                    return
                }
            }
        }
    }


}

extension CubeDownloader: URLSessionDelegate {



}

extension CubeDownloader: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {

        completionHandler(.allow)
        for progressReporter in progressContainer {

            for i in 0..<progressReporter.tasks.count {

                if dataTask == progressReporter.tasks[i].downloadTask {
                    progressReporter.tasks[i].progress.totalUnitCount = response.expectedContentLength
                    progressReporter.reportProgress?(progressReporter.totalProgress, nil)

                    return
                }
            }
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        for progressReporter in progressContainer {

            for i in 0..<progressReporter.tasks.count {

                if dataTask == progressReporter.tasks[i].downloadTask {

                    let didReceiveDataBytes = Int64((data as NSData).length)
                    progressReporter.tasks[i].progress.completedUnitCount += didReceiveDataBytes
                    progressReporter.tasks[i].tempData.append(data)

                    let progress = progressReporter.tasks[i].progress
                    let final = progress.completedUnitCount == progress.totalUnitCount

                    let imageSource = progressReporter.tasks[i].imageSource
                    let data = progressReporter.tasks[i].tempData

                    CGImageSourceUpdateData(imageSource, data as CFData, final)

                    var transitionImage: UIImage?

                    if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {

                        let image = UIImage(cgImage: cgImage.extendedCanvasCGImage)

                        if progressReporter.totalProgress < 1 {
                            let blurPercent = CGFloat(1 - progressReporter.totalProgress)
                            let radius = 5 * blurPercent
                            let iterations = UInt(10 * blurPercent)

                            if let blurredImage = image.blurredImage(withRadius: radius, iterations: iterations, tintColor: UIColor.clear) {
                                if let imageTransform = progressReporter.tasks[i].imageTransform {
                                    transitionImage = imageTransform(blurredImage)
                                }
                            }
                        }
                    }

                    progressReporter.reportProgress?(progressReporter.totalProgress, transitionImage)

                    if final {

                        finishDownloadTask(dataTask)
                    }
                }
            }
        }
    }


}

