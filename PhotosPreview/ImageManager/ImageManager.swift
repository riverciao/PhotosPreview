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
    typealias RequestIDNumber = Int
    func requsetImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void) -> RequestIDNumber
}

class ImageAPIManager: ImageManager {
    
    let manager = PHImageManager.default()
    var assetsInCameraRoll = [PHAsset]()
    var assetsInColletion = [PHAsset]()
    var images = [UIImage]()
    var assetCollections = [PHAssetCollection]()
    
    func fetchAssetsInCameraRoll() {
        guard let cameraRollColletion = cameraRollAssetCollection() else { return }
        self.assetsInCameraRoll = []
        let assets = PHAsset.fetchAssets(in: cameraRollColletion, options: nil)
        assets.enumerateObjects { (object, index, stop) in
            self.assetsInCameraRoll.append(object)
        }
        self.assetsInCameraRoll.reverse()
    }
    
    func fetchAssets(in collection: PHAssetCollection) {
        self.assetsInColletion = []
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        assets.enumerateObjects { (object, index, stop) in
            self.assetsInColletion.append(object)
        }
        self.assetsInColletion.reverse()
    }
    
    typealias RequestIDNumber = Int
    
    @discardableResult
    func requsetImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void) -> RequestIDNumber {
        let requsetID = manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in
            guard
                let image = image,
                let info = info,
                let isLowQualified = info[PHImageResultIsDegradedKey] as? Bool
                else { return }
            
            if !isLowQualified {
                resultHandler(image)
            }
        }
        return Int(requsetID)
    }
    
    func fetchAssetCollections() {
        assetCollections = []
        let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        let smartAlbums = systemAlbums([.smartAlbumUserLibrary, .smartAlbumFavorites, .smartAlbumVideos, .smartAlbumScreenshots, .smartAlbumSelfPortraits])
        
        for smartAlbum in smartAlbums {
            smartAlbum.enumerateObjects { (object, index, stop) in
                if object.photosCount > 0 {
                    self.assetCollections.append(object)
                }
            }
        }
        
        
        customAlbums.enumerateObjects { (object, index, stop) in
            if object.photosCount > 0 {
                self.assetCollections.append(object)
            }
        }
    }
    
    private func systemAlbums(_ subtypes: [PHAssetCollectionSubtype]) -> [PHFetchResult<PHAssetCollection>] {
        var smartAlbums = [PHFetchResult<PHAssetCollection>]()
        for subtype in subtypes {
            let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil)
            smartAlbums.append(album)
        }
        return smartAlbums
    }
    
    func cameraRollAssetCollection() -> PHAssetCollection? {
        var assetCollection: PHAssetCollection?
        let assets = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        assets.enumerateObjects { (object, index, stop) in
            assetCollection = object
        }
        return assetCollection
    }
    
    func cancelImageRequest(_ requestIDNumber: Int) {
        manager.cancelImageRequest(PHImageRequestID(requestIDNumber))
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset {
        return assetsInCameraRoll[indexPath.row]
    }
    
    func numberOfAssets() -> Int {
        return assetsInCameraRoll.count
    }
    
    func asAsset(_ object: Any?) -> PHAsset? {
        guard let asset = object as? PHAsset else { return nil }
        return asset
    }
}

extension PHAssetCollection {
    var photosCount: Int {
        let result = PHAsset.fetchAssets(in: self, options: nil)
        return result.count
    }
}
