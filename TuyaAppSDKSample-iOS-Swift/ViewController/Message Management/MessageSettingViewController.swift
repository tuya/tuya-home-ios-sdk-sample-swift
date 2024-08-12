//
//  MessageSettingViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartMessageKit

class MessageSettingViewController : UITableViewController {
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    @IBOutlet weak var systemSwitch: UISwitch!
    
    @IBOutlet weak var phoneSwitch: UISwitch!
    
    @IBOutlet weak var smsSwitch: UISwitch!
    
    @IBOutlet weak var familySwitch: UISwitch!
    
    @IBOutlet weak var noticeSwitch: UISwitch!
    
    @IBOutlet weak var phoneDesc: UILabel!
    
    @IBOutlet weak var smsDesc: UILabel!
    
    let messageSetting = ThingSmartMessagePushSetting()
    
    override func viewDidLoad() {
        messageSetting.getMessagePushSwitchStatus(with: .deviceAlarm) { result in
            self.alarmSwitch.isOn = result
        }
        
        messageSetting.getMessagePushSwitchStatus(with: .family) { result in
            self.familySwitch.isOn = result
        }
        
        messageSetting.getMessagePushSwitchStatus(with: .notice) { result in
            self.noticeSwitch.isOn = result
        }
        
        messageSetting.getDeviceAlarmSwitchStatus(with: .system) { result in
            self.systemSwitch.isOn = result
        }
        
        messageSetting.getDeviceAlarmSwitchStatus(with: .phone) { result in
            self.phoneSwitch.isOn = result
        }
        
        messageSetting.getDeviceAlarmSwitchStatus(with: .SMS) { result in
            self.smsSwitch.isOn = result
        }
        
        messageSetting.getDeviceAlarmPurchaseInfo(with: .phone) { info in
            if let info = info {
                self.phoneDesc.text = info.packageDesc
            }
        }
        
        messageSetting.getDeviceAlarmPurchaseInfo(with: .SMS) { info in
            if let info = info {
                self.smsDesc.text = info.packageDesc
            }
        }
    }
    
    @IBAction func alarmChange(sender:UISwitch) {
        let requestModel = ThingSmartMessagePushSwitchRequestModel()
        requestModel.open = self.alarmSwitch.isOn
        requestModel.type = .deviceAlarm
        messageSetting.setMessagePushSwitchStatusWith(requestModel) {
            
        }
    }
    
    @IBAction func systemChange(sender:UISwitch) {
        let requestModel = ThingSmartDeviceAlarmSwitchRequestModel()
        requestModel.open = self.systemSwitch.isOn
        requestModel.pushChannel = .system
        messageSetting.setDeviceAlarmSwitchStatusWith(requestModel) {
            
        }
    }
    
    @IBAction func phoneChange(sender:UISwitch) {
        let requestModel = ThingSmartDeviceAlarmSwitchRequestModel()
        requestModel.open = self.phoneSwitch.isOn
        requestModel.pushChannel = .phone
        messageSetting.setDeviceAlarmSwitchStatusWith(requestModel) {
            
        }
    }
    
    @IBAction func smsChange(sender:UISwitch) {
        let requestModel = ThingSmartDeviceAlarmSwitchRequestModel()
        requestModel.open = self.smsSwitch.isOn
        requestModel.pushChannel = .SMS
        messageSetting.setDeviceAlarmSwitchStatusWith(requestModel) {
            
        }
    }
    
    @IBAction func familyChange(sender:UISwitch) {
        let requestModel = ThingSmartMessagePushSwitchRequestModel()
        requestModel.open = self.familySwitch.isOn
        requestModel.type = .family
        messageSetting.setMessagePushSwitchStatusWith(requestModel) {
            
        }
    }
    
    @IBAction func noticeChange(sender:UISwitch) {
        let requestModel = ThingSmartMessagePushSwitchRequestModel()
        requestModel.open = self.noticeSwitch.isOn
        requestModel.type = .notice
        messageSetting.setMessagePushSwitchStatusWith(requestModel) {
            
        }
    }
}
