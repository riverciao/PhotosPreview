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
    let imageManager = PHImageManager.default()
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBAction func openPreviewView(_ sender: UIButton) {
        openView(targetView: previewView)
    }
    
    @IBOutlet weak var photoGridButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImages()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photoGridButton.isHidden = true
    }
    
    // MARK: Setup
    
    private func setup() {
        // MARK: CollectionView
        collectionView.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closePreviewView))
        view.addGestureRecognizer(tap)
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

    func openView(targetView: UIView) {
        let isPreviewViewClosed = previewView.frame.minY == view.frame.maxY
        if isPreviewViewClosed {
            UIView.animate(withDuration: 0.5) {
                self.previewView.frame.origin.y -= self.previewView.frame.height - 6
                self.previewButton.frame.origin.y -= self.previewView.frame.height - 6
            }
            photoGridButton.isHidden = false
        }
    }
    
    @objc private func closePreviewView(_ sender: UITapGestureRecognizer) {
        let isPreviewViewOpened = previewView.frame.maxY - 6 == view.frame.maxY
        if isPreviewViewOpened {
            UIView.animate(withDuration: 0.5) {
                self.previewView.frame.origin.y += self.previewView.frame.height - 6
                self.previewButton.frame.origin.y += self.previewView.frame.height - 6
            }
            photoGridButton.isHidden = true
        }
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
        
        if cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        cell.tag = Int(imageManager.requestImage(for: asset,
                                            targetSize: CGSize(width: 150, height: 150),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                cell.imageView.image = result
                                                
        })
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = images[indexPath.row]
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFit, options: nil) { (image, _) in
            self.displayImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.displayImageView.image = image
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
}

