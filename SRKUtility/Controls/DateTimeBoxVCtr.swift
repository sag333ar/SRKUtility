//
//  DateTimeBoxVCtr.swift
//  BeautyNotes
//
//  Created by Sagar on 12/18/15.
//  Copyright © 2015 Sagar R. Kothari. All rights reserved.
//

import UIKit

@objc public protocol SRKDateTimeBoxDelegate: NSObjectProtocol {

	func dateTimeBox(_ textField: SRKDateTimeBox, didSelectDate date: Date)
	func dateTimeBoxType(_ textField: SRKDateTimeBox) -> UIDatePickerMode

	func dateTimeBoxMinimumDate(_ textField: SRKDateTimeBox) -> Date?
	func dateTimeBoxMaximumDate(_ textField: SRKDateTimeBox) -> Date?

	func dateTimeBoxPresentingViewController(_ textField: SRKDateTimeBox) -> UIViewController
	func dateTimeBoxRectFromWhereToPresent(_ textField: SRKDateTimeBox) -> CGRect

	func dateTimeBoxFromBarButton(_ textField: SRKDateTimeBox) -> UIBarButtonItem?

	func dateTimeBoxTintColor(_ textField: SRKDateTimeBox) -> UIColor
	func dateTimeBoxToolbarColor(_ textField: SRKDateTimeBox) -> UIColor

	func dateTimeBoxDidTappedCancel(_ textField: SRKDateTimeBox)
	func dateTimeBoxDidTappedDone(_ textField: SRKDateTimeBox)
}

@objc open class SRKDateTimeBox: UITextField {
	open weak var delegateForDateTimeBox: SRKDateTimeBoxDelegate?
	var objDateTimeBoxVCtr: DateTimeBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "SRKControls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objDateTimeBoxVCtr = DateTimeBoxVCtr(nibName: "DateTimeBoxVCtr", bundle: bundle)
				self.objDateTimeBoxVCtr?.modalPresentationStyle = .popover
				self.objDateTimeBoxVCtr?.popoverPresentationController?.delegate = self.objDateTimeBoxVCtr
				self.objDateTimeBoxVCtr?.refSRKDateTimeBox = self
				if let btn = self.delegateForDateTimeBox?.dateTimeBoxFromBarButton(self) {
					self.objDateTimeBoxVCtr?.popoverPresentationController?.barButtonItem = btn
				} else {
					self.objDateTimeBoxVCtr?.popoverPresentationController?.sourceView = self.delegateForDateTimeBox?.dateTimeBoxPresentingViewController(self).view
					self.objDateTimeBoxVCtr?.popoverPresentationController?.sourceRect = (self.delegateForDateTimeBox?.dateTimeBoxRectFromWhereToPresent(self))!
				}
				self.delegateForDateTimeBox?.dateTimeBoxPresentingViewController(self).present(self.objDateTimeBoxVCtr!, animated: true, completion: nil)
			} else {
				assertionFailure("Could not load the bundle")
			}
		} else {
			assertionFailure("Could not create a path to the bundle")
		}
	}

}

@objc open class DateTimeBoxVCtr: UIViewController, UIPopoverPresentationControllerDelegate {

	@IBOutlet weak var pickerView: UIDatePicker!
	@IBOutlet weak var toolBar: UIToolbar!
	weak var refSRKDateTimeBox: SRKDateTimeBox?

	override open func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxTintColor(self.refSRKDateTimeBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxToolbarColor(self.refSRKDateTimeBox!) {
			self.toolBar.backgroundColor = clr
		}

		if let max = self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxMaximumDate(self.refSRKDateTimeBox!) {
			self.pickerView.maximumDate = max
			self.refSRKDateTimeBox!.delegateForDateTimeBox?.dateTimeBox(self.refSRKDateTimeBox!, didSelectDate: max)
		}
		if let min = self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxMinimumDate(self.refSRKDateTimeBox!) {
			self.pickerView.minimumDate = min
		}

		self.pickerView.datePickerMode = (self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxType(self.refSRKDateTimeBox!))!
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction open func dateChanged(_ sender: UIDatePicker) {
		self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBox(self.refSRKDateTimeBox!, didSelectDate: sender.date)
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxDidTappedDone(self.refSRKDateTimeBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refSRKDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxDidTappedCancel(self.refSRKDateTimeBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
