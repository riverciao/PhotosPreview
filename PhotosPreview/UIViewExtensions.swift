//
//  UIViewExtensions.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/9.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

extension UIView {
    /// Add dark style blur effect view to self. If user disable transparency effects, add no effect.
    open func addDarkBlurBackground() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            if let tableView = self as? UITableView {
                tableView.backgroundView = blurEffectView
            } else if let colletionView = self as? UICollectionView {
                colletionView.backgroundView = blurEffectView
            } else {
                self.insertSubview(blurEffectView, at: 0)
            }
        }
    }
    
    open func addShadow(shadowColor: UIColor, shadowOffset: CGSize, opacity: Float, shadowRadius: CGFloat,borderWidth: CGFloat = 0, borderColor: UIColor? = nil) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = opacity
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
}
