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
    
    static let buttonBackgroundColor = UIColor.black.withAlphaComponent(0.75)
    static let buttonTintColor = UIColor.white
}

