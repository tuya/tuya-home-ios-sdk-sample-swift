//
//  DeviceStatusBehaveCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import NotificationCenter

class DeviceStatusBehaveCell: UITableViewCell {
    var controls = [UIControl]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOffline), name: .deviceOffline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOnline), name: .deviceOnline, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .deviceOnline, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deviceOffline, object: nil)
    }
    
    @objc func deviceOffline() {
        for control in controls {
            control.isEnabled = false
        }
    }
    
    @objc func deviceOnline() {
        for control in controls {
            control.isEnabled = true
        }
    }
    
    
}
