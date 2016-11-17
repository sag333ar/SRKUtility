//
//  ComboBoxVCtr.swift
//  BeautyNotes
//
//  Created by Sagar on 12/18/15.
//  Copyright © 2015 Sagar R. Kothari. All rights reserved.
//

import UIKit

@objc public protocol SRKComboBoxDelegate: NSObjectProtocol {

	func comboBox(_ textField: SRKComboBox, didSelectRow row: Int)
	func comboBoxNumberOfRows(_ textField: SRKComboBox) -> Int
	func comboBox(_ textField: SRKComboBox, textForRow row: Int) -> String
	func comboBoxPresentingViewController(_ textField: SRKComboBox) -> UIViewController
	func comboBoxRectFromWhereToPresent(_ textField: SRKComboBox) -> CGRect

	func comboBoxFromBarButton(_ textField: SRKComboBox) -> UIBarButtonItem?

	func comboBoxTintColor(_ textField: SRKComboBox) -> UIColor
	func comboBoxToolbarColor(_ textField: SRKComboBox) -> UIColor

	func comboBoxDidTappedCancel(_ textField: SRKComboBox)
	func comboBoxDidTappedDone(_ textField: SRKComboBox)
}

@objc open class SRKComboBox: UITextField {
	open weak var delegateForComboBox: SRKComboBoxDelegate?
	var objComboBoxVCtr: ComboBoxVCtr?

	open func showOptions() {
        let podBundle = Bundle(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Controls", ofType: "bundle")!))
        self.objComboBoxVCtr = ComboBoxVCtr(nibName: "ComboBoxVCtr", bundle: podBundle)
        self.objComboBoxVCtr?.modalPresentationStyle = .popover
        self.objComboBoxVCtr?.popoverPresentationController?.delegate = self.objComboBoxVCtr
        self.objComboBoxVCtr?.refSRKComboBox = self
        if let btn = self.delegateForComboBox?.comboBoxFromBarButton(self) {
            self.objComboBoxVCtr?.popoverPresentationController?.barButtonItem = btn
        } else {
            self.objComboBoxVCtr?.popoverPresentationController?.sourceView = self.delegateForComboBox?.comboBoxPresentingViewController(self).view
            self.objComboBoxVCtr?.popoverPresentationController?.sourceRect = self.delegateForComboBox!.comboBoxRectFromWhereToPresent(self)
        }
        self.delegateForComboBox?.comboBoxPresentingViewController(self).present(self.objComboBoxVCtr!, animated: true, completion: nil)
	}

}

@objc open class ComboBoxVCtr: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {

	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var toolBar: UIToolbar!
	weak var refSRKComboBox: SRKComboBox?

    override open func viewDidLoad() {
        super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 320, height: 260)
		if let clr = self.refSRKComboBox?.delegateForComboBox?.comboBoxTintColor(self.refSRKComboBox!) {
			self.toolBar.tintColor = clr
		}

		if let clr = self.refSRKComboBox?.delegateForComboBox?.comboBoxToolbarColor(self.refSRKComboBox!) {
			self.toolBar.backgroundColor = clr
		}

		self.refSRKComboBox!.delegateForComboBox?.comboBox(self.refSRKComboBox!, didSelectRow: 0)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.refSRKComboBox!.delegateForComboBox?.comboBox(self.refSRKComboBox!, didSelectRow: row)
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (self.refSRKComboBox?.delegateForComboBox?.comboBoxNumberOfRows(self.refSRKComboBox!))!
	}

	open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return self.refSRKComboBox?.delegateForComboBox?.comboBox(self.refSRKComboBox!, textForRow: row)
	}

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	@IBAction open func btnDoneTapped(_ sender: UIBarButtonItem) {
		self.refSRKComboBox?.delegateForComboBox?.comboBoxDidTappedDone(self.refSRKComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction open func btnCancelTapped(_ sender: UIBarButtonItem) {
		self.refSRKComboBox?.delegateForComboBox?.comboBoxDidTappedCancel(self.refSRKComboBox!)
		self.dismiss(animated: true, completion: nil)
	}

	open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}
