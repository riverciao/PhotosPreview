//
//  PhotoGridHeaderCell.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/9.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class PhotoGridHeaderCell: UICollectionViewCell {

    class var identifier: String { return String(describing: self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .yellow
    }
}
