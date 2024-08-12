//
//  MessageDNDSettingCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit

class MessageDNDSettingCell : UITableViewCell {
    
    @IBOutlet weak var settingSwitch: UISwitch!
    
    @IBAction func changeSetting(sender:UISwitch) {
        let status = sender.isOn
        ThingSmartMessageSetting().setDeviceDNDSettingStatus(status) {
            
        } failure: { error in
            
        }
    }
}
