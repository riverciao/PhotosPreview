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
    func fetch(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void)
}

class ImageAPIManager: ImageManager {
    
    let manager = PHImageManager.default()
    var assets = [PHAsset]()
    var images = [UIImage]()
    var assetCollections = [PHAssetCollection]()
    
    func fetchAssetsInAlblum() {
//        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
//        assets.enumerateObjects({ (object, count, stop) in
//            self.assets.append(object)
//        })
        let assets = PHAsset.fetchAssets(in: assetCollections[0], options: nil)
        assets.enumerateObjects { (object, index, stop) in
            self.assets.append(object)
        }
        self.assets.reverse()
    }
    
    func fetch(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void) {
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in
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
    
    func fetchAssetCollections() {
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        assetCollections.enumerateObjects { (object, index, stop) in
            self.assetCollections.append(object)
        }
        self.assetCollections.reverse()
    }
}
