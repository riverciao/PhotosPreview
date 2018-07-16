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
    
    func fetchAssets(in album: AlbumType)
    func fetchAllAlbums()
    
    typealias RequestIDNumber = Int
    func requsetImage(for asset: PHAsset, targetSize: CGSize?, resultHandler: @escaping (UIImage) -> Void) -> RequestIDNumber
    func latestThumbnailImage(in album: AlbumType, at targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void)
    
    // MARK: DataSource
    func asset(at indexPath: IndexPath) -> PHAsset
    func countOfAssets() -> Int
    func asAsset(_ object: Any?) -> PHAsset?
    func album(at indexPath: IndexPath) -> AlbumType
    func countOfAlbums() -> Int
}

protocol ImageManagerDelegate: class {
    func didGetAssetsInAlbum(by manager: ImageManager)
}

public class ImageAPIManager: ImageManager {
    
    // MARK: Public property
    
    /// Request image at this size. It is recommended to set 'imageSize' at least double of the imageView size that image will be assigned into. Default value is double of UIScreen size.
    public var imageSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width * 2,
        height: UIScreen.main.bounds.height * 2
    )
    
    // MARK: Private property
    private let manager = PHCachingImageManager()
    private var assetsInColletion = [PHAsset]()
    private var albums = [AlbumType]()
    
    weak var delegate: ImageManagerDelegate?
    
    // MARK: FetchData
    /// Fetch assets in specific album and get asset in method asset(at: IndexPath).
    public func fetchAssets(in album: AlbumType) {
        self.assetsInColletion = []
        let collection = album.collection
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        assets.enumerateObjects { (object, _, _) in
            self.assetsInColletion.append(object)
        }
        // reverse the array to get lastest asset at first index
        assetsInColletion.reverse()
        let size = CGSize(width: 400, height: 400)
        manager.startCachingImages(for: assetsInColletion, targetSize: size, contentMode: .aspectFit, options: nil)
        delegate?.didGetAssetsInAlbum(by: self)
    }
    
    /// Fetch albums including smart albums: CameraRoll, Favorites, Videos, Selfies when more than one photo is in the album. Also fetch albums that user created.
    public func fetchAllAlbums() {
        albums = []
        let smartAlbums: [AlbumType] = [.cameraRoll, .favorites, .videos, .screenshots, .selfies]
        for album in smartAlbums {
            // Only fetch album when more than one photo is in the album
            if album.countOfPhotos > 0 {
                albums.append(album)
            }
        }
        
        let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        customAlbums.enumerateObjects { (object, index, stop) in
            if object.countOfPhotos > 0 {
                // Save index in albumtype to handle more than one custom album that user created
                self.albums.append(AlbumType.custom(index: index))
            }
        }
    }
    
    public typealias RequestIDNumber = Int
    
    /// Request image for specific asset, return high qualidied UIImage in resultHandler.
    @discardableResult
    public func requsetImage(for asset: PHAsset, targetSize: CGSize? = nil, resultHandler: @escaping (UIImage) -> Void) -> RequestIDNumber {
        // Request image at this size. If both targetSize and displaySize are not set, default displaySize is double size of UIScreen.
        let size = targetSize ?? imageSize
        let requsetID = manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
            guard
                let image = image,
                let info = info,
                let isLowQualified = info[PHImageResultIsDegradedKey] as? Bool
                else { return }
            // when manager.requestImage return low qualified image, do not accept it as result. Later manager.requestImage will return a high qualified image
            
            if !isLowQualified {
                resultHandler(image)
            }
        }
        return Int(requsetID)
    }
    
    /// Get the lastest image in collection.
    public func latestThumbnailImage(in album: AlbumType, at targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void) {
        let assets = PHAsset.fetchAssets(in: album.collection, options: nil)
        guard let lastAsset = assets.lastObject else { return }
        requsetImage(for: lastAsset, targetSize: targetSize) { (image) in
            resultHandler(image)
        }
    }
    
    public func cancelImageRequest(_ requestIDNumber: Int) {
        manager.cancelImageRequest(PHImageRequestID(requestIDNumber))
    }
    
    // MARK: DataSource
    
    public func asset(at indexPath: IndexPath) -> PHAsset {
        return assetsInColletion[indexPath.row]
    }
    
    public func countOfAssets() -> Int {
        return assetsInColletion.count
    }
    
    public func asAsset(_ object: Any?) -> PHAsset? {
        guard let asset = object as? PHAsset else { return nil }
        return asset
    }
    
    public func album(at indexPath: IndexPath) -> AlbumType {
        return albums[indexPath.row]
    }
    
    public func countOfAlbums() -> Int {
        return albums.count
    }
}

extension PHAssetCollection {
    var countOfPhotos: Int {
        let result = PHAsset.fetchAssets(in: self, options: nil)
        return result.count
    }
}
