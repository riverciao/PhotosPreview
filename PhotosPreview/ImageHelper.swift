//
//  ImageHelper.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/17.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class ImageHelper {
    private static var bundle: Bundle {
        let bundle = Bundle(for: ImageHelper.self)
        return bundle
    }
    
    static func image(_ name: String) -> UIImage {
        return UIImage.init(named: name, in: bundle, compatibleWith: nil)!
    }
}
