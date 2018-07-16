//
//  PhotoGridCell.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class PhotoGridCell: UICollectionViewCell {

    class var identifier: String {
        return String(describing: self)
    }
    var representedAssetIdentifier: String!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

}
