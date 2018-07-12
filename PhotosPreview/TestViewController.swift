//
//  TestViewController.swift
//  PhotosPreview
//
//  Created by riverciao on 2018/7/12.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, PhotoGridDelegate {
    
    @IBOutlet weak var testImageView: UIImageView!
    var image: UIImage? = nil
    let photoGrid = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoGridViewController") as! PhotoGridViewController
    @IBAction func ButtonPressed(_ sender: UIButton) {
        present(photoGrid, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoGrid.targetSize = UIScreen.main.bounds.size
        photoGrid.delegate = self
    }
    
    func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController) {
        self.image = image
        print("image: \(image)")
        testImageView.image = image
    }

}
