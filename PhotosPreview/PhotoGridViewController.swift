//
//  PhotoGridViewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit
import Photos

class PhotoGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var assets = [PHAsset]()
    var imageManager = ImageAPIManager()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var albumTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        
        // MARK: CollectionView
        collectionView.register(
            UINib(nibName: PhotoGridCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoGridCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // MARK: CloseButton
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(selectAlbum), for: .touchUpInside)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageManager.numberOfAssets()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = imageManager.asset(at: indexPath)
        if cell.tag != 0 {
            imageManager.cancelImageRequest(cell.tag)
        }
        cell.tag = imageManager.requsetImage(for: asset, targetSize: cell.bounds.size, resultHandler: { (image) in
            cell.imageView.image = image
        })
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = imageManager.asset(at: indexPath)
        NotificationCenter.default.post(name: Notification.Name("image"), object: asset)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    

    // MARK: Action
    
    @objc private func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectAlbum(_ sender: UIButton) {
        albumTableView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.collectionView.frame.minY
        }
    }
}
