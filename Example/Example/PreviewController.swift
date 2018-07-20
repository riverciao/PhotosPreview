//
//  PreviewController.swift
//  Example
//
//  Created by riverciao on 2018/7/20.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit
import PhotosPreview

class PreviewController: UIViewController, PhotoPreviewBarDelegate, PhotoGridDelegate {

    // MARK: Properties
    
    let photoGridViewController = PhotoGridViewController(nibName: PhotoGridViewController.nibName, bundle: Bundle(for: PhotoGridViewController.self))
    var previewBar: PhotoPreviewBar!
    var displayImageView = UIImageView()
    var previewButton = UIButton()
    
    @objc private func previewButtonPressed() {
        if previewBar.isOpened {
            previewBar.close(from: view)
        } else {
            previewBar.open(from: view)
        }
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePreviewButtonUI()
    }

    // MARK: Setup
    
    private func setup() {
        view.backgroundColor = .white
        
        // MARK: PhotoPreviewBar
        previewBar.delegate = self
        previewBar.photoGridButton.addTarget(self, action: #selector(goToPhotoGrid), for: .touchUpInside)
        
        // MARK: PhotoGridController
        photoGridViewController.delegate = self
        
        // MARK: PhotoProvider
        let photoProvider = PhotoProvider()
        photoProvider.fetchAssets(in: .cameraRoll)
        previewBar.photoProvider = photoProvider
        
        // MARK: PreviewButton
        let photoImage = #imageLiteral(resourceName: "icon-photo").withRenderingMode(.alwaysTemplate)
        previewButton.setImage(photoImage, for: .normal)
        previewButton.tintColor = .white
        previewButton.backgroundColor = .lightGray
    }
    
    private func addSubview() {
        // MARK: PhotoPreviewBar
        let frame = CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 150)
        previewBar = PhotoPreviewBar(frame: frame)
        view.addSubview(previewBar)
        
        // MARK: DispalyImageView
        displayImageView.translatesAutoresizingMaskIntoConstraints = false
        displayImageView.backgroundColor = .black
        displayImageView.contentMode = .scaleAspectFit
        view.addSubview(displayImageView)
        displayImageView.constraints([.top, .left, .right], equalTo: view)
        displayImageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        // MARK: PreviewButtom
        previewButton.clipsToBounds = true
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewButton)
        previewButton.constraints(sizeEqualTo: CGSize(width: 38, height: 30))
        previewButton.leftAnchor.constraint(equalTo: displayImageView.leftAnchor, constant: 8).isActive = true
        previewButton.bottomAnchor.constraint(equalTo: displayImageView.bottomAnchor, constant: -8).isActive = true
        previewButton.addTarget(self, action: #selector(previewButtonPressed), for: .touchUpInside)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Action
    
    @objc func goToPhotoGrid() {
        present(photoGridViewController, animated: true, completion: nil)
    }
    
    private func updatePreviewButtonUI() {
        if previewBar.isOpened {
            previewButton.backgroundColor = .blue
            previewButton.tintColor = .white
        } else {
            previewButton.backgroundColor = .lightGray
            previewButton.tintColor = .white
        }
    }
    
    // MARK: PhotoPreviewBarDelegate
    
    func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar) {
        displayImageView.image = image
    }
    
    func previewBarDidOpen() {
        updatePreviewButtonUI()
    }
    
    func previewBarDidClose() {
        updatePreviewButtonUI()
    }
    
    // MARK: PhotoGridViewControllerDelegate
    
    func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController) {
        displayImageView.image = image
    }
    
    func photoGridWillDismiss() {
        previewBar.close(from: view)
    }
}
