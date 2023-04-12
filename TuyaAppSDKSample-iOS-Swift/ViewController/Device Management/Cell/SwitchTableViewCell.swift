//
//  SwitchTableViewCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit

class SwitchTableViewCell: DeviceStatusBehaveCell {
    // MARK: - IBOutlet
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    // MARK: - Property
    var switchAction: ((UISwitch) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        controls.append(switchButton)
    }

    // MARK: - IBAction
    @IBAction func switchTapped(_ sender: UISwitch) {
        switchAction?(sender)
    }
}
