//
//  CustomCustomComboBoxVCtr.swift
//  BeautyNotes
//
//  Created by Sagar on 12/18/15.
//  Copyright © 2015 Sagar R. Kothari. All rights reserved.
//

import UIKit

@objc public protocol SRKCustomComboBoxDelegate: NSObjectProtocol {

	func customComboBox(_ textField: SRKCustomComboBox, didSelect row: Int)
	func customComboBoxNumberOfRows(_ textField: SRKCustomComboBox) -> Int
	func customComboBoxHeightForRows(_ textField: SRKCustomComboBox) -> CGFloat
	func customComboBox(_ textField: SRKCustomComboBox, viewFor row: Int, reusingView view: UIView?) -> UIView

	func customComboBoxPresentingViewController(_ textField: SRKCustomComboBox) -> UIViewController
	func customComboBoxRectFromWhereToPresent(_ textField: SRKCustomComboBox) -> CGRect

	func customComboBoxFromBarButton(_ textField: SRKCustomComboBox) -> UIBarButtonItem?

	func customComboBoxTintColor(_ textField: SRKCustomComboBox) -> UIColor
	func customComboBoxToolbarColor(_ textField: SRKCustomComboBox) -> UIColor

	func customComboBoxDidTappedCancel(_ textField: SRKCustomComboBox)
	func customComboBoxDidTappedDone(_ textField: SRKCustomComboBox)
}

@objc open class SRKCustomComboBox: UITextField {
	open weak var delegateForComboBox: SRKCustomComboBoxDelegate?
	var objCustomComboBoxVCtr: CustomComboBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "Controls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objCustomComboBoxVCtr = CustomComboBoxVCtr(nibName: "CustomComboBoxVCtr", bundle: bundle)
				self.objCustomComboBoxVCtr?.modalPresentationStyle = .popover
				self.objCustomComboBoxVCtr?.popoverPresentationController?.delegate = self.objCustomComboBoxVCtr
				self.objCustomComboBoxVCtr?.refSRKCustomComboBox = self
				if let btn = self.delegateForComboBox?.customComboBoxFromBarButton(self) {
					self.objCustomComboBoxVCtr?.popoverPresentationController?.barButtonItem = btn
				} else {
					self.objCustomComboBoxVCtr?.popoverPresentationController?.sourceView = self.delegateForComboBox?.customComboBoxPresentingViewController(self).view
					self.objCustomComboBoxVCtr?.popoverPresentationController?.sourceRect = self.delegateForComboBox!.customComboBoxRectFromWhereToPresent(self)
				}
				self.delegateForComboBox?.customComboBoxPresentingViewController(self).present(self.objCustomComboBoxVCtr!, animated: true, completion: nil)
			} else {
				assertionFailure("Could not load the bundle")
			}
		} else {
			assertionFailure("Could not create a path to the bundle")
		}
	}

}

@objc open class CustomComboBoxVCtr: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {

	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var toolBar: UIToolbar!
	weak var refSRKCustomComboBox: SRKCustomComboBox?

	override open func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxTintColor(self.refSRKCustomComboBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxToolbarColor(self.refSRKCustomComboBox!) {
			self.toolBar.backgroundColor = clr
		}

		self.refSRKCustomComboBox!.delegateForComboBox?.customComboBox(self.refSRKCustomComboBox!, didSelect: 0)
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.refSRKCustomComboBox!.delegateForComboBox?.customComboBox(self.refSRKCustomComboBox!, didSelect: row)
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxNumberOfRows(self.refSRKCustomComboBox!))!
	}

	open func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return (self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxHeightForRows(self.refSRKCustomComboBox!))!
	}

	open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		return (self.refSRKCustomComboBox!.delegateForComboBox?.customComboBox(self.refSRKCustomComboBox!, viewFor: row, reusingView: view))!
	}

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxDidTappedDone(self.refSRKCustomComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refSRKCustomComboBox?.delegateForComboBox?.customComboBoxDidTappedCancel(self.refSRKCustomComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
