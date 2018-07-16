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
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if previewBar.isOpened {
            previewBar.close(from: view)
        } else {
            previewBar.open(from: view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoGrid.delegate = self
        photoGrid.numberOfCellPerRow = 3
        photoGrid.aspectRatio = 1
//        photoGrid.verticalEdgeInset = 100
//        photoGrid.horizontalEdgeInset = 10
        photoGrid.minimumLineSpacing = 4
        photoGrid.minimumInteritemSpacing = 4
        
        manager.fetchAssets(in: .cameraRoll)
        
        // MARK : PreviewBar
        let frame = CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 200)
        previewBar = PhotoPreviewBar(frame: frame)
        previewBar.delegate = self
        previewBar.imageManager = manager
        view.addSubview(previewBar)
        previewBar.photoGridButton.addTarget(self, action: #selector(goToPhotoGrid), for: .touchUpInside)
    }
    
    @objc func goToPhotoGrid() {
        present(photoGrid, animated: true, completion: nil)
    }
    
    func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController) {
        self.image = image
        testImageView.image = image
    }
    
    func photoGridDidDismissed() {
    }
    
    func photoGridWillDismiss() {
        previewBar.close(from: view)
    }
    
    func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar) {
        testImageView.image = image
    }
    
    // MARK: PreviewBarDelegate
    
    func previewBarWillOpen() {
        print("preview bar will open")
    }
    
    func previewBarDidOpen() {
        print("preview bar did open")
    }
    
    func previewBarWillClose() {
        print("preview bar will close")
    }
    
    func previewBarDidClose() {
        print("preview bar did close")
    }

}
