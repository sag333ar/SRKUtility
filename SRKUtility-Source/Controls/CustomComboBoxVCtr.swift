//
//  CustomCustomComboBoxVCtr.swift
//
import UIKit

@objc public protocol CustomComboBoxDelegate: NSObjectProtocol {

	func customComboBox(_ textField: CustomComboBox, didSelect row: Int)
	func customComboBoxNumberOfRows(_ textField: CustomComboBox) -> Int
	func customComboBoxHeightForRows(_ textField: CustomComboBox) -> CGFloat
	func customComboBox(_ textField: CustomComboBox, viewFor row: Int, reusingView view: UIView?) -> UIView

	func customComboBoxPresentingViewController(_ textField: CustomComboBox) -> UIViewController
	func customComboBoxRectFromWhereToPresent(_ textField: CustomComboBox) -> CGRect

	func customComboBoxFromBarButton(_ textField: CustomComboBox) -> UIBarButtonItem?

	func customComboBoxTintColor(_ textField: CustomComboBox) -> UIColor
	func customComboBoxToolbarColor(_ textField: CustomComboBox) -> UIColor

	func customComboBoxDidTappedCancel(_ textField: CustomComboBox)
	func customComboBoxDidTappedDone(_ textField: CustomComboBox)
}

@objc open class CustomComboBox: UITextField {
	open weak var delegateForComboBox: CustomComboBoxDelegate?
	open var objCustomComboBoxVCtr: CustomComboBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "Controls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objCustomComboBoxVCtr = CustomComboBoxVCtr(nibName: "CustomComboBoxVCtr", bundle: bundle)
				self.objCustomComboBoxVCtr?.modalPresentationStyle = .popover
				self.objCustomComboBoxVCtr?.popoverPresentationController?.delegate = self.objCustomComboBoxVCtr
				self.objCustomComboBoxVCtr?.refCustomComboBox = self
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

	@IBOutlet open weak var pickerView: UIPickerView!
	@IBOutlet open weak var toolBar: UIToolbar!
	weak var refCustomComboBox: CustomComboBox?

	override open func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refCustomComboBox?.delegateForComboBox?.customComboBoxTintColor(self.refCustomComboBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refCustomComboBox?.delegateForComboBox?.customComboBoxToolbarColor(self.refCustomComboBox!) {
			self.toolBar.backgroundColor = clr
		}

		self.refCustomComboBox!.delegateForComboBox?.customComboBox(self.refCustomComboBox!, didSelect: 0)
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.refCustomComboBox!.delegateForComboBox?.customComboBox(self.refCustomComboBox!, didSelect: row)
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.refCustomComboBox!.delegateForComboBox!.customComboBoxNumberOfRows(self.refCustomComboBox!)
	}

	open func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return self.refCustomComboBox!.delegateForComboBox!.customComboBoxHeightForRows(self.refCustomComboBox!)
	}

	open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		return self.refCustomComboBox!.delegateForComboBox!.customComboBox(self.refCustomComboBox!, viewFor: row, reusingView: view)
	}

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refCustomComboBox!.delegateForComboBox!.customComboBoxDidTappedDone(self.refCustomComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refCustomComboBox!.delegateForComboBox!.customComboBoxDidTappedCancel(self.refCustomComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
