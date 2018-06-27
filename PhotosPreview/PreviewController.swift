//
//  PreviewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit
import Photos

class PreviewController: UIViewController {

    var images = [PHAsset]()
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBAction func openPreviewView(_ sender: UIButton) {
        openView(targetView: previewView, hidden: true)
        photoGridButton.backgroundColor = .red
        print("OOOOO\(photoGridButton.frame)")
    }
    
    @IBOutlet weak var photoGridButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImages()
        collectionView.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
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
        self.collectionView.reloadData()
        
    }

    func openView(targetView: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .curveEaseInOut, animations: {
            targetView.frame.origin.y = self.view.frame.height - targetView.bounds.height + 6
            self.previewButton.frame.origin.y = targetView.frame.minY - self.previewButton.frame.height - 8
        })
    }
}

extension PreviewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
}

