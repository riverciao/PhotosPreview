//
//  ImageManager.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/3.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import Foundation
import Photos

protocol ImageManager {
    func fetch(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, resultHandler: @escaping (UIImage) -> Void)
}

struct ImageManagerAPI: ImageManager {
    let manager = PHImageManager.default()
    
    func fetch(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, resultHandler: @escaping (UIImage) -> Void) {
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: nil) { (image, info) in
            guard
                let image = image,
                let info = info,
                let isLowQualified = info[PHImageResultIsDegradedKey] as? Bool
                else { return }
            
            if !isLowQualified {
                resultHandler(image)
            }
        }
    }
    
    
}
