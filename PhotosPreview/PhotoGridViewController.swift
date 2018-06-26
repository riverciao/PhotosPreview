//
//  PhotoGridViewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit
import Photos

class PhotoGridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        collectionView?.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        getImages()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: 120.0, height: 120.0),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                cell.imageView.image = result

        })
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    

    // MARK: Action
    
    func getImages() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            // self.cameraAssets.add(object)
            self.images.append(object)
            //In order to get latest image first, we just reverse the array
        })
        
        self.images.reverse()
        
        // To show photos, I have taken a UICollectionView
        self.collectionView?.reloadData()
    }

}
