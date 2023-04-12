//
//  DeviceStatusBehaveCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import NotificationCenter

class DeviceStatusBehaveCell: UITableViewCell {
    // MARK: - Property
    var controls = [UIControl]()
    var isReadOnly: Bool = false {
        didSet {
            isReadOnly ? disableControls() : enableControls()
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOffline), name: .deviceOffline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOnline), name: .deviceOnline, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .deviceOnline, object: nil)
        NotificationCenter.default.removeObserver(self, name: .deviceOffline, object: nil)
    }
    
    // MARK: - Device status reaction
    @objc func deviceOffline() {
        disableControls()
    }
    
    @objc func deviceOnline() {
        if !isReadOnly {
            enableControls()
        }
    }

    func enableControls() {
        for control in controls {
            control.isEnabled = true
        }
    }
    
    func disableControls() {
        for control in controls {
            control.isEnabled = false
        }
    }
}
