//
//  PhotoPreviewBar.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

protocol PhotoPreviewBarDelegate: class {
    func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar)
}

class PhotoPreviewBar: UIView {
    
    public var targetSize: CGSize {
        return self.superview!.bounds.size
    }
    public var horizontalEdgeInset: CGFloat = 0
    public var verticalEdgeInset: CGFloat = 0
    public var minimumLineSpacing: CGFloat = 2
    public var minimumInteritemSpacing: CGFloat = 0
    
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
        let view = loadNib()
        view.frame = bounds
        self.addSubview(view)
        collectionView.backgroundColor = .yellow
        
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
    }
    
    // MARK: Action
    public func open(from superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = superView.bounds.maxY - self.frame.height
        }
        isOpened = true
    }
    
    public func close(from superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = superView.bounds.maxY
        }
        isOpened = false
    }
}

extension PhotoPreviewBar {
    func loadNib() -> UIView {
        let view = Bundle.main.loadNibNamed(PhotoPreviewBar.identifier, owner: self, options: nil)?.first as! UIView
        return view
    }
}

extension PhotoPreviewBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = imageManager.asset(at: indexPath)
        imageManager.requsetImage(for: asset, targetSize: targetSize) { (image) in
            self.delegate?.didSeleteImage(image, by: self)
        }
        close(from: self.superview!)
    }
    
    // MARK: Layout
    
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
