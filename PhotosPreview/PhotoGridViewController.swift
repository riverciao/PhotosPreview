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
    var isAlbumSelected = false
    @IBOutlet weak var albumTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cameraRollCollection = imageManager.cameraRollAssetCollection() {
            imageManager.fetchAssets(in: cameraRollCollection)
        }
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
        
        // MARK: AlbumTableView
        albumTableView.register(
            UINib(nibName: AlbumCell.identifier, bundle: nil),
            forCellReuseIdentifier: AlbumCell.identifier
        )
        albumTableView.dataSource = self
        albumTableView.delegate = self
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageManager.assetsInColletion.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = imageManager.assetsInColletion[indexPath.row]
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
        let asset = imageManager.assetsInColletion[indexPath.row]
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
        if !isAlbumSelected {
            openAlbumView()
            isAlbumSelected = true
        } else {
            closeAlbumView()
            isAlbumSelected = false
        }
    }
    
    /// Animate to open the albumTableView
    private func openAlbumView() {
        albumTableView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.collectionView.frame.minY
        }
    }
    
    /// Animate to close the albumTableView
    private func closeAlbumView() {
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.collectionView.frame.maxY
        }
    }
}

extension PhotoGridViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageManager.assetCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.identifier, for: indexPath) as! AlbumCell
        cell.selectionStyle = .none
        let assetCollection = imageManager.assetCollections[indexPath.row]
        cell.albumNameLabel.text = assetCollection.localizedTitle
        cell.albumAssetNumberLabel.text = String(assetCollection.photosCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let colletcion = imageManager.assetCollections[indexPath.row]
        imageManager.fetchAssets(in: colletcion)
        collectionView.reloadData()
        isAlbumSelected = false
        closeAlbumView()
    }
}
