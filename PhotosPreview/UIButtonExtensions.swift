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
        let horizantalInset = self.bounds.width / 3.5
        let verticalInset = self.bounds.height / 3.5
        self.imageEdgeInsets = UIEdgeInsets(top: verticalInset, left: horizantalInset, bottom: verticalInset, right: horizantalInset)
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.layer.cornerRadius = conerRadius
        self.clipsToBounds = true
    }
}
