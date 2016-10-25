//
//  SRKKCamera.swift
//  Sagar R. Kothari
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

import UIKit
//import SRKImagePicker

public enum SRKCameraResponse {
	case success(UIImage)
	case cancelled
}

public struct SRKCamera {
	fileprivate static let shared = SRKCameraViewController()
	fileprivate static let sharedCrop = SRKCropCamera()
	public static func openCameraController(_ viewController: UIViewController,
											sourceType: UIImagePickerControllerSourceType = .photoLibrary,
	                                        cameraDevice: UIImagePickerControllerCameraDevice = .front,
	                                        canEditImage: Bool = true,
	                                        handler: @escaping ((SRKCameraResponse) -> Void)
	                                        ) {
		SRKCamera.shared.sourceType = sourceType
		SRKCamera.shared.cameraDevice = cameraDevice
		SRKCamera.shared.canEditImage = canEditImage
		SRKCamera.shared.handler = handler
		SRKCamera.shared.hasAppeared = false
		viewController.present(SRKCamera.shared, animated: false, completion: nil)
	}
	public static func openCropCameraController(_ viewController: UIViewController,
	                                            sourceType: UIImagePickerControllerSourceType = .photoLibrary,
	                                            cameraDevice: UIImagePickerControllerCameraDevice = .front,
	                                            cropSize: CGSize = CGSize(width: 400, height: 400),
	                                            allowResize: Bool = false,
	                                            handler: @escaping ((SRKCameraResponse) -> Void)
												) {
		SRKCamera.sharedCrop.cropCam.cropSize = cropSize
		SRKCamera.sharedCrop.handler = handler
		if TARGET_OS_SIMULATOR != 0 {
			if sourceType == .camera {
				SRKCamera.sharedCrop.cropCam.imagePickerController.sourceType = .photoLibrary
			} else {
				SRKCamera.sharedCrop.cropCam.imagePickerController.sourceType = sourceType
			}
		} else {
			SRKCamera.sharedCrop.cropCam.imagePickerController.sourceType = sourceType
			SRKCamera.sharedCrop.cropCam.imagePickerController.cameraDevice = cameraDevice
		}
		SRKCamera.sharedCrop.cropCam.resizeableCropArea = allowResize
		SRKCamera.sharedCrop.cropCam.delegate = SRKCamera.sharedCrop
		viewController.present(SRKCamera.sharedCrop.cropCam.imagePickerController, animated: false, completion: nil)
	}
}

@objc class SRKCropCamera: NSObject, SRKImagePickerDelegate {
	var cropCam = SRKImagePicker(sourceType: UIImagePickerControllerSourceType.photoLibrary)!
	var handler: ((SRKCameraResponse) -> Void)?
	func imagePickerDidCancel(_ imagePicker: SRKImagePicker!) {
		self.cropCam.imagePickerController.dismiss(animated: false)
		self.handler?(SRKCameraResponse.cancelled)
	}
	func imagePicker(_ imagePicker: SRKImagePicker!, pickedImage image: UIImage!) {
		self.cropCam.imagePickerController.dismiss(animated: false)
		self.handler?(SRKCameraResponse.success(image))
	}
}

@objc class SRKCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var canEditImage = true
	var sourceType: UIImagePickerControllerSourceType = .photoLibrary
    var cameraDevice: UIImagePickerControllerCameraDevice = .front
	var handler: ((SRKCameraResponse) -> Void)?
	var hasAppeared: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if self.hasAppeared == false {
			self.hasAppeared = true
			self.presentCamera()
		}
    }

	func presentCamera() {
		if self.handler == nil {
			self.dismiss(animated: false, completion: nil)
			print("Please pass handler")
			return
		}
		if let _ = Bundle.main.infoDictionary?["NSPhotoLibraryUsageDescription"], let _ = Bundle.main.infoDictionary?["NSCameraUsageDescription"] {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			if TARGET_OS_SIMULATOR != 0 {
				if self.sourceType == .camera {
					imagePicker.sourceType = .photoLibrary
				} else {
					imagePicker.sourceType = self.sourceType
				}
			} else {
				imagePicker.sourceType = self.sourceType
				imagePicker.cameraDevice = cameraDevice
			}
			imagePicker.allowsEditing = canEditImage
			self.present(imagePicker, animated: false, completion: nil)
		} else {
			self.handler?(SRKCameraResponse.cancelled)
			self.dismiss(animated: false, completion: nil)
			print("Please add following key-value to info.plist\nNSCameraUsageDescription\nNSPhotoLibraryUsageDescription")
		}
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let selectedPhoto: UIImage
        if canEditImage {
            selectedPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        }
        else {
            selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
		self.handler?(SRKCameraResponse.success(selectedPhoto))
		picker.dismiss(animated: false) {
			self.dismiss(animated: false, completion: nil)
		}
    }
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.handler?(SRKCameraResponse.cancelled)
		picker.dismiss(animated: false) {
			self.dismiss(animated: false, completion: nil)
		}
	}
}
