//
//  ImageHelper.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/17.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

/// Get icon and button image from Image.bundle.
class ImageHelper {
    static func image(_ name: String) -> UIImage {
        let podBundle = Bundle(for: ImageHelper.self)
        if let url = podBundle.url(forResource: "PhotosPreview", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
        }
        return UIImage()
    }
}
