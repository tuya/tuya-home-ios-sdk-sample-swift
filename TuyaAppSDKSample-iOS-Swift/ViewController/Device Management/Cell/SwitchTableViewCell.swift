//
//  SwitchTableViewCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class SwitchTableViewCell: UITableViewCell {
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    // MARK: - Property
    var switchAction: ((UISwitch) -> Void)?

    @IBAction func switchTapped(_ sender: UISwitch) {
        switchAction?(sender)
    }
}
