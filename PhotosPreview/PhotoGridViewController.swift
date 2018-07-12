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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    var isAlbumSelected = false
    @IBOutlet weak var albumTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAlbum()
    }

    // MARK: Setup
    
    private func fetchAlbum() {
        // fetch assets in CameraRoll album and set album title
        let albumType: AlbumType = .cameraRoll
        imageManager.fetchAssets(of: albumType)
        albumButton.setTitle(albumType.title, for: .normal)
    }
    
    private func setup() {
        
        // MARK: CollectionView
        collectionView.register(
            UINib(nibName: PhotoGridCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoGridCell.identifier
        )
        collectionView.register(
            UINib(nibName: PhotoGridHeaderCell.identifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: PhotoGridHeaderCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // MARK: CloseButton
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.addShadow(
            shadowColor: .black,
            shadowOffset: CGSize(width: 0.5, height: 0.5),
            opacity: 1.0,
            shadowRadius: 1
        )
        
        // MARK: AlbumButton
        albumButton.addTarget(self, action: #selector(selectAlbum), for: .touchUpInside)
        albumButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        albumButton.titleLabel?.numberOfLines = 0
        albumButton.titleLabel?.addShadow(
            shadowColor: .black,
            shadowOffset: CGSize(width: 0.5, height: 0.5),
            opacity: 1.0,
            shadowRadius: 1
        )
        
        // MARK: AlbumTableView
        albumTableView.register(
            UINib(nibName: AlbumCell.identifier, bundle: nil),
            forCellReuseIdentifier: AlbumCell.identifier
        )
        albumTableView.addDarkBlurBackground()
        albumTableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        albumTableView.dataSource = self
        albumTableView.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        let size = CGSize(width: cell.bounds.width * 2, height: cell.bounds.height * 2)
        cell.tag = imageManager.requsetImage(for: asset, targetSize: size, resultHandler: { (image) in
            cell.imageView.image = image
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoGridHeaderCell.identifier, for: indexPath)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerView.bounds.size
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
            self.albumTableView.frame.origin.y = self.headerView.frame.maxY
            self.headerView.backgroundColor = .photoGridHeaderViewOpenedColor
        }
    }
    
    /// Animate to close the albumTableView
    private func closeAlbumView() {
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.view.frame.maxY
            self.headerView.backgroundColor = .photoGridHeaderViewClosedColor
        }
    }
}

extension PhotoGridViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageManager.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.identifier, for: indexPath) as! AlbumCell
        let album = imageManager.albums[indexPath.row]
        cell.albumNameLabel.text = album.title
        cell.albumAssetNumberLabel.text = String(album.collection.photosCount)
        let size = CGSize(width: cell.bounds.width * 2, height: cell.bounds.height * 2)
        imageManager.latestThumbnailImage(in: album.collection, at: size) { (image) in
            cell.albumImageView.image = image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = imageManager.albums[indexPath.row]
        imageManager.fetchAssets(of: album)
        collectionView.reloadData()
        albumButton.setTitle(album.title, for: .normal)
        isAlbumSelected = false
        closeAlbumView()
    }
}