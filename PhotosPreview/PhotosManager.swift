//
//  PhotosManager.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/3.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import Foundation
import Photos

protocol PhotosManager {
    
    // MARK: Fetch data and request image from Asset
    func fetchAssets(in album: AlbumType)
    func fetchAllAlbums()
    func requsetImage(for asset: PHAsset, targetSize: CGSize?, resultHandler: @escaping (UIImage) -> Void)
    func latestThumbnailImage(in album: AlbumType, at targetSize: CGSize, resultHandler: @escaping (UIImage) -> Void)
    
    // MARK: DataSource
    func asset(at indexPath: IndexPath) -> PHAsset
    func countOfAssets() -> Int
    func album(at indexPath: IndexPath) -> AlbumType
    func countOfAlbums() -> Int
}

protocol PhotoProviderDelegate: class {
    func didGetAssetsInAlbum(by manager: PhotosManager)
}

/// Provide photo in Photos library.
public class PhotoProvider: PhotosManager {
    
    // MARK: Public property
    
    /// Request image at this size. It is recommended to set 'imageSize' at least double of the imageView size that image will be assigned into. Default value is UIScreen scale times of UIScreen size.
    public lazy var imageSize: CGSize = {
        let screenSize = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        return CGSize(
            width: screenSize.width * scale,
            height: screenSize.height * scale
        )
    }()
    
    // MARK: Private property
    private let manager = PHCachingImageManager()
    private var assetsInColletion = [PHAsset]()
    private var albums = [AlbumType]()
    weak var delegate: PhotoProviderDelegate?
    
    // MARK: Init
    public init() {}
    
    // MARK: FetchData
    /// Fetch assets in specific album and cache them. Can get asset by method asset(at: IndexPath) after fetching assets.
    public func fetchAssets(in album: AlbumType) {
        self.assetsInColletion = []
        let collection = album.collection
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        assets.enumerateObjects { (object, _, _) in
            self.assetsInColletion.append(object)
        }
        // reverse the array to get lastest asset at first index
        assetsInColletion.reverse()
        manager.startCachingImages(for: assetsInColletion, targetSize: imageSize, contentMode: .aspectFit, options: nil)
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
    
    /// Request image for specific asset, return high qualidied UIImage in resultHandler.
    public func requsetImage(for asset: PHAsset, targetSize: CGSize? = nil, resultHandler: @escaping (UIImage) -> Void) {
        // Request image at this size. If both targetSize and displaySize are not set, default displaySize is double size of UIScreen.
        let size = targetSize ?? imageSize
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
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
        return assetsInColletion[indexPath.item]
    }
    
    public func countOfAssets() -> Int {
        return assetsInColletion.count
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
