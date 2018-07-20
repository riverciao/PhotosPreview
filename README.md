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

Download and drop the 'PhotosPreview' folder into your XCode project.

#### [Cocoapods](http://cocoapods.org)

Add `pod 'PhotosPreview'` to your `Podfile` and run `pod install`.

```
use_frameworks!
pod 'PhotosPreview'
```

## Quick Start
Import PhotosPreview ```import PhotosPreview``` then use the following codes and give PhotoGridDelegate to the view controller.  

```Swift
let photoGridViewController = PhotoGridViewController(nibName: PhotoGridViewController.nibName, bundle: Bundle(for: PhotoGridViewController.self))
photoGridViewController.delegate = self
self.presentViewController(photoGridViewController, animated: true, completion: nil)
```

Then you can get the image selected in PhotoGridController in PhotoGridDelegate method below.

```Swift
func didSeleteImage(_ image: UIImage, by previewBar: PhotoPreviewBar) {
    // Do something with the image
}
```


## Author
Ciao Huang 
<forwardciao@gmail.com>

## License
PhotosPreview is released under MIT license.
