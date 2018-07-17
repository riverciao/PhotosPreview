//
//  ImageHelper.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/17.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class ImageHelper {
    private class var identifier: String { return String(describing: self)}
    static func image(_ name: String) -> UIImage {
        let podBundle = Bundle(for: ImageHelper.self)
        if let url = podBundle.url(forResource: ImageHelper.identifier, withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)!
        }
        return UIImage()
    }
}
