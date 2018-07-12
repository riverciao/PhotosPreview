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

protocol ImageManagerDelegate: class {
    func didGetAssetsInAlbum(by manager: ImageManager)
}

class ImageAPIManager: ImageManager {
    
    private let manager = PHImageManager.default()
    private var assetsInColletion = [PHAsset]()
    private var albums = [AlbumType]()
    
    weak var delegate: ImageManagerDelegate?
    
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
    
    func fetchAssets(in album: AlbumType) {
        let collection = album.collection
        self.assetsInColletion = []
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        assets.enumerateObjects { (object, index, stop) in
            self.assetsInColletion.append(object)
        }
        self.assetsInColletion.reverse()
        delegate?.didGetAssetsInAlbum(by: self)
    }
    
    func fetchAllAlbums() {
        albums = []
        let smartAlbums: [AlbumType] = [.cameraRoll, .favorites, .videos, .screenshots, .selfies]
        for album in smartAlbums {
            if album.countOfPhotos > 0 {
                albums.append(album)
            }
        }
        
        let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        customAlbums.enumerateObjects { (object, index, stop) in
            if object.countOfPhotos > 0 {
                self.albums.append(AlbumType.custom(index: index))
            }
        }
    }
    
    /// Get the lastest image in collection.
    func latestThumbnailImage(in collection: PHAssetCollection, at targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void) {
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        guard let lastAsset = assets.lastObject else { return }
        requsetImage(for: lastAsset, targetSize: targetSize) { (image) in
            resultHandler(image)
        }
    }
    
    func cancelImageRequest(_ requestIDNumber: Int) {
        manager.cancelImageRequest(PHImageRequestID(requestIDNumber))
    }
    
    // MARK: DataSource
    
    func asset(at indexPath: IndexPath) -> PHAsset {
        return assetsInColletion[indexPath.row]
    }
    
    func countOfAssets() -> Int {
        return assetsInColletion.count
    }
    
    func asAsset(_ object: Any?) -> PHAsset? {
        guard let asset = object as? PHAsset else { return nil }
        return asset
    }
    
    func album(at indexPath: IndexPath) -> AlbumType {
        return albums[indexPath.row]
    }
    
    func countOfAlbums() -> Int {
        return albums.count
    }
}

extension PHAssetCollection {
    var countOfPhotos: Int {
        let result = PHAsset.fetchAssets(in: self, options: nil)
        return result.count
    }
}

enum AlbumType {
    case cameraRoll, favorites, videos, screenshots, selfies, custom(index: Int)
}

extension AlbumType {
    var title: String? {
        return collection.localizedTitle
    }
    
    var countOfPhotos: Int {
        return collection.countOfPhotos
    }
    
    var collection: PHAssetCollection {
        switch self {
        case .cameraRoll:
            let albumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            return albumResult.object(at: 0)
        case .favorites:
            let albumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
            return albumResult.object(at: 0)
        case .screenshots:
            let albumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
            return albumResult.object(at: 0)
        case .selfies:
            let albumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil)
            return albumResult.object(at: 0)
        case .videos:
            let albumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
            return albumResult.object(at: 0)
        case .custom(let index):
            let albumResults = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            return albumResults.object(at: index)
        }
    }
}
