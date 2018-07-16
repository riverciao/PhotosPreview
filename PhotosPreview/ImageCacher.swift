//
//  ImageCacher.swift
//  TaipeiPark
//
//  Created by riverciao on 2018/6/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

struct ImageCacher {

    typealias CacheID = Int
    static private var imageCache = [CacheID: Data]()
    
    static func loadImage(with id: CacheID, into imageView: UIImageView) {
        if let imageData = imageCache[id], let image = UIImage(data: imageData) {
            imageView.image = image
        }
    }
    
    static func cache(_ image: UIImage, with id: CacheID, into imageView: UIImageView) {
        
        // if already have image in cache, set image into imageView
        if let imageData = imageCache[id], let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = image
            // if do not have image in cache, save it in cache
            DispatchQueue.global().async {
                let imageData = UIImagePNGRepresentation(image)
                imageCache[id] = imageData
            }
        }
    }
}


