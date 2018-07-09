//
//  ColorTool.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/29.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
    
    static let photoGridButtonBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    static let photoGridButtonTintColor = UIColor.white
    static let selectedButtonBackgroundColor = UIColor(r: 50, g: 101, b: 254)
    static let selectedButtonTintColor = UIColor.white
    static let unselectButtonBackgroundColor = UIColor.white
    static let unselectButtonTintColor = UIColor.lightGray
    static let albumTextColor = UIColor.white
    static let photoGridHeaderViewOpenedColor = UIColor.black
    static let photoGridHeaderViewClosedColor = UIColor.clear
}

