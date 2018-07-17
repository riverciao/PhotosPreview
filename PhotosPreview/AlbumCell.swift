//
//  AlbumCell.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/4.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumAssetNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
        albumNameLabel.textColor = .albumTextColor
        albumAssetNumberLabel.textColor = .albumTextColor
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        let image = ImageHelper.image("icon-photo")
            .withRenderingMode(.alwaysTemplate)
        albumImageView.image = image
        albumImageView.tintColor = .unselectButtonTintColor
    }
    
}
