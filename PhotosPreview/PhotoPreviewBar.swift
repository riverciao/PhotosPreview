//
//  PhotoPreviewBar.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

public protocol PhotoPreviewBarDelegate: class {
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

public class PhotoPreviewBar: UIView {
    
    // MARK: State
    enum State {
        case preparing, ready
    }
    
    // MARK: Public Properties
    
    /// Left edge inset and right edge inset of collection view. Default value is 0.
    public var horizontalEdgeInset: CGFloat = 0
    
    /// Top edge inset and bottom edge inset of collection view. Default value is 0.
    public var verticalEdgeInset: CGFloat = 0
    
    /// MinimumLineSpacing of collection view flow layout. Default value is 2.
    public var minimumLineSpacing: CGFloat = 2
    
    /// MinimumInteritemSpacing of collection view flow layout. Default value is 0.
    public var minimumInteritemSpacing: CGFloat = 0
    
    /// The aspect ratio of preview bar cell. Default value is 1.0.
    public var aspectRatio: CGFloat = 1
    
    /// The image size in the preview bar cell. If it is not set, the default value would be UIScreen scale times of the cell size.
    public lazy var thumbnailSize: CGSize = {
        let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let scale = UIScreen.main.scale
        return CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }()
    
    /// The time interval of opening and closing preview bar animation.
    public var animationDuration: TimeInterval = 0.3
    
    /// The backgraound color of colletion view. Default value is UIColor.clear.
    public var barBackgroundColor: UIColor = .clear {
        didSet {
            collectionView.backgroundColor = barBackgroundColor
        }
    }
    
    public var imageManager = ImageAPIManager()
    public weak var delegate: PhotoPreviewBarDelegate?
    private var state: State = .preparing {
        didSet {
            collectionView.reloadData()
        }
    }
    public var isOpened: Bool = false
    class var identifier: String { return String(describing: self) }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet public weak var photoGridButton: UIButton!
   
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let photoPreviewBar = loadNib()
        photoPreviewBar.frame = bounds
        self.addSubview(photoPreviewBar)
        
        // MARK: ImageManager
        imageManager.delegate = self
        
        // MARK: CollectionView
        collectionView.register(UINib(nibName: PhotoGridCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoGridCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = barBackgroundColor
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
        UIView.animate(withDuration: animationDuration) {
            self.frame.origin.y = superView.bounds.maxY - self.frame.height
        }
        isOpened = true
        delegate?.previewBarDidOpen()
    }
    
    public func close(from superView: UIView) {
        delegate?.previewBarWillClose()
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: animationDuration) {
            self.frame.origin.y = superView.bounds.maxY
        }
        isOpened = false
        delegate?.previewBarDidClose()
    }
}

extension PhotoPreviewBar {
    func loadNib() -> UIView {
        let bundle = Bundle(for: PhotoPreviewBar.classForCoder())
        let view = UINib(nibName: PhotoPreviewBar.identifier, bundle: bundle).instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}

extension PhotoPreviewBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: ColletionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoGridCell.identifier, for: indexPath) as! PhotoGridCell
        let asset = imageManager.asset(at: indexPath)

        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requsetImage(for: asset, targetSize: thumbnailSize) { (image) in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageManager.countOfAssets()
    }
    
    // MARK: CollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = imageManager.asset(at: indexPath)
        imageManager.requsetImage(for: asset) { (image) in
            self.delegate?.didSeleteImage(image, by: self)
        }
        close(from: self.superview!)
    }
    
    // MARK: CollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - verticalEdgeInset * 2
        let width = height * aspectRatio
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
}

extension PhotoPreviewBar: ImageManagerDelegate {
    func didGetAssetsInAlbum(by manager: ImageManager) {
        state = .ready
    }
}
