//
//  DateTimeBoxVCtr.swift
//

import UIKit

@objc public protocol DateTimeBoxDelegate: NSObjectProtocol {

	func dateTimeBox(_ textField: DateTimeBox, didSelectDate date: Date)
	func dateTimeBoxType(_ textField: DateTimeBox) -> UIDatePickerMode

	func dateTimeBoxMinimumDate(_ textField: DateTimeBox) -> Date?
	func dateTimeBoxMaximumDate(_ textField: DateTimeBox) -> Date?

	func dateTimeBoxPresentingViewController(_ textField: DateTimeBox) -> UIViewController
	func dateTimeBoxRectFromWhereToPresent(_ textField: DateTimeBox) -> CGRect

	func dateTimeBoxFromBarButton(_ textField: DateTimeBox) -> UIBarButtonItem?

	func dateTimeBoxTintColor(_ textField: DateTimeBox) -> UIColor
	func dateTimeBoxToolbarColor(_ textField: DateTimeBox) -> UIColor

	func dateTimeBoxDidTappedCancel(_ textField: DateTimeBox)
	func dateTimeBoxDidTappedDone(_ textField: DateTimeBox)
}

@objc open class SRKDateTimeBox: UITextField {
	open weak var delegateForDateTimeBox: SRKDateTimeBoxDelegate?
	open var objDateTimeBoxVCtr: DateTimeBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "Controls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objDateTimeBoxVCtr = DateTimeBoxVCtr(nibName: "DateTimeBoxVCtr", bundle: bundle)
				self.objDateTimeBoxVCtr?.modalPresentationStyle = .popover
				self.objDateTimeBoxVCtr?.popoverPresentationController?.delegate = self.objDateTimeBoxVCtr
				self.objDateTimeBoxVCtr?.refDateTimeBox = self
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

<<<<<<< HEAD
	@IBOutlet open weak var pickerView: UIDatePicker!
	@IBOutlet open weak var toolBar: UIToolbar!
	weak var refSRKDateTimeBox: SRKDateTimeBox?
||||||| merged common ancestors
	@IBOutlet weak var pickerView: UIDatePicker!
	@IBOutlet weak var toolBar: UIToolbar!
	weak var refSRKDateTimeBox: SRKDateTimeBox?
=======
	@IBOutlet weak var pickerView: UIDatePicker!
	@IBOutlet weak var toolBar: UIToolbar!
	weak var refDateTimeBox: DateTimeBox?
>>>>>>> 5e2ebf96702965035bd4ea0d8e53ab164aee636c

	override open func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxTintColor(self.refDateTimeBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxToolbarColor(self.refDateTimeBox!) {
			self.toolBar.backgroundColor = clr
		}

		if let max = self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxMaximumDate(self.refDateTimeBox!) {
			self.pickerView.maximumDate = max
			self.refDateTimeBox!.delegateForDateTimeBox?.dateTimeBox(self.refDateTimeBox!, didSelectDate: max)
		}
		if let min = self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxMinimumDate(self.refDateTimeBox!) {
			self.pickerView.minimumDate = min
		}

		self.pickerView.datePickerMode = (self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxType(self.refDateTimeBox!))!
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction open func dateChanged(_ sender: UIDatePicker) {
		self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBox(self.refDateTimeBox!, didSelectDate: sender.date)
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxDidTappedDone(self.refDateTimeBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refDateTimeBox?.delegateForDateTimeBox?.dateTimeBoxDidTappedCancel(self.refDateTimeBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
