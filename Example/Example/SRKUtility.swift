//
//  SRKUtility.swift
//  IGNOU
//
//  Created by sagar kothari on 21/08/16.
//  Copyright © 2016 sagar kothari. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSReachability

public struct SRKUtility {
	public static var reachability = KSReachability.toInternet()
}

// MARK: - SRKUtility Extension for Reachability

extension SRKUtility {
	public static var isReachableToInternet: Bool {
		get {
			return self.reachability!.reachable
		}
	}
}

// MARK: - SRKUtility Extension for MBProgress HUD - hide and Show

extension SRKUtility {

    private static var progressHUD: MBProgressHUD? = nil
    public static func showProgressHUD(viewController from: UIViewController,
                                      title: String,
                                      subtitle: String,
                                      titleFont: UIFont?,
                                      subtitleFont: UIFont?) {
        OperationQueue.main.addOperation {
            self.progressHUD = MBProgressHUD(view: from.view)
            from.view.addSubview(self.progressHUD!)
            self.progressHUD?.label.text = title
            self.progressHUD?.detailsLabel.text = subtitle
            if let font = titleFont {
                self.progressHUD?.label.font = font
            }
            if let font = subtitleFont {
                self.progressHUD?.detailsLabel.font = font
            }
            self.progressHUD?.removeFromSuperViewOnHide = true
            self.progressHUD?.show(animated: false)
        }
    }

    public static func hideProgressHUD() {
        OperationQueue.main.addOperation {
            if let hud = self.progressHUD {
                if let _ = hud.superview {
                    hud.hide(animated: false)
                }
                self.progressHUD = nil
            }
        }
    }

}

// MARK: - SRKUtility Extension Some Useful utilities

extension SRKUtility {

    public static func showErrorMessage(title: String,
                                       message: String,
                                       viewController: UIViewController) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: UIAlertControllerStyle.alert)

        let handler = { (action: UIAlertAction) -> Void in
            ac.dismiss(animated: true, completion: nil)
        }
        let acAction = UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay"),
                                     style: UIAlertActionStyle.default,
                                     handler: handler)
        ac.addAction(acAction)
        viewController.present(ac, animated: true, completion: nil)
    }

    public static var isRunningSimulator: Bool {
        get {
            return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        }
    }

    public static func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }

    public static func colorWithString(string: String) -> UIColor {
        let redString = string.components(separatedBy: ",")[0]
        let greenString = string.components(separatedBy: ",")[1]
        let blueString = string.components(separatedBy: ",")[2]
        let red = (redString as NSString).floatValue
        let green = (greenString as NSString).floatValue
        let blue = (blueString as NSString).floatValue
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }

}

// MARK: - SRKUtility Extension for UserDefaults

extension SRKUtility {

    public static func saveValueForKey(value: AnyObject, forKey: String) -> Bool {
        UserDefaults.standard.set(value, forKey: forKey)
        return UserDefaults.standard.synchronize()
    }

    public static func getValueForKey(forKey: String) -> AnyObject? {
        return UserDefaults.standard.value(forKey: forKey) as AnyObject?
    }

    public static func deleteValueForKey(forKey: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: forKey)
        return UserDefaults.standard.synchronize()
    }

    public static func registerDefaultsFromSettingsBundle() {
        let settingbundlepath = Bundle.main.path(forResource: "Settings", ofType: "bundle")
        let dictionary = NSDictionary(contentsOfFile: settingbundlepath!.appending("/Root.plist"))
        let array = (dictionary?.object(forKey: "PreferenceSpecifiers") as? NSArray)!
        for dictinaryOfPreference in array {
            if let d = dictinaryOfPreference as? NSDictionary {
                let key = d.value(forKey: "Key") as? String
                if key != nil {
                    UserDefaults.standard.set(d.value(forKey: "DefaultValue"), forKey: key!)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }

}

// MARK: - SRKUtility Extension for Base64

extension SRKUtility {

    public static func base64StringFromData(data: Data) -> String {
        let base64String = data.base64EncodedString(
            options: Data.Base64EncodingOptions(rawValue: 0))
        return base64String
    }

    public static func base64DataFromString(string: String) -> Data? {
        let data = Data(base64Encoded: string,
                          options: Data.Base64DecodingOptions(rawValue: 0))
        return data
    }

}
