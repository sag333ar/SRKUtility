//
//  StringHelper.swift
//
//

import UIKit

public extension String {

	func validateEmail() -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
		return predicate.evaluate(with: self)
	}

}
