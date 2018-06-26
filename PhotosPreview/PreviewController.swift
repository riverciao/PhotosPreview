//
//  PreviewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/6/25.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class PreviewController: UIViewController {

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBAction func openPreviewView(_ sender: UIButton) {
        openView(targetView: previewView, hidden: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    func openView(targetView: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .curveEaseInOut, animations: {
            targetView.frame.origin.y = self.view.frame.height - targetView.bounds.height
            self.previewButton.frame.origin.y = targetView.frame.minY - self.previewButton.frame.height - 8
        })
    }
}

