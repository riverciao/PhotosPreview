//
//  PreviewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class PreviewController: UIViewController {

    // MARK: Properties
    
    var imageManager = ImageAPIManager()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    var isPreviewOpened = false
    @IBAction func openPreviewView(_ sender: UIButton) {
        if !isPreviewOpened {
            openPreview()
            isPreviewOpened = true
        } else {
            closePreview()
            isPreviewOpened = false
        }
        updateUI()
    }
    
    @IBOutlet weak var photoGridButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imagePlaceholderImageView: UIImageView!
    @IBOutlet weak var previewViewTopConstraint: NSLayoutConstraint!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let cameraRollAssetCollection =  imageManager.cameraRollAssetCollection() {
            imageManager.fetchAssets(in: cameraRollAssetCollection)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        closePreview()
        isPreviewOpened = false
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinimumZoomScaleForSize()
    }
    
    // MARK: Setup
    
    private func setup() {
        // MARK: CollectionView
        collectionView.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // MARK: Button
        photoGridButton.setupButtonUI(
            with: #imageLiteral(resourceName: "icon-grid"),
            backgroundColor: .photoGridButtonBackgroundColor,
            tintColor: .photoGridButtonTintColor,
            conerRadius: photoGridButton.bounds.width / 2
        )
        previewButton.setupButtonUI(
            with: #imageLiteral(resourceName: "icon-photo"), backgroundColor: .unselectButtonBackgroundColor,
            tintColor: .unselectButtonTintColor,
            conerRadius: 5
        )
        
        // MARK: ScrollView
        scrollView.delegate = self
        scrollView.contentSize = displayImageView.bounds.size
        scrollView.maximumZoomScale = 2.0
        scrollView.contentInset = .zero
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // MARK: ImageView
        imagePlaceholderImageView.image = #imageLiteral(resourceName: "icon-photo").withRenderingMode(.alwaysTemplate)
        imagePlaceholderImageView.tintColor = .white
        
        // MARK: TapGesture
//        let tap = UITapGestureRecognizer(target: self, action: #selector(closePreviewView))
//        view.addGestureRecognizer(tap)
        
        // MARK: Notification
        NotificationCenter.default.addObserver(self, selector: #selector(loadImage), name: Notification.Name("image"), object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Action
    
    @objc private func loadImage(_ sender: Notification) {
        if let asset = imageManager.asAsset(sender.object) {
            imageManager.requsetImage(for: asset, targetSize: self.view.bounds.size) { (image) in
                self.displayImageView.image = image
                self.placeholderImageView.image = nil
                self.closePreview()
                self.isPreviewOpened = false
                self.updateUI()
            }
        }
    }
    
    private func updateMinimumZoomScaleForSize() {
        let size = scrollView.bounds.size
        let widthScale = size.width / displayImageView.bounds.width
        let heightScale = size.height / displayImageView.bounds.height
        let minimunScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minimunScale
        scrollView.zoomScale = minimunScale
        
    }
    
    private func updateUI() {
        if isPreviewOpened {
            previewButton.backgroundColor = .selectedButtonBackgroundColor
            previewButton.tintColor = .selectedButtonTintColor
            photoGridButton.isHidden = false
        } else {
            previewButton.backgroundColor = .unselectButtonBackgroundColor
            previewButton.tintColor = .unselectButtonTintColor
            photoGridButton.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToPhotoGrid" {
            if let photoGridViewController = segue.destination as? PhotoGridViewController {
                let imageManager = ImageAPIManager()
                imageManager.fetchAssetCollections()
                imageManager.fetchAssets(in: imageManager.assetCollections[12])
                photoGridViewController.imageManager = imageManager
            }
        }
    }
    

    func openPreview() {
        if !isPreviewOpened {
            previewView.translatesAutoresizingMaskIntoConstraints = true
            UIView.animate(withDuration: 0.3) {
                self.previewView.frame.origin.y = self.view.bounds.maxY - self.previewView.frame.height
                self.previewButton.frame.origin.y = self.view.bounds.maxY - self.previewView.frame.height - self.previewButton.frame.height
            }
        }
    }
    
    @objc func closePreview(_ sender: UITapGestureRecognizer? = nil) {
        if isPreviewOpened {
            UIView.animate(withDuration: 0.3) {
                self.previewView.frame.origin.y = self.view.bounds.maxY
                self.previewButton.frame.origin.y = self.view.bounds.maxY - self.previewButton.frame.height
            }
        }
    }
}

extension PreviewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
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
        imageManager.requsetImage(for: asset, targetSize: view.bounds.size) { (image) in
            self.displayImageView.image = image
            self.placeholderImageView.image = nil
            self.closePreview()
            self.isPreviewOpened = false
            self.updateUI()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return displayImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5 , 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5 , 0.0)
        scrollView.contentInset = .init(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

