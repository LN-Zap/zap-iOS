//
//  Library
//
//  Created by 0 on 27.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import Photos

struct Screenshot {
    let id: String
    let image: UIImage
    let message: String
}

final class ScreenshotChecker {
    private let maxScreenshotAge: TimeInterval = 60 * 1500

    func qrCodes(on image: UIImage) -> CIQRCodeFeature? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

        let options: [String: Any]
        if ciImage.properties.keys.contains(kCGImagePropertyOrientation as String) {
            options = [CIDetectorImageOrientation: ciImage.properties[kCGImagePropertyOrientation as String] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }

        let features = qrDetector?
            .features(in: ciImage, options: options)
            .compactMap { $0 as? CIQRCodeFeature }

        guard features?.count == 1 else { return nil }

        return features?.first
    }

    func lastScreenshot(completion: @escaping (Screenshot) -> Void) {
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)

        guard let screenshotCollection = collections.firstObject else { return }

        let options = PHFetchOptions()
        options.fetchLimit = 1
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let creationDate = Date(timeIntervalSinceNow: -maxScreenshotAge)
        options.predicate = NSPredicate(format: "creationDate > %@", argumentArray: [creationDate])

        let assets = PHAsset.fetchAssets(in: screenshotCollection, options: options)

        guard let screenshot = assets.firstObject else { return }

        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false

        manager.requestImage(for: screenshot, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            guard
                let image = image,
                let qrCodeMessage = self.qrCodes(on: image)?.messageString
                else { return }
            completion(Screenshot(id: screenshot.localIdentifier, image: image, message: qrCodeMessage))
        }
    }
}
