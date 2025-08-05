//
//  SelectDeviceVC.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class SelectDeviceVC: DeviceListBaseVC {
    var selectDeviceHandler : ((_ model:ThingSmartDeviceModel) -> Void)?
    
    override func viewDidLoad() {
        self.isGroup = false;
        super.viewDidLoad()
        self.title = "Select Device"
        self.navigationItem.rightBarButtonItem = nil;
    }

    override func handle(index: Int) {
        if index >= home.deviceList.count { return }
        
        let deviceModel = home.deviceList[index]
        selectDeviceHandler?(deviceModel)
        self.navigationController?.popViewController(animated: true)
    }

}
