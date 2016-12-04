//
//  ComboBoxVCtr.swift
//

import UIKit

@objc public protocol ComboBoxDelegate: NSObjectProtocol {

	func comboBox(_ textField: ComboBox, didSelectRow row: Int)
	func comboBoxNumberOfRows(_ textField: ComboBox) -> Int
	func comboBox(_ textField: ComboBox, textForRow row: Int) -> String
	func comboBoxPresentingViewController(_ textField: ComboBox) -> UIViewController
	func comboBoxRectFromWhereToPresent(_ textField: ComboBox) -> CGRect

	func comboBoxFromBarButton(_ textField: ComboBox) -> UIBarButtonItem?

	func comboBoxTintColor(_ textField: ComboBox) -> UIColor
	func comboBoxToolbarColor(_ textField: ComboBox) -> UIColor

	func comboBoxDidTappedCancel(_ textField: ComboBox)
	func comboBoxDidTappedDone(_ textField: ComboBox)
}

@objc open class ComboBox: UITextField {
	open weak var delegateForComboBox: ComboBoxDelegate?
	open var objComboBoxVCtr: ComboBoxVCtr?

	open func showOptions() {
		let podBundle = Bundle(for: self.classForCoder)
		if let bundleURL = podBundle.url(forResource: "Controls", withExtension: "bundle") {
			if let bundle = Bundle(url: bundleURL) {
				self.objComboBoxVCtr = ComboBoxVCtr(nibName: "ComboBoxVCtr", bundle: bundle)
				self.objComboBoxVCtr?.modalPresentationStyle = .popover
				self.objComboBoxVCtr?.popoverPresentationController?.delegate = self.objComboBoxVCtr
				self.objComboBoxVCtr?.refComboBox = self
				if let btn = self.delegateForComboBox?.comboBoxFromBarButton(self) {
					self.objComboBoxVCtr?.popoverPresentationController?.barButtonItem = btn
				} else {
					self.objComboBoxVCtr?.popoverPresentationController?.sourceView = self.delegateForComboBox?.comboBoxPresentingViewController(self).view
					self.objComboBoxVCtr?.popoverPresentationController?.sourceRect = self.delegateForComboBox!.comboBoxRectFromWhereToPresent(self)
				}
				self.delegateForComboBox?.comboBoxPresentingViewController(self).present(self.objComboBoxVCtr!, animated: true, completion: nil)
			} else {
				assertionFailure("Could not load the bundle")
			}
		} else {
			assertionFailure("Could not create a path to the bundle")
		}
	}

}

@objc open class ComboBoxVCtr: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {

	@IBOutlet open weak var pickerView: UIPickerView!
	@IBOutlet open weak var toolBar: UIToolbar!
	weak var refComboBox: ComboBox?

    override open func viewDidLoad() {
        super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refComboBox?.delegateForComboBox?.comboBoxTintColor(self.refComboBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refComboBox?.delegateForComboBox?.comboBoxToolbarColor(self.refComboBox!) {
			self.toolBar.backgroundColor = clr
		}

		self.refComboBox!.delegateForComboBox?.comboBox(self.refComboBox!, didSelectRow: 0)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.refComboBox!.delegateForComboBox?.comboBox(self.refComboBox!, didSelectRow: row)
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (self.refComboBox?.delegateForComboBox?.comboBoxNumberOfRows(self.refComboBox!))!
	}

	open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return self.refComboBox?.delegateForComboBox?.comboBox(self.refComboBox!, textForRow: row)
	}

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refComboBox?.delegateForComboBox?.comboBoxDidTappedDone(self.refComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refComboBox?.delegateForComboBox?.comboBoxDidTappedCancel(self.refComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
