//
//  AlbumType.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/13.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import Photos

public enum AlbumType {
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
