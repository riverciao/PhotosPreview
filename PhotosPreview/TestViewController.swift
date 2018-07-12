//
//  TestViewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, PhotoGridDelegate, PhotoPreviewBarDelegate {
    
    @IBOutlet weak var testImageView: UIImageView!
    var previewBar: PhotoPreviewBar!
    var image: UIImage? = nil
    let manager = ImageAPIManager()
    let photoGrid = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoGridViewController") as! PhotoGridViewController
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
//        present(photoGrid, animated: true, completion: nil)
        
        if previewBar.isOpened {
            previewBar.closePreviewBar(from: view)
        } else {
            previewBar.openPreviewBar(from: view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoGrid.targetSize = UIScreen.main.bounds.size
        photoGrid.delegate = self
        let frame = CGRect(x: 0, y: view.frame.maxY - 200, width: view.frame.width, height: 200)
        previewBar = PhotoPreviewBar(frame: frame)
        previewBar.delegate = self
        manager.fetchAssets(in: .cameraRoll)
        previewBar.imageManager = manager
        view.addSubview(previewBar)
    }
    
    func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController) {
        self.image = image
        testImageView.image = image
    }
    
    func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar) {
        testImageView.image = image
    }

}
