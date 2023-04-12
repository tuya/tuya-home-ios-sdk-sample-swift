//
//  StringTableViewCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit

class StringTableViewCell: DeviceStatusBehaveCell {
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Property
    var buttonAction: ((String) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        controls.append(button)
        controls.append(textField)
    }
    
    // MARK: - IBAction
    @IBAction func buttonTapped(_ sender: UIButton) {
        endEditing(true)
        buttonAction?(textField.text ?? "")
    }
    
}
