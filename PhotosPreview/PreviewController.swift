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

    // MARK: Properties
    
    var images = [PHAsset]()
    let imageManager = PHImageManager.default()
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    var isPreviewOpened = false
    @IBAction func openPreviewView(_ sender: UIButton) {
        if !isPreviewOpened {
            openView(targetView: previewView)
        } else {
            closePreviewView()
        }
    }
    
    @IBOutlet weak var photoGridButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var displayImageViewAspectRatio: NSLayoutConstraint!
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImages()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isPreviewOpened = false
        updateUI()
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
            backgroundColor: .buttonBackgroundColor,
            tintColor: .buttonTintColor,
            conerRadius: photoGridButton.bounds.width / 2
        )
        previewButton.setupButtonUI(
            with: #imageLiteral(resourceName: "icon-photo"), backgroundColor: .white,
            tintColor: .lightGray,
            conerRadius: 5
        )
        
        // MARK: TapGesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(closePreviewView))
        view.addGestureRecognizer(tap)
        
        // MARK: Notification
        NotificationCenter.default.addObserver(self, selector: #selector(loadImage), name: Notification.Name("image"), object: nil)
    }
    
    // MARK: Action
    
    @objc private func loadImage(_ sender: Notification) {
        if let asset = sender.object as? PHAsset {
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFit, options: nil) { (image, _) in
                self.displayImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                self.displayImageView.image = image
                self.updateImageAspectRatio()
            }
        }
    }
    
    private func updateImageAspectRatio() {
        guard let image = displayImageView.image else { return }
        displayImageView.removeConstraint(displayImageViewAspectRatio)
        displayImageViewAspectRatio = NSLayoutConstraint(
            item: displayImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: displayImageView,
            attribute: .height,
            multiplier: image.size.width / image.size.height,
            constant: 0
        )
        displayImageView.addConstraint(displayImageViewAspectRatio)
    }
    
    private func updateUI() {
        if isPreviewOpened {
            previewButton.backgroundColor = .blue
            previewButton.tintColor = .white
            photoGridButton.isHidden = false
        } else {
            previewButton.backgroundColor = .white
            previewButton.tintColor = .lightGray
            photoGridButton.isHidden = true
        }
    }
    
    func getImages() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            self.images.append(object)
        })
        
        self.images.reverse()
        
        // To show photos, I have taken a UICollectionView
        self.collectionView.reloadData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToPhotoGrid" {
            if let photoGridViewController = segue.destination as? PhotoGridViewController {
                photoGridViewController.images = self.images
            }
        }
    }
    

    func openView(targetView: UIView) {
        isPreviewOpened = previewView.frame.minY != view.frame.maxY
        if !isPreviewOpened {
            UIView.animate(withDuration: 0.3) {
                self.previewView.frame.origin.y -= self.previewView.frame.height - 6
                self.previewButton.frame.origin.y -= self.previewView.frame.height - 6
            }
            isPreviewOpened = true
            updateUI()
        }
    }
    
    @objc private func closePreviewView(_ sender: UITapGestureRecognizer? = nil) {
        isPreviewOpened = previewView.frame.maxY - 6 == view.frame.maxY
        if isPreviewOpened {
            UIView.animate(withDuration: 0.3) {
                self.previewView.frame.origin.y += self.previewView.frame.height - 6
                self.previewButton.frame.origin.y += self.previewView.frame.height - 6
            }
            isPreviewOpened = false
            updateUI()
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
            self.updateImageAspectRatio()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
}

