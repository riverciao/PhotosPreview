//
//  PhotoGridViewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

public protocol PhotoGridDelegate: class {
    //MARK: Required
    func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController)
    
    // MARK: Optional
    func photoGridViewDidLoad()
    func photoGridViewWillApear()
    func photoGridViewDidApear()
    func photoGridWillDismiss()
    func photoGridDidDismissed()
}

public extension PhotoGridDelegate {
    func photoGridViewDidLoad() {}
    func photoGridViewWillApear() {}
    func photoGridViewDidApear() {}
    func photoGridWillDismiss() {}
    func photoGridDidDismissed() {}
}

public class PhotoGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: Public Property
    
    /// Use nibName to init PhotoGridViewController
    public class var nibName: String { return String(describing: self) }
    
    /// Number of cell per row. Default value is 3. Automatically recount the cell size with 'numberOfCellPerRow', edge inset, and minimumInteritemSpacing.
    public var numberOfCellPerRow: CGFloat = 3
    
    /// Left edge inset and right edge inset of collection view. Default value is 0.
    public var horizontalEdgeInset: CGFloat = 0
    
    /// Top edge inset and bottom edge inset of collection view. Default value is 0.
    public var verticalEdgeInset: CGFloat = 0
    
    /// MinimumLineSpacing of collection view flow layout. Default value is 4.
    public var minimumLineSpacing: CGFloat = 4
    
    /// MinimumInteritemSpacing of collection view flow layout. Default value is 4.
    public var minimumInteritemSpacing: CGFloat = 4
    
    /// The aspect ratio of photo grid cell. Default value is 1.0.
    public var aspectRatio: CGFloat = 1
    
    /// The image size in the photo grid cell. If it is not set, the default value would be 2 times of the cell size.
    public var cellImageSize: CGSize?
    
    /// The backgraound color of colletion view. Default value is black.
    public var backgroundColor: UIColor = .black
    
    // MARK: Private property
    
    private var photoProvider = PhotoProvider()
    private var isAlbumSelected = false
    
    public weak var delegate: PhotoGridDelegate?
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var albumTableView: UITableView!
    
    // MARK: Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        delegate?.photoGridViewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAlbum()
        delegate?.photoGridViewWillApear()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        delegate?.photoGridViewDidApear()
    }

    // MARK: Setup
    
    private func fetchAlbum() {
        // fetch assets in CameraRoll album and set album title
        let albumType: AlbumType = .cameraRoll
        photoProvider.fetchAssets(in: albumType)
        albumButton.setTitle(albumType.title, for: .normal)
        
        // fetch all albums for album selection
        photoProvider.fetchAllAlbums()
    }
    
    private func setup() {
        
        // MARK: CollectionView
        collectionView.register(
            UINib(nibName: PhotoGridCell.identifier,
                  bundle: Bundle(for: PhotoGridCell.classForCoder())),
            forCellWithReuseIdentifier: PhotoGridCell.identifier
        )
        
        collectionView.register(
            UINib(nibName: PhotoGridHeaderCell.identifier,
                  bundle: Bundle(for: PhotoGridHeaderCell.classForCoder())),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: PhotoGridHeaderCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = backgroundColor
        
        // MARK: CloseButton
        closeButton.setImage(ImageHelper.image("button-close"), for: .normal)
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
            UINib(nibName: AlbumCell.identifier,
                  bundle: Bundle(for: AlbumCell.classForCoder())),
            forCellReuseIdentifier: AlbumCell.identifier
        )
        albumTableView.addDarkBlurBackground()
        albumTableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        albumTableView.dataSource = self
        albumTableView.delegate = self
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoProvider.countOfAssets()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = photoProvider.asset(at: indexPath)
        if cell.tag != 0 { photoProvider.cancelImageRequest(cell.tag) }
        
        // Request image size at 'cellImageSize'. If it is not set, the default value would be 2 times of cell size.
        if let size = cellImageSize {
            cell.tag = photoProvider.requsetImage(for: asset, targetSize: size) { (image) in
                cell.imageView.image = image
            }
        } else {
            let cellSize = cell.bounds.size
            let size = CGSize(width: cellSize.width * 2, height: cellSize.height * 2)
            cell.tag = photoProvider.requsetImage(for: asset, targetSize: size) { (image) in
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoGridHeaderCell.identifier, for: indexPath)
        return headerView
    }
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photoProvider.asset(at: indexPath)
        NotificationCenter.default.post(name: Notification.Name("image"), object: asset)
        photoProvider.requsetImage(for: asset) { (image) in
            self.delegate?.didSelectImage(image, by: self)
        }
        close()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let countOfInteritemSpacing = numberOfCellPerRow - 1
        let width = (
            screenWidth
            - horizontalEdgeInset * 2
            - minimumInteritemSpacing * countOfInteritemSpacing
            ) / numberOfCellPerRow
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: verticalEdgeInset, left: horizontalEdgeInset, bottom: verticalEdgeInset, right: horizontalEdgeInset)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    // MARK: Action
    
    @objc private func close(_ sender: UIButton? = nil) {
        self.delegate?.photoGridWillDismiss()
        presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.photoGridDidDismissed()
        })
    }
    
    @objc private func selectAlbum(_ sender: UIButton) {
        if !isAlbumSelected {
            openAlbumView()
        } else {
            closeAlbumView()
        }
    }
    
    /// Animate to open the albumTableView
    private func openAlbumView() {
        albumTableView.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.headerView.frame.maxY
            self.headerView.backgroundColor = .photoGridHeaderViewOpenedColor
        }
        isAlbumSelected = true
    }
    
    /// Animate to close the albumTableView
    private func closeAlbumView() {
        UIView.animate(withDuration: 0.3) {
            self.albumTableView.frame.origin.y = self.view.frame.maxY
            self.headerView.backgroundColor = .photoGridHeaderViewClosedColor
        }
        isAlbumSelected = false
    }
}

// MARK: AlbumTableView Delegate

extension PhotoGridViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: TableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoProvider.countOfAlbums()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AlbumCell.identifier,
            for: indexPath) as! AlbumCell
        let album = photoProvider.album(at: indexPath)
        cell.albumNameLabel.text = album.title
        cell.albumAssetNumberLabel.text = String(album.countOfPhotos)
        
        let size = CGSize(
            width: cell.bounds.width * 2,
            height: cell.bounds.height * 2
        )
        photoProvider.latestThumbnailImage(in: album, at: size) { (image) in
            cell.albumImageView.image = image
        }
        return cell
    }
    
    // MARK: TableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = photoProvider.album(at: indexPath)
        photoProvider.fetchAssets(in: album)
        albumButton.setTitle(album.title, for: .normal)
        collectionView.reloadData()
        closeAlbumView()
    }
}
