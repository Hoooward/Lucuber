//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import MobileCoreServices

extension CommentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        if let mediaType = info[UIImagePickerControllerMediaType] as? String {

            switch mediaType {

            case String(kUTTypeImage):

                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

                    let imageWidth = image.size.width
                    let imageHeight = image.size.height

                    let fixedImageWidth: CGFloat
                    let fixedImageHeight: CGFloat

                    if imageWidth > imageHeight {
                        fixedImageHeight = min(imageHeight, Config.Media.imageHeight)
                        fixedImageWidth = imageWidth * (fixedImageHeight / imageHeight)
                    } else {
                        fixedImageWidth = min(imageWidth, Config.Media.imageWidth)
                        fixedImageHeight = imageHeight * (fixedImageWidth / imageWidth)
                    }

                    let fixedSize = CGSize(width: fixedImageWidth, height: fixedImageHeight)

                    if let fixedImage = image.resizeTo(targetSize: fixedSize, quality: .high) {
                        sendImage(fixedImage)
                    }
                }

            case String(kUTTypeMovie):

            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                printLog("viedioURL \(videoURL)")

                // TODO: - send video
            }

            default:
                break
            }
        }

        dismiss(animated: true, completion: nil)
    }
}