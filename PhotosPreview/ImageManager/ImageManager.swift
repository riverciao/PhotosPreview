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
    
    func fetchAssets(in collection: PHAssetCollection) {
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
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
    
    func cameraRollAssetCollection() -> PHAssetCollection? {
        var assetCollection: PHAssetCollection?
        let assets = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        assets.enumerateObjects { (object, index, stop) in
            assetCollection = object
        }
        return assetCollection
    }
}
