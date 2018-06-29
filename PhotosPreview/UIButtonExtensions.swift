//
//  UIButtonExtensions.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/29.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

extension UIButton {
    func setupButtonUI(with image: UIImage, backgroundColor: UIColor, tintColor: UIColor, conerRadius: CGFloat) {
        self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.layer.cornerRadius = conerRadius
        self.clipsToBounds = true
    }
}
