//
//  StringTableViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class StringTableViewCell: UITableViewCell {
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Property
    var buttonAction: ((String) -> Void)?
    
    // MARK: - IBAction
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonAction?(textField.text ?? "")
    }
    
}
