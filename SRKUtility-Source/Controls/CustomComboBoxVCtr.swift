//
//  CustomCustomComboBoxVCtr.swift
//
import UIKit

@objc public protocol CustomComboBoxDelegateDelegate: NSObjectProtocol {

	func customComboBox(_ textField: CustomComboBoxDelegate, didSelect row: Int)
	func customComboBoxNumberOfRows(_ textField: CustomComboBoxDelegate) -> Int
	func customComboBoxHeightForRows(_ textField: CustomComboBoxDelegate) -> CGFloat
	func customComboBox(_ textField: CustomComboBoxDelegate, viewFor row: Int, reusingView view: UIView?) -> UIView

	func customComboBoxPresentingViewController(_ textField: CustomComboBoxDelegate) -> UIViewController
	func customComboBoxRectFromWhereToPresent(_ textField: CustomComboBoxDelegate) -> CGRect

	func customComboBoxFromBarButton(_ textField: CustomComboBoxDelegate) -> UIBarButtonItem?

	func customComboBoxTintColor(_ textField: CustomComboBoxDelegate) -> UIColor
	func customComboBoxToolbarColor(_ textField: CustomComboBoxDelegate) -> UIColor

	func customComboBoxDidTappedCancel(_ textField: CustomComboBoxDelegate)
	func customComboBoxDidTappedDone(_ textField: CustomComboBoxDelegate)
}

@objc open class CustomComboBoxDelegate: UITextField {
	open weak var delegateForComboBox: CustomComboBoxDelegateDelegate?
	var objCustomComboBoxVCtr: CustomComboBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "Controls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objCustomComboBoxVCtr = CustomComboBoxVCtr(nibName: "CustomComboBoxVCtr", bundle: bundle)
				self.objCustomComboBoxVCtr?.modalPresentationStyle = .popover
				self.objCustomComboBoxVCtr?.popoverPresentationController?.delegate = self.objCustomComboBoxVCtr
				self.objCustomComboBoxVCtr?.refCustomComboBoxDelegate = self
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
	weak var refCustomComboBoxDelegate: CustomComboBoxDelegate?

	override open func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxTintColor(self.refCustomComboBoxDelegate!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxToolbarColor(self.refCustomComboBoxDelegate!) {
			self.toolBar.backgroundColor = clr
		}

		self.refCustomComboBoxDelegate!.delegateForComboBox?.customComboBox(self.refCustomComboBoxDelegate!, didSelect: 0)
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.refCustomComboBoxDelegate!.delegateForComboBox?.customComboBox(self.refCustomComboBoxDelegate!, didSelect: row)
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxNumberOfRows(self.refCustomComboBoxDelegate!))!
	}

	open func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return (self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxHeightForRows(self.refCustomComboBoxDelegate!))!
	}

	open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		return (self.refCustomComboBoxDelegate!.delegateForComboBox?.customComboBox(self.refCustomComboBoxDelegate!, viewFor: row, reusingView: view))!
	}

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxDidTappedDone(self.refCustomComboBoxDelegate!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refCustomComboBoxDelegate?.delegateForComboBox?.customComboBoxDidTappedCancel(self.refCustomComboBoxDelegate!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
