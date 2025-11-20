//
//  CameraPanelEntry.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class CameraPanelEntry {
    private init() {}

    static func openCameraPanel(withDevId devId: String) -> Bool {
        guard let navigationController = UIApplication.shared.tp_navigationController else { return false }
        navigationController.pushViewController(CameraViewController(devId: devId), animated: true)
        return true
    }
}
