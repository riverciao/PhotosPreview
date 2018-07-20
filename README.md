## PhotosPreview
* Messenger-like photo browser for user to preview and pick photo.
* PhotosPreview can be completely customized.
* You can use PhotosPreview to replace UIImagePickerController.
* Developed by Swift.

## Preview
<img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo1.gif" width="200">  <img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo2.gif" width="200">  <img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo3.png" width="200">

<img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo4.png" width="200">  <img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo5.png" width="200">  <img src="https://github.com/riverciao/PhotosPreview/blob/master/ScreenShot/demo6.png" width="200">

## Features
- [x] UIImagePickerController alternative
- [x] Customized photo aspect ratio, preview bar height, and cell number per raw
- [x] Album selection enabled


## Installation

#### Manual installation

Download and drop the 'PhotosPreview' folder into your Xcode project.

#### [Cocoapods](http://cocoapods.org)

Add `pod 'PhotosPreview'` to your `Podfile` and run `pod install`.

```
use_frameworks!
pod 'PhotosPreview'
```

## Quick Start
Import PhotosPreview ```import PhotosPreview``` then use the following codes and give `PhotoGridDelegate` to the view controller.  

```Swift
let photoGridViewController = PhotoGridViewController(nibName: PhotoGridViewController.nibName, bundle: Bundle(for: PhotoGridViewController.self))
photoGridViewController.delegate = self
self.presentViewController(photoGridViewController, animated: true, completion: nil)
```

Then you can get the image selected in PhotoGridController in PhotoGridDelegate method below.

```Swift
func didSelectImage(_ image: UIImage, by controller: PhotoGridViewController) {
    // Do something with the image
}
```

#### Using PhotoPreviewBar
Conform `PhotoPreviewBarDelegate` to the view controller and add the following code.
```Swift
// Setup PhotoPreviewBar
let frame = CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 150)
let previewBar = PhotoPreviewBar(frame: frame)
view.addSubview(previewBar)
previewBar.delegate = self

// Setup PhotoProvider
let photoProvider = PhotoProvider()
// can select a smart album to display in the preview bar
photoProvider.fetchAssets(in: .cameraRoll) 
previewBar.photoProvider = photoProvider
```

And set up when to open the preview bar.
```Swift
// Setup PhotoPreviewBar
func previewButtonPressed() {
    if previewBar.isOpened {
        previewBar.close(from: view) // will close to the bottom of this view
    } else {
        previewBar.open(from: view) // will open from the bottom of this view
    }
}
```


## Author
Ciao Huang 
<forwardciao@gmail.com>

## License
PhotosPreview is released under MIT license.
