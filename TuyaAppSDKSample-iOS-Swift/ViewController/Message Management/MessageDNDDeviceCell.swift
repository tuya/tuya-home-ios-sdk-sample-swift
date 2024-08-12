//
//  MessageDNDDeviceCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation

class MessageDNDDeviceCell: UITableViewCell {
    
    @IBOutlet weak var actionSwitch: UISwitch!
    @IBOutlet weak var titlelabel: UILabel!

    var block : ((Bool) -> ())?
    
    @IBAction func changeSwitch() {
        if (block != nil) {
            block!(actionSwitch.isOn)
        }
    }
}
