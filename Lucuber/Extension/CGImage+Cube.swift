//
// Created by Tychooo on 16/12/16.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit

extension CGImage {

    var extendedCanvasCGImage: CGImage {

        let width = self.width
        let height = self.height

        guard width > 0 && height > 0 else {
            return self
        }

        func hasAlpha() -> Bool {
            let alpha = self.alphaInfo
            switch alpha {
            case .first, .last, .premultipliedFirst, .premultipliedLast:
                return true
            default:
                return false
            }
        }

        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        if hasAlpha() {
            bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue
        } else {
            bitmapInfo |= CGImageAlphaInfo.noneSkipFirst.rawValue
        }

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo) else {
            return self
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let newCGImage = context.makeImage() else {
            return self
        }

        return newCGImage
    }
}
