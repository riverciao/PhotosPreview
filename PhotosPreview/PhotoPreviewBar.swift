//
//  PhotoPreviewBar.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

protocol PhotoPreviewBarDelegate: class {
    // MARK: Required
    func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar)
    
    // MARK: Optional
    func previewBarWillOpen()
    func previewBarDidOpen()
    func previewBarWillClose()
    func previewBarDidClose()
}

extension PhotoPreviewBarDelegate {
    func previewBarWillOpen() {}
    func previewBarDidOpen() {}
    func previewBarWillClose() {}
    func previewBarDidClose() {}
}

class PhotoPreviewBar: UIView {
    
    public var targetSize: CGSize {
        return self.superview!.bounds.size
    }
    public var horizontalEdgeInset: CGFloat = 0
    public var verticalEdgeInset: CGFloat = 0
    public var minimumLineSpacing: CGFloat = 2
    public var minimumInteritemSpacing: CGFloat = 0
    public var barBackgroundColor: UIColor = .clear {
        didSet {
            collectionView.backgroundColor = barBackgroundColor
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoGridButton: UIButton!
    var imageManager = ImageAPIManager()
    weak var delegate: PhotoPreviewBarDelegate?
    class var identifier: String { return String(describing: self) }
    public var isOpened: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let photoPreviewBar = loadNib()
        photoPreviewBar.frame = bounds
        self.addSubview(photoPreviewBar)
        
        // MARK: CollectionView
        collectionView.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        // MARK: Button
        photoGridButton.setupButtonUI(
            with: #imageLiteral(resourceName: "icon-grid"),
            backgroundColor: .photoGridButtonBackgroundColor,
            tintColor: .photoGridButtonTintColor,
            conerRadius: photoGridButton.bounds.width / 2
        )
    }
    
    // MARK: Action
    
    public func open(from superView: UIView) {
        delegate?.previewBarWillOpen()
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = superView.bounds.maxY - self.frame.height
        }
        isOpened = true
        delegate?.previewBarDidOpen()
    }
    
    public func close(from superView: UIView) {
        delegate?.previewBarWillClose()
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = superView.bounds.maxY
        }
        isOpened = false
        delegate?.previewBarDidClose()
    }
}

extension PhotoPreviewBar {
    func loadNib() -> UIView {
        let view = Bundle.main.loadNibNamed(PhotoPreviewBar.identifier, owner: self, options: nil)?.first as! UIView
        return view
    }
}

extension PhotoPreviewBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: ColletionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = imageManager.asset(at: indexPath)
        let size = cell.bounds.size
        imageManager.requsetImage(for: asset, targetSize: size) { (image) in
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageManager.countOfAssets()
    }
    
    // MARK: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = imageManager.asset(at: indexPath)
        imageManager.requsetImage(for: asset, targetSize: targetSize) { (image) in
            self.delegate?.didSeleteImage(image, by: self)
        }
        close(from: self.superview!)
    }
    
    // MARK: CollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - verticalEdgeInset * 2
        let width = height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: verticalEdgeInset, left: horizontalEdgeInset, bottom: verticalEdgeInset, right: horizontalEdgeInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
}
