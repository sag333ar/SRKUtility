//
//  SRKKCamera.swift
//  Sagar R. Kothari
//
//  Created by sagar kothari
//  Copyright © 2016 sagar kothari. All rights reserved.
//

import UIKit

public enum SRKCameraResponse {
	case success(UIImage)
	case cancelled
}

public struct SRKCamera {
	private static let shared = SRKCameraViewController()
	public static func openCameraController(viewController: UIViewController,
											sourceType: UIImagePickerControllerSourceType = .photoLibrary,
	                                        cameraDevice: UIImagePickerControllerCameraDevice = .front,
	                                        canEditImage: Bool = true,
	                                        handler: @escaping ((SRKCameraResponse) -> Void)
	                                        ) {
		SRKCamera.shared.sourceType = sourceType
		SRKCamera.shared.cameraDevice = cameraDevice
		SRKCamera.shared.canEditImage = canEditImage
		SRKCamera.shared.handler = handler
		viewController.present(SRKCamera.shared, animated: false, completion: nil)
	}
}

class SRKCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var canEditImage = true
	var sourceType: UIImagePickerControllerSourceType = .photoLibrary
    var cameraDevice: UIImagePickerControllerCameraDevice = .front
	var handler: ((SRKCameraResponse) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.presentCamera()
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
			if SRKUtility.isRunningSimulator {
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
