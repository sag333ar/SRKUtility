//
//  UIImageHelper.swift
//  
//
//  Created by Sagar on 9/28/16.
//  Copyright © 2016 Sagar R Kothari. Ltd. All rights reserved.
//

import UIKit

public extension Double {
	func toRadians() -> CGFloat {
		return CGFloat(self * .pi / 180.0)
	}
}

public extension UIImage {

	public func resizeWith(percentage: CGFloat) -> UIImage? {
		let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
		imageView.contentMode = .scaleAspectFit
		imageView.image = self
		UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		imageView.layer.render(in: context)
		guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
		UIGraphicsEndImageContext()
		return result
	}

	public func resizeWith(width: CGFloat) -> UIImage? {
		let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
		imageView.contentMode = .scaleAspectFit
		imageView.image = self
		UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		imageView.layer.render(in: context)
		guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
		UIGraphicsEndImageContext()
		return result
	}

	func rotated(by degrees: Double, flipped: Bool = false) -> UIImage? {
		guard let cgImage = self.cgImage else { return nil }
		
		let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
		var rect = CGRect(origin: .zero, size: self.size).applying(transform)
		rect.origin = .zero
		
		let renderer = UIGraphicsImageRenderer(size: rect.size)
		return renderer.image { renderContext in
			renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
			renderContext.cgContext.rotate(by: degrees.toRadians())
			renderContext.cgContext.scaleBy(x: flipped ? -1.0 : 1.0, y: -1.0)
			
			let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
			renderContext.cgContext.draw(cgImage, in: drawRect)
		}
	}
}
