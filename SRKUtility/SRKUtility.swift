//
//  Utility.swift
//  HFTDriver
//
//  Created by Sagar on 12/2/15.
//  Copyright © 2015 sagarrkothari. All rights reserved.
//

import UIKit

class SRKUtility: NSObject {
	
	class func showErrorMessage(title:String, message:String, viewController:UIViewController) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		ac.addAction(UIAlertAction(title: LOCALIZE("Okay"), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
			ac.dismissViewControllerAnimated(true, completion: nil)
		}))
		viewController.presentViewController(ac, animated: true, completion: nil)
	}
	
	class var isRunningSimulator: Bool {
		get {
			return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
		}
	}
	
	class func base64_string_from_data(data:NSData) -> String {
		let base64EncodedString = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
		return base64EncodedString
	}
	
	class func base64_data_from_string(string:String) -> NSData {
		let data = NSData(base64EncodedString: string, options: NSDataBase64DecodingOptions(rawValue: 0))!
		return data
	}
	
	class func invokeRequestForJSONResponseDictionaryData(request:NSMutableURLRequest, Handler:(NSDictionary?, NSString?) -> Void) -> NSURLSessionDataTask {
		request.timeoutInterval = 20
		let task =  NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
			do {
				if let responseData = data {
					if let responseObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
						if let responseDictionary = responseObject["response"]![0] as? NSDictionary {
							Handler(responseDictionary, nil)
						} else {
							Handler(nil, "Invalid response received")
						}
					} else {
						Handler(nil, "Invalid response received")
					}
				} else {
					Handler(nil, "Invalid response received")
				}
			} catch {
				print(error)
				Handler(nil, "Invalid JSON Request received\n\(error)")
			}
		})
		task.resume()
		return task
	}
	
	class func invokeRequestForJSON(request:NSMutableURLRequest, Handler:(AnyObject?, NSString?) -> Void) -> NSURLSessionDataTask {
		request.timeoutInterval = 20
		let task =  NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
			do {
				if let responseData = data {
					let responseObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments)
					return Handler(responseObject, nil)
				} else {
					Handler(nil, "Invalid response received")
				}
			} catch {
				print(error)
				Handler(nil, "Invalid JSON Request received\n\(error)")
			}
		})
		task.resume()
		return task
	}

	class func invokeRequestForData(request:NSMutableURLRequest, Handler:(NSData?, NSString?) -> Void) -> NSURLSessionDataTask {
		request.timeoutInterval = 20
		let task =  NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
			
			if let r = error {
				Handler(nil, r.localizedDescription)
			} else if let dataReceived = data {
				Handler(dataReceived, nil)
			} else {
				Handler(nil, "Some error occured")
			}
		})
		task.resume()
		return task
	}
}
