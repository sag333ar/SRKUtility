//
//  Utility.swift
//  sagarrkothari
//
//  Created by Sagar on 12/2/15.
//  Copyright © 2015 sagarrkothari. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD
import KSReachability

@objc public class SRKUtility: NSObject {
	
	public static let sharedInstance = SRKUtility()
	static var progressHUD: MBProgressHUD? = nil
	
	let obj_KSReachability = KSReachability.reachabilityToInternet()
	
	public class func isReachableToNetwork() -> Bool {
		return self.sharedInstance.obj_KSReachability.reachable
	}
	
	public class func saveValueForKey(value:AnyObject, forKey:String) -> Bool {
		NSUserDefaults.standardUserDefaults().setObject(value, forKey: forKey)
		return NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	public class func getValueForKey(forKey:String) -> AnyObject? {
		return NSUserDefaults.standardUserDefaults().valueForKey(forKey)
	}
	
	public class func deleteValueForKey(forKey:String) -> Bool {
		NSUserDefaults.standardUserDefaults().removeObjectForKey(forKey)
		return NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	public class func showProgressHUD(from:UIViewController, title:String, subtitle:String, titleFont:UIFont?, subtitleFont:UIFont?) {
		NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
			self.progressHUD = MBProgressHUD(view: from.view)
			from.view.addSubview(self.progressHUD!)
			self.progressHUD?.labelText = title
			self.progressHUD?.detailsLabelText = subtitle
			if let font = titleFont {
				self.progressHUD?.labelFont = font
			}
			if let font = subtitleFont {
				self.progressHUD?.detailsLabelFont = font
			}
			self.progressHUD?.removeFromSuperViewOnHide = true
			self.progressHUD?.show(false)
		}
	}
	
	public class func hideProgressHUD() {
		if let hud = self.progressHUD {
			if let _ = hud.superview {
				hud.hide(false)
			}
			self.progressHUD = nil
		}
	}
	
	public class func showErrorMessage(title:String, message:String, viewController:UIViewController) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)

		ac.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay"), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
			ac.dismissViewControllerAnimated(true, completion: nil)
		}))
		viewController.presentViewController(ac, animated: true, completion: nil)
	}
	
	public class var isRunningSimulator: Bool {
		get {
			return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
		}
	}
	
	public class func base64_string_from_data(data:NSData) -> String {
		let base64EncodedString = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
		return base64EncodedString
	}
	
	public class func base64_data_from_string(string:String) -> NSData {
		let data = NSData(base64EncodedString: string, options: NSDataBase64DecodingOptions(rawValue: 0))!
		return data
	}
}
