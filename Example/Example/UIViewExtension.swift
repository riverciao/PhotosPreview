//
//  UIViewExtension.swift
//  Example
//
//  Created by riverciao on 2018/7/20.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

extension UIView {
    enum ConstraintDirection {
        case top, bottom, right, left
    }
    
    func allConstraints(equalTo view: UIView) {
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func constraints(_ directions: [ConstraintDirection], equalTo view: UIView) {
        for direction in directions {
            switch direction {
            case .top:
                self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            case .bottom:
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            case .left:
                self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            case .right:
                self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            }
        }
    }
    
    func constraints(centerTo view: UIView) {
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func constraints(sizeEqualTo size: CGSize) {
        self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
}
