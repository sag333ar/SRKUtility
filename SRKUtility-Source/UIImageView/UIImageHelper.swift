//
//  UIImageHelper.swift
//  
//
//  Created by Sagar on 9/28/16.
//  Copyright © 2016 Sagar R Kothari. Ltd. All rights reserved.
//

import UIKit

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

	public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage? {
		let radiansToDegrees: (CGFloat) -> CGFloat = {
			return $0 * (180.0 / CGFloat(M_PI))
		}
		let degreesToRadians: (CGFloat) -> CGFloat = {
			return $0 / 180.0 * CGFloat(M_PI)
		}
		
		// calculate the size of the rotated view's containing box for our drawing space
		let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
		let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
		rotatedViewBox.transform = t
		let rotatedSize = rotatedViewBox.frame.size
		
		// Create the bitmap context
		UIGraphicsBeginImageContext(rotatedSize)
		let bitmap = UIGraphicsGetCurrentContext()
		
		// Move the origin to the middle of the image so we will rotate and scale around the center.
		bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
		
		//   // Rotate the image context
		bitmap!.rotate(by: degreesToRadians(degrees));
		
		// Now, draw the rotated/scaled image into the context
		var yFlip: CGFloat
		
		if(flip){
			yFlip = CGFloat(-1.0)
		} else {
			yFlip = CGFloat(1.0)
		}
		
		bitmap!.scaleBy(x: yFlip, y: -1.0)
		let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
		bitmap!.draw(cgImage!, in: rect)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}
